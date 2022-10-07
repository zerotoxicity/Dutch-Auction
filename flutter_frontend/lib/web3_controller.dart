import 'dart:html';

import "package:flutter_web3/ethers.dart";

import 'package:get/get.dart';
import "package:flutter_web3/flutter_web3.dart";

class Web3Controller extends GetxController {
  @override
  void onInit() {
    super.onInit();

    if (isEnabled.value) {
      ethereum!.onAccountsChanged((accounts) {
        print("Change in account: $accounts");
        currentAddress.value = accounts[0];
        window.location.reload();
      });
      ethereum!.onChainChanged((chainId) {
        print("Change in chainId: $chainId");
        setChain(chainId);
        window.location.reload();
      });
      ethereum!.onDisconnect((error) {
        clear();
        update();
      });

      ethereum!.on("message", (message) {
        print(dartify(message));
      });
    }
  }

  /// Getters
  RxBool get isEnabled => RxBool(ethereum != null);
  RxBool get isInOperatingChain =>
      RxBool(currentChain.value == operatingChain.value);
  RxBool get isConnected =>
      RxBool(isEnabled.value && currentAddress.isNotEmpty);
  Web3Provider? get getProvider => provider;

  RxString currentAddress = RxString("");
  RxInt currentChain = RxInt(-1);
  RxInt operatingChain = RxInt(5);

  void setChain(int v) {
    operatingChain.value = v;
  }

  // Read-only functions
  Future<BigInt> getNativeTokenBalance() async {
    BigInt _result = await getNativeTokenBalanceOf(currentAddress.value);
    return _result;
  }

  Future<BigInt> getNativeTokenBalanceOf(String address) async {
    try {
      if (ethereum != null) {
        final web3provider = Web3Provider.fromEthereum(ethereum!);
        return await web3provider.getBalance(address);
      }
      return BigInt.zero;
    } catch (error) {
      print(error);
      return BigInt.zero;
    }
  }

  Future<void> connect() async {
    if (isEnabled.value) {
      final accounts = await ethereum!.requestAccount();
      print("Requesting accounts");
      if (accounts.isNotEmpty) {
        currentAddress.value = accounts[0];
      }
      currentChain.value = await ethereum!.getChainId();
    }
  }

  Future<void> disconnect() async {
    if (isConnected.value) {
      // TODO : Sign out
    }
  }

  clear() {
    currentAddress.value = "";
    currentChain.value = -1;
  }
}
