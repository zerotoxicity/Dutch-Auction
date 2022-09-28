const { ethers, upgrades, waffle } = require("hardhat");
const { expect } = require("chai");

describe("💰 Ketchup Token", function () {
  let ketchupContract;
  let deployer;
  let accounts; //Accounts[1] is selected as mock Auction Contract address

  beforeEach(async function () {
    accounts = await ethers.getSigners();
    deployer = accounts[0];
    const KetchupTokenV1 = await ethers.getContractFactory("KetchupTokenV1");
    ketchupContract = await upgrades.deployProxy(
      KetchupTokenV1,
      ["Ketchup", "KCH"],
      {
        kind: "uups",
      }
    );

    await ketchupContract.transferOwnership(accounts[1].address);
    await ketchupContract.connect(accounts[1]).fundAuction();
  });

  it("👨 Owner should be changed to accounts[1]", async function () {
    expect(await ketchupContract.owner()).to.equals(accounts[1].address);
  });

  it("🔨 Tokens should be minted ", async function () {
    expect(await ketchupContract.balanceOf(accounts[1].address)).to.equal(
      BigInt(1e20)
    );
  });

  it("🔥 Remaining token should be burnt", async function () {
    await ketchupContract.connect(accounts[1]).burnRemainingToken(BigInt(1e18));
    expect(await ketchupContract.balanceOf(accounts[1].address)).to.equal(
      BigInt(1e20 - 1e18)
    );
  });
});
