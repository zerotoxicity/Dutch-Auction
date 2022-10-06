import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/admin/controller.dart';
import 'package:get/get.dart';

class AdminScreen extends StatelessWidget {
  AdminScreen({Key? key}) : super(key: key);

  final controller = Get.put(AdminController());

  @override
  Widget build(BuildContext context) {
    return Center(
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
                onPressed: controller.addWallet,
                child: const Text("Add Wallet"),
              )
            ],
          );
        }
        return Column(
          children: [
            Obx((() => Text("Address: ${controller.walletAddress}"))),
            ElevatedButton(
                onPressed: () async {
                  await controller.startAuction();
                },
                child: const Text("Start Auction"))
          ],
        );
      }),
    );
  }
}
