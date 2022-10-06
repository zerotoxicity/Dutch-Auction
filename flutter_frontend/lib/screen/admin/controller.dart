// Admin Controller for Web3

import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';
import 'package:get/get.dart';

/// @dev We assume the contract is deployed and using the same account to do other operations
class AdminController extends GetxController {
  Wallet? adminWallet;
  RxBool isLogin = false.obs;
  Rx<String> walletAddress = "".obs;

  TextEditingController privateKeyEditingController = TextEditingController();

  void addWallet() async {
    // Assume text is not empty
    adminWallet =
        Wallet(privateKeyEditingController.text).connect(JsonRpcProvider());

    // Connect to localhost
    walletAddress.value = await adminWallet!.getAddress();
    privateKeyEditingController.clear();

    isLogin.value = true;
  }

  Future<void> startAuction() async {
    final result = await adminWallet!.signTransaction(
      TransactionRequest(),
    );
    print('result: $result');
  }
}
