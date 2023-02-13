import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/abi/ikch_token_interface.dart';
import 'package:flutter_frontend/helper.dart' as helper;
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

/// @note Right now we're only interested in localchain 1337 id
class AuctionController extends GetxController {
  Rx<String> currentBidPrice = Rx("-1");
  Rx<int> auctionNo = Rx(-1);
  Rx<int> auctionState = Rx(-1);
  Rx<String> tokenPrice = Rx("-1");
  Rx<String> tokenTotalSupply = Rx("-1");
  Rx<String> supplyReserved = Rx("-1");
  Rx<String> auctionTokenSupply = Rx("-1");
  Rxn<DateTime> startTime = Rxn();
  Rx<String> startTimeString = Rx("NIL");
  Rxn<DateTime> endTime = Rxn();
  Rx<String> endTimeString = Rx("NIL");
  Rx<int> secondsLeft = Rx(0);
  Rx<String> timeLeftString = Rx("-1");
  Rx<String> userKCHBalance = Rx("-1");
  Rx<bool> shouldHaveEnded = RxBool(true);

  TextEditingController bidAmountEditingController = TextEditingController();

  late IAuctionInterface auctionContract;
  late IKCHToken tokenContract;

  String auctionAddress = helper.kAuctionContractAddress;
  String tokenAddress = helper.kTokenAddress;
  Timer? auctionBackgroundTimer;
  Timer? backgroundTimer;

  /// In seconds
  Duration auctionDuration = const Duration(seconds: 300);

  // Details for the admin
  Rx<String> userAddress = Rx("");

  @override
  void onInit() {
    super.onInit();
    provider!
        .getSigner()
        .getAddress()
        .then((value) => userAddress.value = value);
    initTokenContract();
    initAuctionContract();
  }

  @override
  void onReady() async {
    super.onReady();
    await fetchTokenSupply();
    await fetchAverageTokenPrice();

    await refreshAuctionState();

    startGlobalBackgroundAction();

    auctionState.listen((p0) {
      if (p0 != 0) {
        // cancel timer
        clearAuctionTimer();
      }
    });

    ever(
      secondsLeft,
      (int seconds) {
        //print("Tick... $seconds");
        timeLeftString.value = viewTimeLeft(seconds);
      },
      // condition: secondsLeft.value >= -1,
    );
  }

  @override
  void onClose() {
    super.onClose();
    backgroundTimer?.cancel();
    auctionBackgroundTimer?.cancel();
  }
  // * Getters

  void initTokenContract() =>
      tokenContract = IKCHToken(tokenAddress, provider!.getSigner());

  void initAuctionContract() {
    auctionContract = IAuctionInterface(
      auctionAddress,
      provider!.getSigner(),
    );
    auctionContract.contract.on("ShouldAuctionEnd", (result, object) {
      print("<ShouldAuctionEnd Listener>: $result -- ${dartify(object)}");
      if (result is bool && result) {
        shouldHaveEnded.value = result;
        if (result) {
          auctionState.value = 1; // Close
        } else {
          auctionState.value = 0; // Active
        }
        refreshAuctionState();
      }
    });
    auctionContract.contract.on("Receiving", (result, object) {
      result = dartify(result);
      print("<Receiving Listener>: $result");
      updateUserKCHBalance().then((value) {
        if (value == null) return;
        GetSnackBar(
          title: "KCH Received",
          message: helper.bigIntToString(value),
          duration: const Duration(seconds: 3),
        ).show();
      });
    });
  }

  /// Total supply bidded
  Future<void> fetchTokenSupply() async {
    final value = await tokenContract.totalSupply();
    tokenTotalSupply.value = helper.bigIntToString(value);
  }

  // Future<void> fetchAuctionDuration() async {
  //   final int _seconds = (await auctionContract.viewAuctionDuration()).toInt();
  //   auctionDuration = Duration(seconds: _seconds);
  // }

  /// Fetch KCH of given addreess
  Future<BigInt?> updateUserKCHBalance() async {
    final value = await tokenContract.balanceOf(userAddress.value);
    userKCHBalance.value = helper.bigIntToString(value);
    return value;
  }

  /// View only: Fetch auction state based on latest auction no
  Future<void> refreshAuctionState() async {
    clearAuctionTimer();
    await fetchAuctionNo();
    if (auctionNo.value == -1) return;
    // Auction has not start even once
    await fetchAuctionState();
    print(
        "Current Auction No: ${auctionNo.value}, Auction State: ${auctionState.value}");
    if (auctionState.value == 0) {
      await fetchBidPrice(auctionNo.value);
      await fetchAuctionTokenSupply();
      await fetchReserved();
      await fetchStartEndTime(auctionNo.value);
      // Create a new auction background timer
      startAuctionBackgroundAction();
    }
  }

  /// Fetch start time, end time & auction duration
  /// Trigger countdown
  Future<void> startAuction() async {
    await fetchAuctionState();
    await fetchAuctionNo();
    // Show start time
    await fetchStartEndTime(auctionNo.value);
    if (startTime.value == null) {
      // Auction not started yet
      clearAuctionTimer();
      return;
    }

    startAuctionBackgroundAction();
  }

  /// Run background functions periodically
  /// * Average Token Price
  /// * Total Token Supply
  void startGlobalBackgroundAction() {
    backgroundTimer = Timer.periodic(
        const Duration(seconds: helper.kBackgroundPeriod), (timer) {
      fetchAverageTokenPrice();
      fetchTokenSupply();
    });
  }

