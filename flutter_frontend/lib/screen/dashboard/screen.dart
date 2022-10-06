import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/admin/screen.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:get/get.dart';

import '../../helper.dart';

// Shows the current ICO activities, login required
class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);
  final Web3Controller web3Controller = Get.find<Web3Controller>();
  final DashboardController controller = Get.put(DashboardController());

  static const List<Widget> tabs = [
    Tab(
      icon: Icon(Icons.money),
      text: "Auction Page",
    ),
    Tab(
      icon: Icon(Icons.admin_panel_settings),
      text: "Admin Page",
    )
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        backgroundColor: Colors.blue[50],
        appBar: AppBar(
          bottom: const TabBar(tabs: tabs),
          title: const Text("Dashboard"),
          actions: [
            Obx(() => Center(
                child: Text(
                    "Current Chain: ${web3Controller.currentChain.value}"))),
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
              icon: const Icon(Icons.refresh),
              tooltip: "Refresh Auction",
              onPressed: controller.fetchAuctionFromBlockchain,
            )
          ],
        ),
        body: TabBarView(children: [
          Container(
            color: Colors.amber[50],
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: ListView(
                children: [
                  auctionNoWidget,
                  timestampWidget,
                  countdownWidget,
                  currentBidPriceWidget,
                  tokenSupplyWidget,
                  auctionStateWidget,
                  contractAddressWidget(
                    "Auction Address: ",
                    controller.auctionContract.address,
                    controller.auctionAddressEditingController,
                  ),
                  contractAddressWidget(
                    "Token Address: ",
                    controller.tokenContract.contract.address,
                    controller.tokenAddressEditingController,
                  ),
                  ElevatedButton(
                    child: const Text("Submit"),
                    onPressed: controller.updateAddress,
                  ),
                  submitBidWdiget,
                ],
              ),
            ),
          ),
          AdminScreen()
        ]),
      ),
    );
  }

  Widget contractAddressWidget(
    String title,
    String previousAddress,
    TextEditingController controller,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: Get.width * 0.6,
      child: Row(
        children: [
          Text(title),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: previousAddress,
              ),
              controller: controller,
              inputFormatters: [
                // Only allow hex address
                FilteringTextInputFormatter.allow(
                  RegExp(r'^[0xX][a-zA-Z0-9]*$'),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Convert timestamp to human readable string
  String _convertTimestampToReadable(int timestamp) {
    final _dt =
        DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
    return "${_dt.day}/${_dt.month}/${_dt.year}";
  }

  String _countdownHandler(int seconds) {
    if (seconds > 59 || seconds < -59) {
      return "${(seconds / 60).round()} mins ${(seconds % 60.round())} seconds";
    } else {
      return "$seconds seconds";
    }
  }

  Widget get timestampWidget => Obx(
        () => SelectableText(
            "Start time: ${_convertTimestampToReadable(controller.startTime.value!.toInt())}"),
      );

  Widget get countdownWidget => Obx(
        () => SelectableText(
            "Time left: ${_countdownHandler(controller.countdownTimerInSeconds.value)}"),
      );

  Widget get auctionNoWidget => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.green[50],
        width: Get.width * 0.6,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Obx(
            () => SelectableText("Auction No: ${controller.auctionNo.value}"),
          ),
          IconButton(
              onPressed: controller.fetchAuctionNo,
              icon: const Icon(Icons.refresh))
        ]),
      );

  Widget get currentBidPriceWidget => Obx(
        () => SelectableText("Current Bid Price: " +
            controller.currentBidPrice.value.toString()),
      );

  Widget get auctionStateWidget => Card(
        child: Obx((() => SelectableText(
            "Auction State: ${kAuctionState[controller.auctionState.value!]}"))),
      );
  Widget get tokenSupplyWidget => Obx(
      (() => SelectableText("Total Supply: ${controller.tokenSupply.value}")));

  Widget get submitBidWdiget => Container(
        constraints: BoxConstraints(maxWidth: Get.width * 0.6),
        child: Row(
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
                  controller: controller.bidAmountEditingController,
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
                await controller.submitBid();
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      );
}
