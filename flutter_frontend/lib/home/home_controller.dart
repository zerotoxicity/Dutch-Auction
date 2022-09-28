import 'dart:async';

import 'package:flutter_frontend/abi/chainlink_abi.dart';
import 'package:flutter_frontend/contract/chainlink_contract.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  late AggregatorV3Interface aggregatorV3Interface;
  RxString btcToUSD = "".obs;
  @override
  void onInit() {
    super.onInit();
    aggregatorV3Interface = AggregatorV3Interface(
      contractAddress: chainlinkGoerliAddress,
      abi: Interface(aggregatorV3InterfaceABI),
      provider: Get.find<Web3Controller>().getProvider,
    );

    Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (timer.isActive) {
        String _result = await aggregatorV3Interface.fetchBTCToUSD();
        btcToUSD.value = _result;
      }
    });
  }
}
