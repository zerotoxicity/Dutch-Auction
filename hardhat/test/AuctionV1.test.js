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

  describe("🏷 Token price", function () {
    it(" After 20 mins, the final price should be equal to the reserve price", async function () {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();
      expect(await auctionContract.getTokenPrice(0)).to.be.equal(
        BigInt(1e18 - 20 * 60 * 1e12) //Formula from Constants.sol
      );
    });
  });

  describe("🕥 User bid history", function () {
    it("Return 0 if the user did not bid", async function () {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();
      expect(
        await auctionContract.getUserBidAmount(
          accounts[0].address,
          await auctionContract.getAuctionNo()
        )
      ).to.be.equal(0);
    });
    it("Returns caller's bidded value for the auctions", async function () {
      //Auction no. 0
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: 100 });
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();

      //Auction no. 1
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: AUCTION_SUPPLY });

      expect(
        await auctionContract.getUserBidAmount(accounts[0].address, 0)
      ).to.be.equal(100);

      expect(
        await auctionContract.getUserBidAmount(
          accounts[0].address,
          (await auctionContract.getAuctionNo()) - 1
        )
      ).to.be.greaterThan(ethers.utils.parseEther("99"));
    });
  });

  describe("👨 Start auction", function () {
    it("Reverts if not started by owner", async function () {
      await expect(auctionContract.connect(accounts[1]).startAuction()).to.be
        .reverted;
    });
    it("Reverts if an auction is ongoing", async function () {
      await auctionContract.startAuction();
      await expect(auctionContract.startAuction()).to.be.reverted;
    });
    it("Owner is able to start auction", async function () {
      await auctionContract.startAuction();

      // Contract should be funded with KCH token
      expect(
        await ketchupContract.balanceOf(auctionContract.address)
      ).to.be.equal(AUCTION_SUPPLY);

      // Auction state should be 0(Auctionstate.ONGOING)
      expect(await auctionContract.getAuctionState()).to.equal(0);
    });

    it("Previous auction variables should be resetted", async function () {
      await auctionContract.startAuction();
      const firstAuctionStartTime = await auctionContract.getAuctionStartTime(
        await auctionContract.getAuctionNo()
      );
      await auctionContract.insertBid({
        value: ethers.utils.parseEther("100"),
      });

      //Start 2nd auction
      await auctionContract.startAuction();
      expect(
        await auctionContract.getAuctionStartTime(
          await auctionContract.getAuctionNo()
        )
      ).to.be.greaterThan(firstAuctionStartTime);

      //User only bidded in first auction, expect zero bid value in second auction
      expect(
        await auctionContract.getUserBidAmount(
          deployer.address,
          await auctionContract.getAuctionNo()
        )
      ).to.be.equal(0);
    });
  });

  describe("⏱ End auction", function () {
    it("Reverts when auction is closed", async function () {
      await expect(auctionContract.checkIfAuctionShouldEnd()).to.be.reverted;
    });
    it("Cant end unbidded auction before 20 minutes", async function () {
      await auctionContract.startAuction();

      //20 minutes has not passed, auction should not end
      await expect(auctionContract.checkIfAuctionShouldEnd())
        .to.emit(auctionContract, "ShouldAuctionEnd")
        .withArgs(false);
    });
    it("Ends auction when 20 minutes have elapsed", async function () {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      //20 minutes has passed, auction should end
      await expect(auctionContract.checkIfAuctionShouldEnd())
        .to.emit(auctionContract, "ShouldAuctionEnd")
        .withArgs(true);
    });

    it("Auction end time should be updated", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({
        value: ethers.utils.parseEther("100"),
      });
      expect(await auctionContract.getAuctionEndTime(0)).to.be.greaterThan(
        await auctionContract.getAuctionStartTime(0)
      );
    });

    it("Max auction end time should be 20 minutes after start time", async function () {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();
      expect(await auctionContract.getAuctionEndTime(0)).to.be.equal(
        BigInt(await auctionContract.getAuctionStartTime(0)) + BigInt(20 * 60)
      );
    });

    it("Leftover tokens should be burnt", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: ethers.utils.parseEther("1") });
      expect(
        await auctionContract.getTotalBiddedAmount(
          auctionContract.getAuctionNo()
        )
      ).to.be.equal(BigInt(1e18));
      await fastForwardTwentyMins();

      //Contract would burn the unsold tokens
      await auctionContract.checkIfAuctionShouldEnd();

      //After bidder withdraw KCH, there should be no KCH left in the contract.
      await auctionContract.withdraw();
      expect(
        await ketchupContract.balanceOf(auctionContract.address)
      ).to.be.equal(0);
    });

    it("Last bidder should be refunded if demand exceeds supply ", async function () {
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

    it("Ketchup Token Contract should receive >99 ETH from an ended and sold out auction", async () => {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: AUCTION_SUPPLY });
      balance = await ethers.provider.getBalance(ketchupContract.address);
      expect(balance).to.be.greaterThan(BigInt(1e19));
      expect(await ketchupContract.getAvgTokenPrice()).to.be.equal(
        BigInt((balance * 1e18) / 1e20)
      );
    });

    it("Ketchup Token Contract should receive 0 ETH from an ended and unbidded auction", async () => {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      balance = await ethers.provider.getBalance(ketchupContract.address);
      expect(balance).to.be.equal(0);
      expect(await ketchupContract.getAvgTokenPrice()).to.be.equal(0);
    });
  });

  describe("👴 Insert bid", function () {
    it("Reverts when auction is closed", async function () {
      await expect(auctionContract.insertBid({ value: 1 })).to.be.revertedWith(
        "Auction is closed."
      );
    });

    it("Able to bid with 1 wei", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: 1 });
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();
      await auctionContract.withdraw();
      expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
        BigInt(1)
      );
    });

    it("Able to insert bid only when the auction is ongoing", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: ethers.utils.parseEther("1") });

      //User should get at least 1e18 KCH for 1e18 Wei(1 ETH)
      expect(await auctionContract.getSupplyReserved()).to.be.greaterThan(
        BigInt(1e18)
      );
    });

    it("One user is able to bid for whole auction supply", async function () {
      await auctionContract.startAuction();

      //As time has elapsed since the start of auction, the token price has dropped below 1 eth/token
      await auctionContract.insertBid({
        value: ethers.utils.parseEther("100"),
      });
      expect(await auctionContract.getAuctionState()).to.be.equal(1);

      //Therefore, user qualifies for refund
      await expect(auctionContract.withdraw())
        .to.emit(auctionContract, "Receiving")
        .withArgs(notZero);
      expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
        AUCTION_SUPPLY
      );
    });

    it("User is able to insert multiple bids", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: ethers.utils.parseEther("50") });
      expect(
        await auctionContract.getTotalBiddedAmount(
          auctionContract.getAuctionNo()
        )
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
    it("User is refunded if auction is meant to end", async () => {
      await auctionContract.startAuction();
      //User 1 bids 99 ETH, just short of 1 ETH to end the auction
      await auctionContract.insertBid({ value: ethers.utils.parseEther("99") });
      await fastForwardTwentyMins();
      //Auction is still ongoing as no one has called the function to end the auction

      //User 2 wants to bid
      await auctionContract
        .connect(accounts[1])
        .insertBid({ value: ethers.utils.parseEther("1") });
      //Auction ends and refunds User 2's 1 ETH (instead of inserting User 2's bid)
      await expect(auctionContract.connect(accounts[1]).withdraw())
        .to.emit(auctionContract, "Receiving")
        .withArgs(BigInt(1e18));
    });

    it("Scenario with 3 bidders(2 successful, 1 excess)", async function () {
      await auctionContract.startAuction();
      await auctionContract.insertBid({ value: ethers.utils.parseEther("90") });

      await auctionContract
        .connect(accounts[1])
        .insertBid({ value: ethers.utils.parseEther("9") });

      await auctionContract
        .connect(accounts[2])
        .insertBid({ value: ethers.utils.parseEther("5") });

      await expect(auctionContract.connect(accounts[2]).withdraw())
        .to.emit(auctionContract, "Receiving")
        .withArgs((x) => x > BigInt(4e18));

      await auctionContract.connect(accounts[1]).withdraw();
      expect(
        await ketchupContract.balanceOf(accounts[1].address)
      ).to.be.greaterThan(BigInt(9e18));
    });
  });

  describe("💳 Withdraw", function () {
    it("Reverts when auction is not closed", async function () {
      await auctionContract.startAuction();
      await expect(auctionContract.withdraw()).to.be.reverted;
    });

    it("Reverts when caller did not bid in auction", async function () {
      await auctionContract.startAuction();
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();
      await expect(auctionContract.withdraw()).to.be.reverted;
    });

    it("Bidder is able to withdraw past auction prize", async function () {
      await auctionContract.startAuction();

      //User funds first auction
      await auctionContract.insertBid({
        value: ethers.utils.parseEther("100"),
      });

      //Start second auction
      await auctionContract.startAuction();

      //User is unable to withdraw while an auction is ongoing
      await expect(auctionContract.withdraw()).to.be.reverted;

      //End auction
      await fastForwardTwentyMins();
      await auctionContract.checkIfAuctionShouldEnd();

      await auctionContract.withdraw();
      expect(await ketchupContract.balanceOf(deployer.address)).to.be.equal(
        await auctionContract.getAuctionSupply()
      );
    });
  });
});
