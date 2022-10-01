const AUCTION_SUPPLY = BigInt(1e19);
const BURN_AMOUNT = BigInt(1e18);

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

module.exports = {
  AUCTION_SUPPLY,
  BURN_AMOUNT,
  deployKetchupContract,
  deployIterableMapping,
};
