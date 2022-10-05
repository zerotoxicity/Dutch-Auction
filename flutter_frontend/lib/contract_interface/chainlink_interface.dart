import 'dart:convert';

import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';

/// Contracts related to chainlink
class AggregatorV3Interface {
  String contractAddress;
  late Contract _contract;

  /// Initialise with contract address, abi, provider
  AggregatorV3Interface(
      {required this.contractAddress, required abi, required provider}) {
    _contract = Contract(contractAddress, abi, provider);
  }

  Future<String> fetchBTCToUSD() async {
    return await _contract.call("latestRoundData").then((result) {
      print("Runtime type: ${result.runtimeType} | Result: $result");
      return bigIntToString((result[1] as BigNumber).toBigInt, placement: 1e8);
    });
  }
}
