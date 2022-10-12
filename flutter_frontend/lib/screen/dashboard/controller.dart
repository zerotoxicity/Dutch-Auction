import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

import '../../abi/IAuctionInterface.abi.dart';

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  Rx<String> currentBidPrice = Rx("0");
  Rx<BigInt> auctionNo = Rx(BigInt.from(-1));
  Rx<int> auctionState = Rx(-1);
  Rx<BigInt> tokenPrice = Rx(BigInt.from(-1));
  Rx<String> tokenSupply = Rx("0");
  Rx<String> startTime = Rx("");
  Rx<String> countdownTimerInSeconds = Rx("0");
  Rx<String> userKCHBalance = Rx("0");
  Rx<bool> shouldHaveEnded = RxBool(true);

  TextEditingController bidAmountEditingController = TextEditingController();
  TextEditingController auctionAddressEditingController =
      TextEditingController();
  TextEditingController tokenAddressEditingController = TextEditingController();

  late Contract auctionContract;
  late ContractERC20 tokenContract;

  // Details for the admin
  Rx<String> userAddress = Rx("");

  @override
  void onInit() {
    provider!
        .getSigner()
        .getAddress()
        .then((value) => userAddress.value = value);

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
    refreshAuctionState();
    auctionContract.on("ShouldAuctionEnd", (shouldEnded, a) {
      print("Listener<ShouldAuctionEnd>: $shouldEnded, ${dartify(a)}");
      shouldHaveEnded.value = shouldEnded;
    });
    auctionContract.on("Receiving", (amount, a) {
      print("Listener<Receiving>: $amount, ${dartify(a)}");
    });
  }

  Future<void> refreshAuctionState() async {
    await fetchAuctionNo().then((_) {
      fetchAuctionState();
      fetchBidPrice();
      fetchTokenSupply();
    });
    await fetchAuctionStartTime().then((value) {
      if (value != null) {
        startTime.value = _convertTimestampToReadable(value.toInt());
        final now = DateTime.now();

        final start =
            DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);

        if (!now.difference(start).isNegative && value.toInt() > 0) {
          final deadline = calculateDeadline(value.toInt(), kAuctionDuration);
          deadlineCountdown(
            deadline,
            countdownTimerInSeconds,
          );
        }
      }
    });
  }

  // Reassign contract object with new instance
  Future<void> updateAddress() async {
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
    refreshAuctionState();
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
    currentBidPrice.value = bigIntToString(value);
  }

  Future<void> withdrawTokens() async {
    print("withdrawing...");
    await auctionContract.call("withdraw");

    print("withdraw down");
  }

  /// Fetch KCH of given addreess
  Future<void> updateUserKCHBalance() async {
    final value = await tokenContract.balanceOf(userAddress.value);
    print("user balance: ${value.toInt()}");
    userKCHBalance.value = bigIntToString(value);
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

  Future<bool> checkAuctionShouldEnd() async {
    print("call checkAuctionShouldEnd");
    final value = await auctionContract.call("checkIfAuctionShouldEnd");
    print("Object from checkIfAuctionShouldEnd: ${dartify(value)}");
    return shouldHaveEnded.value;
  }

  Future<void> fetchAuctionState() async {
    final value = await auctionContract.call<int>("getAuctionState");
    print("Auction State: ${value.toString()}");
    auctionState.value = value;
  }

  Future<BigInt> submitBid() async {
    final valueInWei = double.parse(bidAmountEditingController.text) * 1e18;
    BigInt bidAmount = web3dart.EtherAmount.fromUnitAndValue(
      web3dart.EtherUnit.wei,
      valueInWei.toInt(),
    ).getInWei;
    try {
      final tx = await auctionContract.send(
        "insertBid",
        [],
        TransactionOverride(value: bidAmount),
      );
      print("Tx hash: ${tx.hash}");
      bidAmountEditingController.clear();
    } catch (e) {
      print("submit bid error: ${e.toString()}");
    }
    return bidAmount;
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
  void fetchTokenSupply() async {
    final value = await tokenContract.totalSupply;
    print("Token Supply: $value");
    // TODO: add a supply converter
    tokenSupply.value = bigIntToString(value);
  }

  // Calculate by adding startime + auction duration
  DateTime calculateDeadline(
    int auctionStartTime,
    int auctionDurationInMinutes,
  ) {
    final _deadline = DateTime.fromMillisecondsSinceEpoch(
      auctionStartTime * 1000,
      isUtc: true,
    ).add(Duration(minutes: auctionDurationInMinutes));
    print("Deadline: ${_deadline.toString()}");
    return _deadline;
  }

  /// Calculate difference between deadline relative to current time
  Timer deadlineCountdown(
    DateTime deadline,
    Rx<String> countdownTimer,
  ) {
    return Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.isActive) {
        // Update countdown timer every 1 sec
        final _result = deadline.difference(DateTime.now());
        if (_result.inSeconds < 0) {
          countdownTimer.value = "0";
          timer.cancel();
        } else {
          countdownTimer.value = _countdownHandler(_result.inSeconds);
        }
      }
    });
  }

  String _countdownHandler(int seconds) {
    if (seconds > 59 || seconds < -59) {
      return "${(seconds / 60).round()} mins ${(seconds % 60.round())} seconds";
    } else {
      return "$seconds seconds";
    }
  }

  /// Convert timestamp to human readable string
  String _convertTimestampToReadable(int timestamp) {
    print("Debug start time: $timestamp");
    if (timestamp <= 0) return "not available";
    final _dt =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return "${_dt.day}/${_dt.month}/${_dt.year}";
  }
}
