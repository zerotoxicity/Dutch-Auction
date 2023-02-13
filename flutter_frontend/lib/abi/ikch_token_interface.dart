import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';

import 'ikch_token_interface.abi.dart';

class IKCHToken {
  late Contract contract;
  late dynamic abi;
  late dynamic provider;

  IKCHToken(
    String address,
    this.provider, {
    this.abi = kIKetchUpTokenABI,
  }) {
    contract = Contract(address, abi, provider);
  }

  // Extends functionality

  updateContract(
    String address,
  ) {
    contract = Contract(address, abi, provider);
  }

  Future<void> fundAuction() async {
    final result = await callFn("fundAuction");
    print("result: $result");
  }

  // Future<void> burnRemainingToken(BigInt amount) async {
  //   try {
  //     final tx = await contract.send(
  //       "burnRemainingToken",
  //       [amount],
  //       TransactionOverride(gasLimit: BigInt.from(21000 * 2)),
  //     );
  //     print("tx: ${tx.hash}");
  //     final receipt = await tx.wait(kBlockConfirmation);
  //     print("receipt: ${receipt.transactionHash}");
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  Future<BigInt> totalSupply() async {
    return contract.call("totalSupply");
  }

  Future<BigInt> balanceOf(String address) async {
    return await callFn("balanceOf", [address]);
  }

  Future<BigInt> getAvgTokenPrice() async =>
      await callFn<BigInt>("getAvgTokenPrice");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    // print("$fnName() called");
    return await contract.call(fnName, a);
  }
}
