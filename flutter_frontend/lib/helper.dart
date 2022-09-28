// Helper Functions

/// Converts bigint to readable of 5 decimal place precision
/// e.g. 0.20000
String bigIntToString(BigInt bi, {placement = 1e18}) {
  assert(placement > 1, "must be more than 1");
  return (bi.toDouble() / placement).toStringAsFixed(4);
}

const String chainlinkGoerliAddress =
    "0xA39434A63A52E749F02807ae27335515BA4b07F7";
