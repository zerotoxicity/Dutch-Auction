import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/admin/controller.dart';
import 'package:flutter_frontend/widget.dart';
import 'package:get/get.dart';

class AdminScreen extends StatelessWidget {
  AdminScreen({Key? key}) : super(key: key);

  final controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Obx(() {
          if (!controller.isLogin.value) {
            // Bring user to "sign in"
            return Column(
              children: [
                const Text("Enter private key: "),
                Container(
                  width: context.width * 0.4,
                  margin: const EdgeInsets.all(8),
                  child: TextField(
                    controller: controller.privateKeyEditingController,
                    inputFormatters: [
                      // Only allow hex address
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^[0xX][a-zA-Z0-9]*$'),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await controller.addWallet();
                    controller.fetchEtherBalance();
                    controller.initAuctionContract();
                    controller.initTokenContract();
                    controller.fetchKCHBalance();
                  },
                  child: const Text("Add Wallet"),
                )
              ],
            );
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              textLayout("Wallet Address: ", controller.walletAddress),
              textLayout("KCH Balance: ", controller.kchBalance),
              textLayout("ETH Balance: ", controller.etherBalance),
              ElevatedButton(
                onPressed: () async {
                  final hash = await controller.startAuction();
                  if (hash != null) {
                    GetSnackBar(
                      title: "Success",
                      message: "Auction Started. Transaction hash: $hash",
                      duration: const Duration(seconds: 2),
                    ).show();
                  } else {
                    await Get.snackbar("Error", "Start auction failed").show();
                  }
                },
                child: const Text("Start Auction"),
              ),
              OutlinedButton(
                onPressed: () async => await controller.withdrawAll(),
                child: const Text("Withdraw Tokens"),
              ),
            ],
          );
        }),
      ),
    );
  }
}
