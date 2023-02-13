import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/admin/controller.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';
import 'package:flutter_frontend/widget.dart';
import 'package:get/get.dart';

class AdminScreen extends StatelessWidget {
  AdminScreen({Key? key}) : super(key: key);

  final controller = Get.find<AdminController>();

  final _textStyle = const TextStyle(fontWeight: FontWeight.w600);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
          return Wrap(
            // mainAxisAlignment: MainAxisAlignment.center,
            // mainAxisSize: MainAxisSize.max,
            // spacing: ,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            runAlignment: WrapAlignment.center,
            spacing: 20,
            children: [
              kchBalanceWidget(context),
              textLayout("Wallet Address: ", controller.walletAddress),
              textLayout("ETH Balance: ", controller.etherBalance),
              auctiontokenAddress(),
              startAuctionWidget(context),
            ],
          );
        }),
      ),
    );
  }

  Widget kchBalanceWidget(BuildContext context) {
    final TextEditingController textEditingController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(
              child: TextField(
            controller: textEditingController,
            decoration: const InputDecoration(
              hintText: "Enter Address",
            ),
          )),
          ElevatedButton(
            onPressed: () {
              showKCHBalance(textEditingController.value.text, context);
              textEditingController.clear();
            },
            child: const Text("Search"),
          )
        ],
      ),
    );
  }

  Widget auctiontokenAddress() => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Flexible(
              child: SelectableText.rich(
                TextSpan(
                    text: "Token Address: ",
                    children: [
                      TextSpan(text: controller.tokenContract?.contract.address)
                    ],
                    style: _textStyle),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: SelectableText.rich(
                TextSpan(
                    text: "Auction Address: ",
                    children: [
                      TextSpan(
                          text: controller.auctionContract?.contract.address)
                    ],
                    style: _textStyle),
              ),
            ),
          ],
        ),
      );

  Widget startAuctionWidget(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        final hash = await controller.startAuction();
        controller.startBackgroundAction();

        if (hash != null) {
          await Get.find<AuctionController>().startAuction();
          GetSnackBar(
            title: "Success",
            message: "Auction Started. Transaction hash: $hash",
            duration: const Duration(seconds: 2),
          ).show();
        } else {
          const GetSnackBar(
            title: "Action Unsuccessful",
            message: "Unable to start auction. Try redeploying blockchain",
            duration: Duration(seconds: 2),
          ).show();
        }
      },
      child: const Text("Start Auction"),
    );
  }
}

/// Pop up dialog that shows the KCH balance of given address
Future<void> showKCHBalance(String address, BuildContext context) async {
  final controller = Get.find<AdminController>();
  final balance = await controller.tokenContract!.balanceOf(address);

  await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return AlertDialog(
          title: Text("Address: $address "),
          content: Text.rich(
            TextSpan(
                text: "Balance: ",
                style: const TextStyle(fontWeight: FontWeight.w600),
                children: [TextSpan(text: bigIntToString(balance) + " KCH")]),
            textAlign: TextAlign.center,
          ),
        );
      });
}
