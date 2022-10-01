const { ethers, upgrades, waffle } = require("hardhat");
const { expect } = require("chai");
const {
  AUCTION_SUPPLY,
  BURN_AMOUNT,
  deployKetchupContract,
  deployIterableMapping,
} = require("./TestHelper");

describe("📝 Auction Contract", function () {
  let ketchupContract;
  let auctionContract;
  let iterableMapping;
  let deployer;
  let accounts;

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    ketchupContract = await deployKetchupContract();
    iterableMapping = await deployIterableMapping();

    const AuctionV1 = await ethers.getContractFactory("AuctionV1", {});
    auctionContract = await upgrades.deployProxy(
      AuctionV1,
      [ketchupContract.address],
      { kind: "uups" }
    );
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
    // Auction state should be 0(ONGOING)
    expect(await auctionContract.getAuctionState()).to.equal(0);
  });

  it("⏱  Check if auction ends on time", async function () {
    await expect(auctionContract.checkIfAuctionShouldEnd()).to.be.revertedWith(
      "Auction is closed."
    );
    await auctionContract.startAuction();
    await expect(auctionContract.checkIfAuctionShouldEnd())
      .to.emit(auctionContract, "ShouldAuctionEnd")
      .withArgs(false);

    //Fast forward time by 20 minutes
    await ethers.provider.send("evm_increaseTime", [60 * 60 * 20]);
    await ethers.provider.send("evm_mine");

    await expect(auctionContract.checkIfAuctionShouldEnd())
      .to.emit(auctionContract, "ShouldAuctionEnd")
      .withArgs(true);
  });

  it("🔁 User is able to insert bid only while the auction is ongoing", async function () {
    await expect(auctionContract.insertBid({ value: 1 })).to.be.revertedWith(
      "Auction is closed."
    );
    await auctionContract.startAuction();
    await auctionContract.insertBid({ value: ethers.utils.parseEther("1") });

    expect(await auctionContract.getSupplyReserved()).to.be.equal(10);
  });
});
