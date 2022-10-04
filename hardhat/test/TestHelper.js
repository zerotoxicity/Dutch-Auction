const AUCTION_SUPPLY = BigInt(1e20);
const BURN_AMOUNT = BigInt(1e19);

// Deploy upgradeable contracts
async function deployContract(contractName, args) {
  const contractFactory = await ethers.getContractFactory(contractName);
  const contract = await upgrades.deployProxy(contractFactory, args, {
    kind: "uups",
  });
  return contract;
}

// Fast forward time by 20 minutes
async function fastForwardTwentyMins() {
  await ethers.provider.send("evm_increaseTime", [60 * 60 * 20]);
  await ethers.provider.send("evm_mine");
}

function notZero(x) {
  return x !== 0;
}

module.exports = {
  AUCTION_SUPPLY,
  BURN_AMOUNT,
  deployContract,
  fastForwardTwentyMins,
  notZero,
};
