const { ethers } = require("hardhat");
const { expect } = require("chai");
const { AUCTION_SUPPLY, BURN_AMOUNT, deployContract } = require("./TestHelper");

describe("💰 Ketchup Token", function () {
  let ketchupContract;
  let deployer;
  let accounts; //Accounts[1] is selected as mock Auction Contract address

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    ketchupContract = await deployContract("KetchupTokenV1", [
      "Ketchup",
      "KCH",
    ]);

    await ketchupContract.transferOwnership(accounts[1].address);
    //Mint token to fund auction
    await ketchupContract.connect(accounts[1]).fundAuction();
  });

  it("👨 Owner should be changed", async function () {
    expect(await ketchupContract.owner()).to.equals(accounts[1].address);
  });

  describe("🔨 Mint", function () {
    it("Revert when caller is not owner", async function () {
      await expect(ketchupContract.fundAuction()).to.be.reverted;
    });

    it("Tokens should be minted", async function () {
      expect(await ketchupContract.balanceOf(accounts[1].address)).to.equal(
        AUCTION_SUPPLY
      );
    });
    it("Maximum mintable should be 1e20", async function () {
      for (i = 0; i < 9; i++) {
        await ketchupContract.connect(accounts[1]).fundAuction();
      }

      //Account should have 1e20 tokens after calling fundAuctions() x10
      expect(await ketchupContract.balanceOf(accounts[1].address)).to.equal(
        AUCTION_SUPPLY * BigInt(10)
      );

      //Further fundAuction() calls should fail
      await expect(
        ketchupContract.connect(accounts[1]).fundAuction()
      ).to.be.revertedWith("Max supply exceeded");
    });
  });

  describe("🔥 Burning tokens", function () {
    it("Revert when caller is not owner", async function () {
      await expect(ketchupContract.burnRemainingToken(1)).to.be.reverted;
    });

    it("Remaining token should be burnt", async function () {
      await ketchupContract
        .connect(accounts[1])
        .burnRemainingToken(BURN_AMOUNT);
      expect(await ketchupContract.balanceOf(accounts[1].address)).to.equal(
        AUCTION_SUPPLY - BURN_AMOUNT
      );
    });
  });
});
