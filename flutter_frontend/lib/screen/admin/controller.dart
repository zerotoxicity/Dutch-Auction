// Admin Controller for Web3

import 'package:flutter/material.dart';
import 'package:flutter_frontend/abi/IAuctionInterface.abi.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

/// @dev We assume the contract is deployed and using the same account to do other operations
class AdminController extends GetxController {
  RxBool isLogin = false.obs;
  Rx<String> walletAddress = "".obs;
  Rx<String> etherBalance = Rx("0");
  Rx<String> kchBalance = Rx("0");

  Wallet? adminWallet;
  Contract? auctionContract;
  ContractERC20? tokenContract;

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
    initTokenContract();
    initAuctionContract();
    fetchEtherBalance();
    fetchKCHBalance();
  }

  Future<void> addWallet(String privateKey) async {
    // Assume text is not empty
    adminWallet = Wallet(privateKey).connect(JsonRpcProvider());

    // Connect to localhost
    walletAddress.value = await adminWallet!.getAddress();
    isLogin.value = true;
  }

  void initAuctionContract() {
    print("init auction contract");
    final _auctionAddress =
        Get.find<DashboardController>().auctionContract.address;

    auctionContract = Contract(
      _auctionAddress,
      kAuctionInterfaceABI,
      adminWallet,
    );
    print("Auction Contract Address: $_auctionAddress");
  }

  void initTokenContract() {
    print("init token contract");
    final _tokenAddress =
        Get.find<DashboardController>().tokenContract.contract.address;
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
    final result = await auctionContract!.send("startAuction");
    print(result.hash);
    return result.hash;
  }

  Future<void> withdrawAll() async {
    if (auctionContract == null) return;
    final result = await auctionContract!.call("withdrawAll");
    print("withdrawAll(): ${dartify(result)}");
  }
}
