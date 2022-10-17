import 'package:flutter_web3/flutter_web3.dart';

import 'ikch_token_interface.abi.dart';

class IKCHToken {
  late Contract contract;

  IKCHToken(
    String address,
    dynamic provider, {
    dynamic abi,
  }) {
    contract = Contract(address, abi ?? kIKetchUpTokenABI, provider);
  }

  // Extends functionality

  Future<void> fundAuction() async {
    final result = await callFn("fundAuction");
    print("result: $result");
  }

  Future<void> burnRemainingToken(BigInt amount) async {
    try {
      final tx = await contract.send(
        "burnRemainingToken",
        [amount],
        TransactionOverride(gasLimit: BigInt.from(21000 * 2)),
      );
      print("tx: ${tx.hash}");
      final receipt = await tx.wait();
      print("receipt: ${receipt.transactionHash}");
    } catch (e) {
      print(e.toString());
    }
  }

  Future<BigInt> totalSupply() async {
    return contract.call("totalSupply");
  }

  Future<BigInt> balanceOf(String address) async {
    return await callFn("balanceOf", [address]);
  }

  Future<BigInt> getAvgTokenPrice() async =>
      await callFn<BigInt>("getAvgTokenPrice");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    print("$fnName() called");
    return await contract.call(fnName, a);
  }
}