  /// Run background action for current active auction
  /// * Bid Price
  /// * Auction State
  void startAuctionBackgroundAction() {
    // Clear previous counter if exists
    auctionBackgroundTimer?.cancel();

    auctionBackgroundTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      if (timer.isActive) {
        fetchBidPrice(auctionNo.value);
        fetchAuctionState();
        secondsLeft.value--;
      }
      if (secondsLeft.value < 0) {
        // Should only be called once in a single instance
        timer.cancel();
        auctionBackgroundTimer?.cancel();
      }
    });
  }

  /// Calculate & update the start & end time of auction (based on given auction no)
  Future<void> fetchStartEndTime(int auctionNo) async {
    print("fetchStartEndTime()");
    BigInt? _st = BigInt.from(0);
    try {
      _st = await auctionContract.getAuctionStartTime(auctionNo);
    } catch (e) {
      helper.debugPrint("error: ${e.toString}");
    }

    print("start time (int): ${_st?.toInt()}");

    if (_st?.toInt() == 0) return; // Auction not started yet

    final _durationInSeconds = await auctionContract.viewAuctionDuration();

    // Calculate start and end time of current auction
    startTime.value = DateTime.fromMillisecondsSinceEpoch(
      _st!.toInt() * 1000,
      isUtc: true,
    );
    endTime.value = startTime.value!.add(
      Duration(
        seconds: _durationInSeconds.toInt(),
      ),
    );

    startTimeString.value = helper
        .convertTimestampToReadable(startTime.value!.millisecondsSinceEpoch);
    endTimeString.value = helper
        .convertTimestampToReadable(endTime.value!.millisecondsSinceEpoch);

    secondsLeft.value =
        calculateTimeLeft(endTime.value!.millisecondsSinceEpoch);

    print(
        "Auction start time: ${startTimeString.value}, end time: ${endTimeString.value}. \n Time left: ${secondsLeft.value}");

    GetSnackBar(
      title: "Auction Details",
      message:
          "Started: ${startTimeString.value}, ending: ${endTimeString.value}",
      duration: const Duration(seconds: 3),
    ).show();
  }

  /// Fetch end time
  /// Returns `< 0` if exceed else returns number of seconds left
  int calculateTimeLeft(int deadlineTimetamp) {
    endTime.value = DateTime.fromMillisecondsSinceEpoch((deadlineTimetamp));
    return endTime.value!.difference(DateTime.now().toUtc()).inSeconds;
  }

  // Reassign contract object with new instance
  void updateContractAddress({
    String? newTokenAddress,
    String? newAuctionAddress,
  }) async {
    if (newTokenAddress != null) {
      tokenAddress = newTokenAddress;
      tokenContract.updateContract(tokenAddress);
    }

    if (newAuctionAddress != null) {
      auctionAddress = newAuctionAddress;
      auctionContract.updateContract(auctionAddress);
    }

    refreshAuctionState();
  }

  Future<void> fetchAuctionNo() async {
    final value = await auctionContract.getAuctionNo();
    auctionNo.value = value.toInt();
  }

  set updateAuctionNo(int newAuctionNo) => auctionState.value = newAuctionNo;

  Future<void> fetchBidPrice(int auctionNo) async {
    final value = await auctionContract.getTokenPrice(auctionNo);
    debugPrint("Token price: $value");
    currentBidPrice.value = helper.bigIntToString(value, fractions: 8);
  }

  Future<void> fetchReserved() async {
    final value = await auctionContract.getSupplyReserved();
    supplyReserved.value =
        helper.bigIntToString(value) + " / " + auctionTokenSupply.value;
  }

  /// Able to withdraw if auction state == 1:CLOSED
  Future<void> withdrawTokens() async {
    await auctionContract.withdraw();
  }

  Future<void> checkAuctionShouldEnd() async {
    final value = await auctionContract.checkIfAuctionShouldEnd();
    print("Object from checkIfAuctionShouldEnd: ${dartify(value)}");
    // return value;
  }

  Future<void> fetchAuctionState() async {
    final value = await auctionContract.getAuctionState();
    // print("Auction State: ${value.toString()}");
    auctionState.value = value;
  }

  Future<void> fetchAverageTokenPrice() async {
    final result = await tokenContract.getAvgTokenPrice();
    // print("Average Token Price: ${result.toInt()}");
    tokenPrice.value = helper.bigIntToString(result);
  }

  Future<BigInt> submitBid() async {
    final valueInWei = double.parse(bidAmountEditingController.text) * 1e18;
    try {
      final tx = await auctionContract.insertBid(BigInt.from(valueInWei));
      print("Tx hash: ${tx?.hash}");
      bidAmountEditingController.clear();
    } catch (e) {
      print("submit bid error: ${e.toString()}");
      return BigInt.zero;
    }
    return BigInt.from(valueInWei);
  }

  /// @deprecated - not in used
  Future<String> sendEther(String address) async {
    final tx = await provider!.getSigner().sendTransaction(
          TransactionRequest(
            to: address,
            value: BigInt.from(1000000000),
          ),
        );
    await tx.wait(helper.kConfirmationBlocks);
    print("Tx: ${tx.hash}");
    return tx.hash;
  }

  /// Total supply for current auction
  Future<void> fetchAuctionTokenSupply() async {
    final value = await auctionContract.getAuctionSupply();
    print("getAuctionSupply(): $value");
    auctionTokenSupply.value = helper.bigIntToString(value);
  }

  /// Remove any active background auction timer
  void clearAuctionTimer() {
    timeLeftString.value = "0";
    auctionBackgroundTimer?.cancel();
  }

  String viewTimeLeft(int seconds) {
    if (seconds < 0) {
      return "Auction Not Available";
    }
    if (seconds > 59 || seconds < -59) {
      return "${(seconds / 60).floor()} mins ${(seconds % 60.round())} seconds";
    } else {
      return "$seconds seconds";
    }
  }
}
