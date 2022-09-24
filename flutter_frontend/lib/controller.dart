import 'package:get/get.dart';
import "package:flutter_web3/flutter_web3.dart";

class AuthController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    if (isEnabled.value) {
      ethereum!.onAccountsChanged((accounts) {
        clear();
      });
      ethereum!.onChainChanged((chainId) {
        clear();
      });
    }
    print("Controller intialised");
  }

  /// Getters
  RxBool get isEnabled => RxBool(ethereum != null);
  RxBool get isInOperatingChain =>
      RxBool(currentChain.value == operatingChain.value);
  RxBool get isConnected =>
      RxBool(isEnabled.value && currentAddress.isNotEmpty);

  RxString currentAddress = RxString("");
  RxInt currentChain = RxInt(-1);
  RxInt operatingChain = RxInt(4);

  setChain(int v) {
    operatingChain.value = v;
  }

  Future<void> connect() async {
    if (isConnected.value) {}
    if (isEnabled.value) {
      final accounts = await ethereum!.requestAccount();
      print("Requesting accounts");
      if (accounts.isNotEmpty) {
        currentAddress.value = accounts[0];
      }
      currentChain.value = await ethereum!.getChainId();
    }
  }

  clear() {
    currentAddress.value = "";
    currentChain.value = -1;
  }
}
