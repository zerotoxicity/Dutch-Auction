const { ethers } = require("hardhat");
const { expect } = require("chai");
const {
  AUCTION_SUPPLY,
  deployContract,
  fastForwardTwentyMins,
  notZero,
} = require("./TestHelper");

describe("📝 Auction Contract", function () {
  let ketchupContract;
  let auctionContract;
  let deployer;
  let accounts;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    ketchupContract = await deployContract("KetchupTokenV1", [
      "Ketchup",
      "KCH",
    ]);

    auctionContract = await deployContract("AuctionV1", [
      ketchupContract.address,
    ]);
    await ketchupContract.transferOwnership(auctionContract.address);
  });

  it("👨 Only owner can start auction", async function () {
    await expect(auctionContract.connect(accounts[1]).startAuction()).to.be
      .reverted;
    await auctionContract.startAuction();

    // Contract should be funded
    expect(
      await ketchupContract.balanceOf(auctionContract.address)
    ).to.be.equal(AUCTION_SUPPLY);

    // Auction state should be 0(Auctionstate.ONGOING)
    expect(await auctionContract.getAuctionState()).to.equal(0);
  });

  it("⏱  Check if auction ends on time", async function () {
    await expect(auctionContract.checkIfAuctionShouldEnd()).to.be.revertedWith(
      "Auction is closed."
    );
    await auctionContract.startAuction();

    //20 minutes has not passed, auction should not end
    await expect(auctionContract.checkIfAuctionShouldEnd())
      .to.emit(auctionContract, "ShouldAuctionEnd")
      .withArgs(false);
    await fastForwardTwentyMins();

    //20 minutes has passed, auction should end
    await expect(auctionContract.checkIfAuctionShouldEnd())
      .to.emit(auctionContract, "ShouldAuctionEnd")
      .withArgs(true);
  });

  it("🏷 After 20 mins, the final price is the reserve price", async function () {
    await auctionContract.startAuction();
    await fastForwardTwentyMins();
    await auctionContract.checkIfAuctionShouldEnd();
    expect(await auctionContract.getTokenPrice(0)).to.be.equal(
      BigInt(1e18 - 20 * 60 * 1e12)
    );
  });

  it("👴 User is able to bid with 1 wei", async function () {
    await auctionContract.startAuction();
    await auctionContract.insertBid({ value: 1 });
    await fastForwardTwentyMins();
    await auctionContract.checkIfAuctionShouldEnd();
    await auctionContract.withdraw();
    expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
      BigInt(1)
    );
  });

  it("🔁 User is able to insert bid only when the auction is ongoing", async function () {
    await expect(auctionContract.insertBid({ value: 1 })).to.be.revertedWith(
      "Auction is closed."
    );
    await auctionContract.startAuction();
    await auctionContract.insertBid({ value: ethers.utils.parseEther("1") });

    //User should get at least 1e18 KCH for 1e18 Wei(1 ETH)
    expect(await auctionContract.getSupplyReserved()).to.be.greaterThan(
      BigInt(1e18)
    );
  });

  it("👶 User is able to bid for whole auction supply", async function () {
    await auctionContract.startAuction();

    //As time has elapsed since the start of auction, the token price has dropped below 1 eth/token
    await auctionContract.insertBid({ value: ethers.utils.parseEther("100") });
    expect(await auctionContract.getAuctionState()).to.be.equal(1);

    //Therefore, user qualifies for refund
    await expect(auctionContract.withdraw())
      .to.emit(auctionContract, "Receiving")
      .withArgs(notZero);
    expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
      AUCTION_SUPPLY
    );
  });

  it("🌊 Start auction should have resetted previous auction variables", async function () {
    await auctionContract.startAuction();
    const firstAuctionStartTime = await auctionContract.getAuctionStartTime();
    await auctionContract.insertBid({ value: ethers.utils.parseEther("100") });
    await auctionContract.startAuction();
    expect(await auctionContract.getAuctionStartTime()).to.be.greaterThan(
      firstAuctionStartTime
    );
    expect(
      await auctionContract.getUserBidAmount(deployer.address)
    ).to.be.equal(0);
  });

  it("⌛️ User is able to withdraw past auction prize", async function () {
    await auctionContract.startAuction();

    //User funds first auction
    await auctionContract.insertBid({ value: ethers.utils.parseEther("100") });

    //Start second auction
    await auctionContract.startAuction();

    //User is unable to withdraw while an auction is ongoing
    await expect(auctionContract.withdraw()).to.be.reverted;

    //End auction
    await fastForwardTwentyMins();
    await auctionContract.checkIfAuctionShouldEnd();

    await auctionContract.withdraw();
    expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
      AUCTION_SUPPLY
    );
  });

  it("🔥 Auction should burn leftover tokens", async function () {
    await auctionContract.startAuction();
    await auctionContract.insertBid({ value: ethers.utils.parseEther("1") });
    expect(
      await auctionContract.getTotalBiddedAmount(auctionContract.getAuctionNo())
    ).to.be.equal(BigInt(1e18));
    await fastForwardTwentyMins();
    await auctionContract.checkIfAuctionShouldEnd();
    await auctionContract.withdraw();
    expect(
      await ketchupContract.balanceOf(auctionContract.address)
    ).to.be.equal(0);
  });

  it("👵 User is able to insert multiple bids", async function () {
    await auctionContract.startAuction();
    await auctionContract.insertBid({ value: ethers.utils.parseEther("50") });
    expect(
      await auctionContract.getTotalBiddedAmount(auctionContract.getAuctionNo())
    ).to.be.equal(BigInt(50 * 1e18));
    await auctionContract.insertBid({ value: ethers.utils.parseEther("50") });
    expect(await auctionContract.getTotalBiddedAmount(0)).to.be.equal(
      AUCTION_SUPPLY
    );
    await auctionContract.withdraw();
    expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
      AUCTION_SUPPLY
    );
  });

  it("💸 Last bidder should be refunded if demand exceeds supply ", async function () {
    await auctionContract.startAuction();

    //Insert 120 ETH into the auction
    for (i = 0; i < 4; i++) {
      await auctionContract
        .connect(accounts[i])
        .insertBid({ value: ethers.utils.parseEther("30") });
    }
    //First 3 bidders are not entitled to refunds
    for (i = 0; i < 3; i++)
      expect(await auctionContract.connect(accounts[i]).withdraw())
        .to.emit(auctionContract, "Receiving")
        .withArgs((x) => x === 0);

    //Last bidder should get a refund as they overbid by >= 20 ETH
    expect(await auctionContract.connect(accounts[3]).withdraw())
      .to.emit(auctionContract, "Receiving")
      .withArgs(notZero);
  });

  it("👩 Owner is able to withdraw all of the eth in the contract", async function () {
    await auctionContract.startAuction();
    await auctionContract
      .connect(accounts[1])
      .insertBid({ value: ethers.utils.parseEther("120") });
    expect(await auctionContract.withdrawAll())
      .to.emit(auctionContract, "Receiving")
      .withArgs(AUCTION_SUPPLY);
  });
});
