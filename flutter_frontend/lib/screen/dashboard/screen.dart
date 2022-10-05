import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:get/get.dart';

import '../../helper.dart';

// Shows the current ICO activities, login required
class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);
  final Web3Controller web3Controller = Get.find<Web3Controller>();
  final DashboardController dashboardController =
      Get.put(DashboardController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          Obx(() => Center(
              child:
                  Text("Current Chain: ${web3Controller.currentChain.value}"))),
          const SizedBox(width: 8),
          FutureBuilder<BigInt>(
              future: web3Controller.getNativeTokenBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }
                if (snapshot.hasData) {
                  return Center(
                      child: Text("Eth: ${bigIntToString(snapshot.data!)}"));
                }
                return Container();
              }),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {},
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            tokenPriceWidget,
            tokenSupplyWidget,
            auctionStateWidget,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text("Bid Amount"),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      decoration: const InputDecoration(
                          border: OutlineInputBorder(), hintText: "in ether"),
                      controller: dashboardController.textEditingController,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          try {
                            final text = newValue.text;
                            if (text.isNotEmpty) double.parse(text);
                            return newValue;
                          } catch (e) {
                            print("input error: ${e.toString()}");
                          }
                          return oldValue;
                        }),
                      ],
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () async {
                      await dashboardController.submitBid();
                    },
                    child: const Text("Submit"))
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget get tokenPriceWidget => Obx(
        () => Text("Token Price: " +
            dashboardController.currentBidPrice.value.toString()),
      );

  Widget get auctionStateWidget => Card(
        child: Obx((() => Text(
            "Auction State: ${kAuctionState[dashboardController.auctionState.value!]}"))),
      );
  Widget get tokenSupplyWidget => Obx(
      (() => Text("Total Supply: ${dashboardController.tokenSupply.value}")));
}
