import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/admin/controller.dart';
import 'package:flutter_frontend/screen/admin/screen.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';
import 'package:flutter_frontend/screen/auction/screen.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';

import 'package:flutter_frontend/web3_controller.dart';
import 'package:get/get.dart';

import '../../widget.dart';

/// Show information about token
class DashboardScreen extends StatelessWidget {
  DashboardScreen({Key? key}) : super(key: key);
  final Web3Controller web3Controller = Get.find<Web3Controller>();
  final DashboardController controller = Get.put(DashboardController());

  final AuctionController auctionController = Get.put(AuctionController());
  final AdminController adminController = Get.put(AdminController());

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _floatingActionHandler,
        child: const Icon(Icons.add),
        tooltip: "Add new Auction Contract",
      ),
      appBar: AppBar(
        title: const Text("Ketchup ICO"),
        actions: [
          Obx(() => Center(
              child:
                  Text("Current Chain: ${web3Controller.currentChain.value}"))),
          const SizedBox(width: 8),
          Center(
            child: Obx(() => Text("ETH: ${web3Controller.etherBalance}")),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: "Refresh Auction",
            onPressed: () async =>
                await auctionController.refreshAuctionState(),
          ),
          IconButton(
            onPressed: () => showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    children: [
                      textLayout("Ketchup Balance (KCH): ",
                          auctionController.userKCHBalance, onTap: () {
                        auctionController.updateUserKCHBalance();
                      })
                    ],
                  );
                }),
            icon: const Icon(Icons.account_balance_wallet),
            tooltip: "KCH balance",
          )
        ],
      ),
      body: DefaultTabController(
        length: tabs.length,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            tokenSupplyWidget,
            averagePriceWidget,
            const TabBar(
              tabs: tabs,
              labelColor: Colors.blueAccent,
              unselectedLabelColor: Colors.blue,
            ),
            Flexible(
              child: TabBarView(children: [AuctionScreen(), AdminScreen()]),
            )
          ],
        ),
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
                controller.auctionAddress,
                controller.auctionAddressEditingController,
              ),
              contractAddressWidget(
                "Token Address: ",
                controller.tokenAddress,
                controller.tokenAddressEditingController,
              ),
              ElevatedButton(
                child: const Text("Submit"),
                onPressed: () async {
                  final _aa = controller.auctionAddressEditingController.text;
                  final _ta = controller.tokenAddressEditingController.text;
                  auctionController.updateContractAddress(
                    newAuctionAddress: _aa,
                    newTokenAddress: _ta,
                  );
                  adminController.updateContractAddress(
                    newAuctionAddress: _aa,
                    newTokenAddress: _ta,
                  );
                  final snackbar = GetSnackBar(
                    title: "Update new contract",
                    message:
                        "Auction address: ${auctionController.auctionAddress} \n Token address: ${auctionController.tokenAddress}",
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

  Widget get tokenSupplyWidget => textLayout(
        "Total Supply: ",
        auctionController.tokenTotalSupply,
      );
  Widget get averagePriceWidget => textLayout(
        "Average Price: (ETH/KCH)",
        auctionController.tokenPrice,
      );
}
