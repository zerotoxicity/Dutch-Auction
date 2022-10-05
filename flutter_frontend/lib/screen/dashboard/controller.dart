import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/contract_interface/auction_interface.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart';

import '../../abi/IAuctionInterface.abi.dart';

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  Rxn<BigInt> currentBidPrice = Rxn(BigInt.from(-1));
  Rxn<BigInt> auctionNo = Rxn(BigInt.from(-1));
  Rxn<int> auctionState = Rxn(-1);
  Rxn<BigInt> tokenPrice = Rxn(BigInt.from(-1));
  Rxn<BigInt> tokenSupply = Rxn(BigInt.from(-1));

  TextEditingController textEditingController = TextEditingController();

  late Contract auctionContract;

  late ContractERC20 tokenContract;

  @override
  void onInit() async {
    provider!
        .getSigner()
        .getAddress()
        .then((value) => print("Wallet Address: $value"));

    super.onInit();
    auctionContract = Contract(
      kAuctionContractAddress,
      kAuctionInterfaceABI,
      provider!.getSigner(),
    );

    tokenContract = ContractERC20(kTokenAddress, provider!.getSigner());
  }

  @override
  void onReady() {
    super.onReady();

    fetchAuctionNo().then((_) {
      fetchAuctionState();
      fetchBidPrice();
    });
  }

  Future<void> fetchAuctionNo() async {
    final value = await auctionContract.call<BigInt>("getAuctionNo");
    print("Auction No: $value");
    auctionNo.value = value;
  }

  fetchBidPrice() async {
    final value = await auctionContract.call<BigInt>(
      "getTokenPrice",
      [auctionNo.value],
    );

    print("Token price: $value");

    currentBidPrice.value = value;
  }

  Future<void> fetchAuctionState() async {
    final value = await auctionContract.call<int>("getAuctionState");
    print("Auction State: ${value.toString()}");
    auctionState.value = value;
  }

  submitBid() async {
    final valueInWei = double.parse(textEditingController.text) * 1e18;
    try {
      final tx = await auctionContract.send(
        "insertBid",
        [],
        TransactionOverride(
          value: EtherAmount.fromUnitAndValue(
            EtherUnit.wei,
            valueInWei.toInt(),
          ).getInWei,
        ),
      );
      print("Tx hash: ${tx.hash}");
    } catch (e) {
      print("submit bid error: ${e.toString()}");
    }
  }

  // * Token Contract Functions
  fetchTokenSupply() async {
    final value = await tokenContract.totalSupply;
    print("Token Supply: $value");
    tokenSupply.value = value;
  }
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
