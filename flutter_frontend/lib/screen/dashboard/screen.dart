import 'dart:html';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/admin/screen.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:flutter_frontend/style.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:get/get.dart';

import '../../helper.dart';
import '../../widget.dart';

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
        floatingActionButton: FloatingActionButton(
          onPressed: _floatingActionHandler,
          child: const Icon(Icons.add),
          tooltip: "Add new Auction Contract",
        ),
        appBar: AppBar(
          bottom: const TabBar(tabs: tabs),
          title: const Text("Ketchup ICO"),
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
              onPressed: controller.refreshAuctionState,
            )
          ],
        ),
        body: TabBarView(children: [
          Container(
            color: Colors.amber[50],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 80),
            child: ListView(
              children: [
                tokenSupplyWidget,
                auctionStateWidget,
                auctionNoWidget,
                actionButtonWidget,
                auctionTokenSupplyWidget,
                timestampWidget,
                countdownWidget,
                currentBidPriceWidget,
                userKCHBalanceWidget,
              ],
            ),
          ),
          AdminScreen()
        ]),
      ),
    );
  }

  _floatingActionHandler() async {
    await Get.bottomSheet(
      Material(
        child: Container(
          padding: const EdgeInsets.all(8),
          color: Colors.orange[100],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Add new Auction Contract"),
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
                onPressed: () async {
                  await controller.updateAddress();
                  final snackbar = GetSnackBar(
                    title: "Update new contract",
                    message:
                        "Auction address: ${controller.auctionContract.address} \n Token address: ${controller.tokenContract.contract.address}",
                    duration: const Duration(seconds: 3),
                  );
                  Get.back();
                  snackbar.show();
                },
              ),
            ],
          ),
        ),
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

  Widget get actionButtonWidget => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () async {
              await showDialog(
                context: Get.context!,
                builder: (context) => submitBidWdiget,
              );
            },
            tooltip: "Bid",
            icon: const Icon(Icons.bolt),
          ),
          const Divider(),
          IconButton(
            tooltip: "Withdraw KCH",
            icon: const Icon(Icons.output),
            onPressed: () async {
              await controller.checkAuctionShouldEnd();
              if (controller.auctionState.value == 1) {
                await controller.withdrawTokens();
                await controller.updateUserKCHBalance();
              } else {
                const GetSnackBar(
                  title: "Withdraw Failed",
                  message: "Auction has not ended. Click to refresh",
                  duration: Duration(seconds: 3),
                ).show();
              }
              // Withdraw token from auction address
            },
          )
        ],
      );

  Widget get userKCHBalanceWidget => textLayout(
        "Ketchup Balance (KCH): ",
        controller.userKCHBalance,
      );

  Widget get auctionTokenSupplyWidget => textLayout(
        "Auction Token Supply: ",
        controller.auctionTokenSupply,
      );

  Widget get timestampWidget => textLayout(
        "Start time: ",
        controller.startTime,
      );

  Widget get countdownWidget => textLayout(
        "Time left: ",
        controller.countdownTimerInSeconds,
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
            icon: const Icon(Icons.refresh),
          )
        ]),
      );

  Widget get currentBidPriceWidget => textLayout(
        "Current Bid Price (ETH):",
        controller.currentBidPrice,
      );

  Widget get auctionStateWidget => Obx((() {
        int _state = controller.auctionState.value;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          margin: const EdgeInsets.symmetric(vertical: 8),
          alignment: Alignment.center,
          color: _auctionStateColor(_state),
          child: SelectableText(kAuctionState[_state]!),
        );
      }));

  Color _auctionStateColor(int state) {
    if (state == 0) return Colors.greenAccent;
    if (state == 1) return Colors.blue;
    if (state == 2) return Colors.lightBlue;
    return Colors.grey;
  }

  Widget get tokenSupplyWidget => textLayout(
        "Total Supply: ",
        controller.tokenTotalSupply,
      );

  Widget get submitBidWdiget => AlertDialog(
        title: Text("Bid Amount", style: Style.headingTextStyle),
        actions: [
          ElevatedButton(
            onPressed: controller.auctionState.value == 0 ||
                    controller.auctionAddressEditingController.text.isNotEmpty
                ? () async {
                    final bidAmount =
                        (await controller.submitBid()).toDouble() / 1e18;
                    final sb = GetSnackBar(
                      title: "Bid Successful",
                      message:
                          "Amount: ${bidAmount.toPrecision(4).toString()} ETH",
                      duration: const Duration(seconds: 3),
                    );
                    await controller.refreshAuctionState();
                    Get.back();
                    sb.show();
                  }
                : null,
            child: const Text("Submit"),
          ),
        ],
        content: Obx(
          () => TextField(
            enabled: controller.auctionState.value == 0,
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
      );
}
