const { ethers } = require("hardhat");
const { deployContract } = require("../test/TestHelper");

async function main() {
  console.log("⏳ Deploying..");
  ketchupContract = await deployContract("KetchupTokenV1", ["Ketchup", "KCH"]);

  auctionContract = await deployContract("AuctionV1", [
    ketchupContract.address,
  ]);
  await ketchupContract.transferOwnership(auctionContract.address);
  console.log("✅ Deployed!");
  console.log(
    `💰 Ketchup Token contract is deployed to ${ketchupContract.address}`
  );
  console.log(`📝 Auction contract is deployed to ${auctionContract.address}`);

  await auctionContract.startAuction().then(() => {
    console.log("Started Auction");
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
