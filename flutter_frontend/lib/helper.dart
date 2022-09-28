// Helper Functions

/// Converts bigint to readable of 5 decimal place precision
/// e.g. 0.20000
String bigIntToInt(BigInt bi) {
  return (bi.toDouble() / 1e18).toStringAsPrecision(5);
}
