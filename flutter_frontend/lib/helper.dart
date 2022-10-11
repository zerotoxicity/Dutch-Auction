// Helper Functions

/// Converts bigint to readable of 5 decimal place precision
/// e.g. 0.20000
String bigIntToString(BigInt bi, {placement = 1e18}) {
  assert(placement > 1, "must be more than 1");
  return (bi.toDouble() / placement).toStringAsFixed(4);
}

const String kChainlinkGoerliAddress =
    "0xA39434A63A52E749F02807ae27335515BA4b07F7";

const String kTokenAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const String kAuctionContractAddress =
    "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

const String kRPCURL = "http://127.0.0.1:8545/";

const Map<int, String> kAuctionState = {
  -1: "NOT FOUND",
  0: "ONGOING",
  1: "CLOSED",
  2: "CLOSING",
};

const int kAuctionDuration = 20;

const privateKey01 =
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";
