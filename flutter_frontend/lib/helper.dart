// Helper Functions

/// Converts bigint to readable of 5 decimal place precision
/// e.g. 0.20000
String bigIntToString(BigInt bi, {placement = 1e18}) {
  assert(placement > 1, "must be more than 1");
  return (bi.toDouble() / placement).toStringAsFixed(4);
}

const String kChainlinkGoerliAddress =
    "0xA39434A63A52E749F02807ae27335515BA4b07F7";

const String kKetchUpToken = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const String kAuctionContract = "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";
