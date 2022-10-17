import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/abi/ikch_token_interface.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';
import 'package:web3dart/web3dart.dart' as web3dart;

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  Rx<String> currentBidPrice = Rx("0");
  Rx<int> auctionNo = Rx(-1);
  Rx<int> auctionState = Rx(-1);
  Rx<String> tokenPrice = Rx("-1");
  Rx<String> tokenTotalSupply = Rx("0");
  Rx<String> auctionTokenSupply = Rx("0");
  Rx<String> startTime = Rx("NIL");
  Rx<String> timeleft = Rx("0");
  Rx<String> userKCHBalance = Rx("0");
  Rx<bool> shouldHaveEnded = RxBool(true);

  TextEditingController bidAmountEditingController = TextEditingController();
  TextEditingController auctionAddressEditingController =
      TextEditingController();
  TextEditingController tokenAddressEditingController = TextEditingController();

  late IAuctionInterface auctionContract;
  late IKCHToken tokenContract;

  String auctionAddress = kAuctionContractAddress;
  String tokenAddress = kTokenAddress;
  Timer? countdownTimer;

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
    await fetchLatestAuction();
    await fetchAverageTokenPrice();
  }

  // * Getters

  void initTokenContract() =>
      tokenContract = IKCHToken(tokenAddress, provider!.getSigner());

  void initAuctionContract() => auctionContract = IAuctionInterface(
        auctionAddress,
        provider!.getSigner(),
      );

  /// Total supply bidded
  Future<void> fetchTokenSupply() async {
    final value = await tokenContract.totalSupply();
    tokenTotalSupply.value = bigIntToString(value);
  }

  /// Fetch KCH of given addreess
  Future<void> updateUserKCHBalance() async {
    final value = await tokenContract.balanceOf(userAddress.value);
    userKCHBalance.value = bigIntToString(value);
  }

  /// Fetch current auction no and show the state for it
  Future<void> fetchLatestAuction() async {
    clearTimer();
    await updateUserKCHBalance();
    await fetchAuctionNo();
    if (auctionNo.value == -1) return; // Auction has not start even once
    await fetchAuctionState();
    // Current action is active
    if (auctionState.value == 0) {
      startAuctionTime(await fetchAuctionStartTime());
      fetchBidPrice(auctionNo.value);
    }
  }

  /// Update countdown timer & stops at 0
  void startAuctionTime(BigInt? value) {
    if (value == null) {
      // Clear time
      startTime.value = "NIL";
      clearTimer();
      return;
    }

    startTime.value = convertTimestampToReadable(value.toInt());
    final now = DateTime.now();
    final start =
        DateTime.fromMillisecondsSinceEpoch(value.toInt(), isUtc: true);
    if (!now.difference(start).isNegative && value.toInt() > 0) {
      final deadline = calculateDeadline(value.toInt(), kAuctionDuration);
      countdownTimer = deadlineCounter(
        deadline,
        timeleft,
      );
    }
  }

  // Reassign contract object with new instance
  Future<void> updateAddress() async {
    if (auctionAddressEditingController.text.isNotEmpty) {
      auctionAddress = auctionAddressEditingController.text;
      initAuctionContract();
    }
    if (tokenAddressEditingController.text.isNotEmpty) {
      tokenAddress = tokenAddressEditingController.text;
      initTokenContract();
    }
    fetchLatestAuction();
  }

  Future<void> fetchAuctionNo() async {
    final value = await auctionContract.getAuctionNo();
    print("Auction No: $value");
    auctionNo.value = value.toInt();
  }

  set updateAuctionNo(int newAuctionNo) => auctionState.value = newAuctionNo;

  Future<void> fetchBidPrice(int auctionNo) async {
    final value = await auctionContract.getTokenPrice(auctionNo);
    print("Token price: $value");
    currentBidPrice.value = bigIntToString(value);
  }

  /// Able to withdraw if auction state == 1:CLOSED
  Future<void> withdrawTokens() async {
    await auctionContract.withdraw();
    await updateUserKCHBalance();
  }

  /// Return timestamp of auction start time
  Future<BigInt?> fetchAuctionStartTime() async {
    final value = await auctionContract.getAuctionStartTime();
    print("Auction start time: $value");
    return value;
  }

  Future<void> checkAuctionShouldEnd() async {
    final value = await auctionContract.checkIfAuctionShouldEnd();
    print("Object from checkIfAuctionShouldEnd: ${dartify(value)}");
    shouldHaveEnded.value = value;
    // return value;
  }

  Future<void> fetchAuctionState() async {
    final value = await auctionContract.getAuctionState();
    print("Auction State: ${value.toString()}");
    auctionState.value = value;
  }

  Future<void> fetchAverageTokenPrice() async {
    final result = await tokenContract.getAvgTokenPrice();
    print("average price: $result");
    tokenPrice.value = bigIntToString(result);
  }

  Future<BigInt> submitBid() async {
    final valueInWei = double.parse(bidAmountEditingController.text) * 1e18;
    try {
      final tx = await auctionContract.insertBid(BigInt.from(valueInWei));
      print("Tx hash: ${tx?.hash}");
      bidAmountEditingController.clear();
    } catch (e) {
      print("submit bid error: ${e.toString()}");
    }
    return BigInt.from(valueInWei);
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

  /// Total supply for all auction
  void fetchAuctionTokenSupply() async {
    print("getAuctionSupply()");
    final value = await auctionContract.getAuctionSupply();
    print("getAuctionSupply(): $value");
    auctionTokenSupply.value = bigIntToString(value);
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

  /// Update countdowntimer with deadline
  Timer deadlineCounter(
    DateTime deadline,
    Rx<String> countdownTimer,
  ) {
    return Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (timer.isActive) {
        // Update countdown timer every 1 sec
        final _result = deadline.difference(DateTime.now());
        if (_result.inSeconds < 0) {
          countdownTimer.value = "Time's Up";
          timer.cancel();
        } else {
          countdownTimer.value = _countdownHandler(_result.inSeconds);
        }
      }
    });
  }

  void clearTimer() {
    timeleft.value = "0";
    if (countdownTimer == null) return;
    if (countdownTimer!.isActive) {
      countdownTimer!.cancel();
    }
  }

  String _countdownHandler(int seconds) {
    if (seconds > 59 || seconds < -59) {
      return "${(seconds / 60).round()} mins ${(seconds % 60.round())} seconds";
    } else {
      return "$seconds seconds";
    }
  }
}
