import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

import '../../abi/IAuctionInterface.abi.dart';

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  Rxn<BigInt> currentBidPrice = Rxn(BigInt.from(-1));
  Rxn<BigInt> auctionNo = Rxn(BigInt.from(-1));
  Rxn<int> auctionState = Rxn(-1);
  Rxn<BigInt> tokenPrice = Rxn(BigInt.from(-1));
  Rxn<BigInt> tokenSupply = Rxn(BigInt.from(-1));
  Rxn<BigInt> startTime = Rxn(BigInt.from(-1));
  Rx<int> countdownTimerInSeconds = Rx(0);

  TextEditingController bidAmountEditingController = TextEditingController();
  TextEditingController auctionAddressEditingController =
      TextEditingController();
  TextEditingController tokenAddressEditingController = TextEditingController();

  late Contract auctionContract;
  late ContractERC20 tokenContract;

  // Details for the admin
  Wallet? adminWallet;

  @override
  void onInit() {
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
  void onReady() async {
    super.onReady();
    fetchAuctionFromBlockchain();
  }

  fetchAuctionFromBlockchain() async {
    await fetchAuctionNo().then((_) {
      fetchAuctionState();
      fetchBidPrice();
      fetchTokenSupply();
    });

    await fetchAuctionStartTime().then((value) {
      if (value != null) {
        startTime.value = value;
        final deadline =
            calculateDeadline(startTime.value!.toInt(), kAuctionDuration);
        deadlineCountdown(
          deadline,
          countdownTimerInSeconds,
        );
      }
    });
  }

  // Reassign contract object with new instance
  updateAddress() async {
    if (auctionAddressEditingController.text.isNotEmpty) {
      auctionContract = Contract(
        auctionAddressEditingController.text,
        kAuctionInterfaceABI,
        provider!.getSigner(),
      );
    }
    if (tokenAddressEditingController.text.isNotEmpty) {
      tokenContract = ContractERC20(
        tokenAddressEditingController.text,
        provider!.getSigner(),
      );
    }
    fetchAuctionFromBlockchain();
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

  /// Return timestamp of auction start time
  Future<BigInt?> fetchAuctionStartTime() async {
    try {
      final value = await auctionContract.call<BigInt>("getAuctionStartTime");
      print("Auction start time: $value");
      return value;
    } catch (e) {
      print("error in fetching time: ${e.toString()}");
    }
    return null;
  }

  Future<void> fetchAuctionState() async {
    final value = await auctionContract.call<int>("getAuctionState");
    print("Auction State: ${value.toString()}");
    auctionState.value = value;
  }

  submitBid() async {
    final valueInWei = double.parse(bidAmountEditingController.text) * 1e18;
    try {
      final tx = await auctionContract.send(
        "insertBid",
        [],
        TransactionOverride(
          value: web3dart.EtherAmount.fromUnitAndValue(
            web3dart.EtherUnit.wei,
            valueInWei.toInt(),
          ).getInWei,
        ),
      );
      print("Tx hash: ${tx.hash}");
    } catch (e) {
      print("submit bid error: ${e.toString()}");
    }
  }

  Future<String> sendEther(
    String address,
  ) async {
    final tx = await provider!.getSigner().sendTransaction(
          TransactionRequest(
            to: address,
            value: BigInt.from(1000000000),
          ),
        );
    await tx.wait();
    print("Tx: ${tx.hash}");
    return tx.hash;
  }

  // * Token Contract Functions
  fetchTokenSupply() async {
    final value = await tokenContract.totalSupply;
    print("Token Supply: $value");
    tokenSupply.value = value;
  }

  // Calculate by adding startime + auction duration
  DateTime calculateDeadline(
    int auctionStartTime,
    int auctionDurationInMinutes,
  ) {
    final _deadline = DateTime.fromMillisecondsSinceEpoch(
      auctionStartTime * 1000,
      isUtc: true,
    ).add(
      Duration(minutes: auctionDurationInMinutes),
    );
    print("Deadline: ${_deadline.toString()}");
    return _deadline;
  }

  /// Calculate difference between deadline relative to current time
  Timer deadlineCountdown(
    DateTime deadline,
    Rx<int> countdownTimer,
  ) {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.isActive) {
        // Update countdown timer every 1 sec
        final _result = deadline.difference(DateTime.now());
        if (_result.inSeconds < 0) {
          timer.cancel();
        }
        countdownTimer.value = _result.inSeconds;
      }
    });
  }
}
