import 'dart:async';

import 'package:flutter_frontend/abi/Chainlink.abi.dart';
import 'package:flutter_frontend/contract_interface/auction_interface.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  Rxn<BigInt> tokenPrice = Rxn(BigInt.zero);
  late AuctionInterface auctionInterface;
  RxString chainId = "".obs;

  @override
  void onInit() {
    super.onInit();
    auctionInterface = AuctionInterface(auctionAddress: kAuctionContract, abi: Interface(), provider: provider)
  }

  // Handle display value based on chainId

}

// void fetchBTCPrice() {
//   aggregatorV3Interface = AggregatorV3Interface(
//     contractAddress: kChainlinkGoerliAddress,
//     abi: Interface(aggregatorV3InterfaceABI),
//     provider: Get.find<Web3Controller>().getProvider,
//   );

//   Timer.periodic(const Duration(seconds: 10), (timer) async {
//     if (timer.isActive) {
//       String _result = await aggregatorV3Interface.fetchBTCToUSD();
//       btcToUSD.value = _result;
//     }
//   });
// }
