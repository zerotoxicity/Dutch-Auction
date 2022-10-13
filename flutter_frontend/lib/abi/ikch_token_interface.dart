import 'package:flutter_web3/flutter_web3.dart';

class IKCHToken {
  late ContractERC20 contract;

  IKCHToken(String address, dynamic provider) {
    contract = ContractERC20(address, provider);
  }

  // Extends functionality

  Future<void> fundAuction() async {
    final result = await callFn("fundAuction");
    print("result: $result");
  }

  Future<void> burnRemainingToken(BigInt amount) async {
    final result = await callFn(
        "burnRemainingToken", [TransactionOverride(value: amount)]);
    print("result: $result");
  }

  Future<BigInt> getAvgTokenPrice() async =>
      await callFn<BigInt>("getAvgTokenPrice");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    late T result;
    try {
      print("call fn:$fnName ");
      result = await contract.contract.call(fnName, a);
    } catch (e) {
      print("error $fnName: ${e.toString()}");
    }
    return result;
  }
}
