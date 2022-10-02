const AUCTION_SUPPLY = BigInt(1e20);
const BURN_AMOUNT = BigInt(1e19);

async function deployKetchupContract() {
  const KetchupTokenV1 = await ethers.getContractFactory("KetchupTokenV1");
  ketchupContract = await upgrades.deployProxy(
    KetchupTokenV1,
    ["Ketchup", "KCH"],
    {
      kind: "uups",
    }
  );
  return ketchupContract;
}

async function deployIterableMapping() {
  const iterableMappingFactory = await ethers.getContractFactory(
    "IterableMapping"
  );
  const iterableMappingContract = await iterableMappingFactory.deploy();
  return iterableMappingContract;
}

async function fastForwardTwentyMins() {
  //Fast forward time by 20 minutes
  await ethers.provider.send("evm_increaseTime", [60 * 60 * 20]);
  await ethers.provider.send("evm_mine");
}

function notZero(x) {
  return x !== 0;
}

module.exports = {
  AUCTION_SUPPLY,
  BURN_AMOUNT,
  deployKetchupContract,
  deployIterableMapping,
  fastForwardTwentyMins,
  notZero,
};
