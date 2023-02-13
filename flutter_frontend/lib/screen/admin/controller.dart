// Admin Controller for Web3

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/abi/ikch_token_interface.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';

import 'package:flutter_web3/flutter_web3.dart';
import "package:flutter_web3/ethers.dart";
import 'package:get/get.dart';

/// @dev We assume the contract is deployed and using the same account to do other operations
class AdminController extends GetxController {
  RxBool isLogin = false.obs;
  Rx<String> walletAddress = "".obs;
  Rx<String> etherBalance = Rx("0");
  Rx<String> kchBalance = Rx("0");
  Rx<int> auctionDuration = Rx<int>(0);
  Rx<String> kchSupply = Rx("0");
  Rx<int> auctionStartTime = Rx(-1);

  Wallet? adminWallet;
  IAuctionInterface? auctionContract;
  IKCHToken? tokenContract;

  late IKCHToken kchToken;

  TextEditingController privateKeyEditingController = TextEditingController();
  TextEditingController contractEditingController = TextEditingController();
  Timer? backgroundTimer;

  @override
  void onReady() async {
    super.onReady();
    await addWallet(kPrivateKey);
    initAuctionContract();
    initTokenContract();
    initKCHTokenContract();
    await fetchEtherBalance();
    await fetchKCHBalance();

    startBackgroundAction();
  }

  @override
  void onClose() {
    super.onClose();
    backgroundTimer?.cancel();
  }

  Future<void> addWallet(String privateKey) async {
    // Assume text is not empty
    adminWallet = Wallet(privateKey).connect(JsonRpcProvider());

    // Connect to localhost
    walletAddress.value = await adminWallet!.getAddress();
    isLogin.value = true;
  }

  void initKCHTokenContract() async {
    final _tokenAddress = Get.find<AuctionController>().tokenAddress;
    kchToken = IKCHToken(_tokenAddress, adminWallet);
  }

  void initAuctionContract() {
    final _auctionAddress = Get.find<AuctionController>().auctionAddress;

    auctionContract = IAuctionInterface(_auctionAddress, adminWallet);
    print("auction contract address: $_auctionAddress");
  }

  void initTokenContract() {
    final _tokenAddress = Get.find<AuctionController>().tokenAddress;
    print("token contract address: $_tokenAddress");
    tokenContract = IKCHToken(_tokenAddress, provider);
  }

  Future<void> fetchEtherBalance() async {
    if (adminWallet == null) return;
    final ether = await adminWallet!.getBalance();
    etherBalance.value = bigIntToString(ether);
  }

  Future<void> fetchKCHBalance() async {
    if (tokenContract == null) return;
    final kch = await tokenContract!.balanceOf(walletAddress.value);
    kchBalance.value = bigIntToString(kch);
  }

  Future<void> fetchTokenSupply() async {
    final _totalSupply = await kchToken.totalSupply();
    kchSupply.value = bigIntToString(_totalSupply);
  }

  Future<String?> startAuction() async {
    if (auctionContract == null) return null;
    print("start auction");
    final result = await auctionContract!.startAuction();
    print("await block confirmation...");
    final receipt = await result.wait(1);
    print("$kConfirmationBlocks blocks confirmed");
    return receipt.transactionHash;
  }

  /// Background task to update active auction state periodically
  void startBackgroundAction() {
    print("AdminController: Start background action");
    backgroundTimer = Timer.periodic(
        Duration(seconds: (kBackgroundPeriod * 1.5).ceil()), (timer) async {
      fetchEtherBalance();
      final _state = await auctionContract?.getAuctionState();
      if (_state == 0) {
        auctionContract?.checkIfAuctionShouldEnd();
      }
    });
  }

  void updateContractAddress({
    String? newTokenAddress,
    String? newAuctionAddress,
  }) async {
    if (newTokenAddress != null) {
      newTokenAddress;
      tokenContract!.updateContract(newTokenAddress);
    }

    if (newAuctionAddress != null) {
      auctionContract!.updateContract(newAuctionAddress);
    }
  }
}
