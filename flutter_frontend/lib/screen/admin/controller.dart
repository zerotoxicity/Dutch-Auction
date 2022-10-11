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

  Wallet? adminWallet;
  Contract? auctionContract;

  TextEditingController privateKeyEditingController = TextEditingController();
  TextEditingController contractEditingController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    ever(adminWallet.obs, (Wallet? wallet) {
      if (wallet != null) {
        print("admin wallet address: ${wallet.address}");
      }
    });
  }

  Future<void> addWallet() async {
    // Assume text is not empty
    adminWallet =
        Wallet(privateKeyEditingController.text).connect(JsonRpcProvider());

    // Connect to localhost
    walletAddress.value = await adminWallet!.getAddress();
    privateKeyEditingController.clear();

    isLogin.value = true;
  }

  void initAuctionContract() {
    final _auctionAddress =
        Get.find<DashboardController>().auctionContract.address;
    auctionContract = Contract(
      _auctionAddress,
      kAuctionInterfaceABI,
      adminWallet,
    );
    print("Auction Contract Address @ $_auctionAddress");
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
