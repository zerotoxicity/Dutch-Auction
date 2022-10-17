// Admin Controller for Web3

import 'package:flutter/material.dart';
import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/abi/ikch_token_interface.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:flutter_web3/flutter_web3.dart';
import "package:flutter_web3/ethers.dart";
import 'package:get/get.dart';

/// @dev We assume the contract is deployed and using the same account to do other operations
class AdminController extends GetxController {
  RxBool isLogin = false.obs;
  Rx<String> walletAddress = "".obs;
  Rx<String> etherBalance = Rx("0");
  Rx<String> kchBalance = Rx("0");

  Wallet? adminWallet;
  IAuctionInterface? auctionContract;
  ContractERC20? tokenContract;

  late IKCHToken kchToken;

  TextEditingController privateKeyEditingController = TextEditingController();
  TextEditingController contractEditingController = TextEditingController();

  @override
  void onReady() async {
    super.onReady();
    // once(adminWallet.obs, (Wallet? wallet) {
    //   if (wallet != null) {
    //     initTokenContract();
    //     initAuctionContract();
    //   }
    // }, condition: adminWallet != null);
    await addWallet(kPrivateKey);
    initAuctionContract();
    initTokenContract();
    fetchEtherBalance();
    fetchKCHBalance();
    await initKCHTokenContract();
  }

  Future<void> addWallet(String privateKey) async {
    // Assume text is not empty
    adminWallet = Wallet(privateKey).connect(JsonRpcProvider());

    // Connect to localhost
    walletAddress.value = await adminWallet!.getAddress();
    isLogin.value = true;
  }

  Future<void> deployContract() async {}

  Future<void> initKCHTokenContract() async {
    final _tokenAddress = Get.find<DashboardController>().tokenAddress;
    kchToken = IKCHToken(_tokenAddress, adminWallet);
    final totalSupply = await kchToken.totalSupply();
    print("max supply from IKCHToken: ${bigIntToString(totalSupply)}");
  }

  void initAuctionContract() {
    print("init auction contract");
    final _auctionAddress = Get.find<DashboardController>().auctionAddress;

    auctionContract = IAuctionInterface(_auctionAddress, adminWallet);
    print("Auction Contract Address: $_auctionAddress");
  }

  void initTokenContract() {
    print("init token contract");
    final _tokenAddress = Get.find<DashboardController>().tokenAddress;
    print("token contract address: $_tokenAddress");
    tokenContract = ContractERC20(_tokenAddress, adminWallet);
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

  Future<String?> startAuction() async {
    if (auctionContract == null) return null;
    final result = await auctionContract!.startAuction();
    print(result.hash);
    return result.hash;
  }
}
