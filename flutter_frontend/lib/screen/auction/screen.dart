import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';
import 'package:flutter_frontend/widget.dart';
import 'package:get/get.dart';

import '../../helper.dart' as helper;
import '../past_auction/controller.dart';
import '../past_auction/screen.dart';

/// Widgets for bidder specific
class AuctionScreen extends StatelessWidget {
  AuctionScreen({Key? key}) : super(key: key);
  final controller = Get.find<AuctionController>();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          auctionNoWidget,
          startTimeWidget,
          endTimeWidget,
          countdownWidget,
          auctionStateWidget,
          currentBidPriceWidget,
          supplyReserved,
          auctionTokenSupplyWidget,
          actionButtonWidget,
        ],
      ),
    );
  }

  Widget get auctionNoWidget => Container(
        padding: const EdgeInsets.all(8),
        color: Colors.green[50],
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Obx(
            () => SelectableText(
                "Current Auction No: ${controller.auctionNo.value}"),
          ),
          IconButton(
            onPressed: () {
              Get.put(PastAuctionController());
              Get.bottomSheet(PastAuction());
            },
            icon: const Icon(Icons.history),
            tooltip: "Past Auctions",
          )
        ]),
      );

  Widget get actionButtonWidget => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(
            () => OutlinedButton(
              child: const Text("Submit Bid"),
              onPressed: controller.auctionState.value == 0
                  ? () async => await showDialog(
                        context: Get.context!,
                        builder: (context) => submitBidWdiget,
                      )
                  : null,
            ),
          ),
          const SizedBox(width: 8),
          Obx(
            () => OutlinedButton(
              child: const Text("Withdraw KCH token"),
              onPressed: controller.auctionState.value == 1
                  ? () async {
                      if (controller.auctionState.value != 0) {
                        try {
                          // Attempt to withdraw tokens
                          await controller.withdrawTokens();
                          final receivedTokens =
                              await controller.updateUserKCHBalance();
                          String message = "";
                          String title = "Withdraw Successful";
                          if (receivedTokens!.toInt() > 0) {
                            message =
                                "Received: ${helper.bigIntToString(receivedTokens)}";
                          } else {
                            message = "awaitng for withdrawal";
                            title = "Withdraw Submitted";
                          }
                          GetSnackBar(
                            title: title,
                            message: message,
                            duration: const Duration(seconds: 3),
                          ).show();
                        } catch (e) {
                          const GetSnackBar(
                            title: "Withdraw Unsuccessful",
                            message: "User has withdrawed/Did not bid",
                            duration: Duration(seconds: 3),
                          ).show();
                        }
                      } else {
                        const GetSnackBar(
                          title: "Withdraw Failed",
                          message: "Auction has not ended. Click to refresh",
                          duration: Duration(seconds: 3),
                        ).show();
                      }
                      // Withdraw token from auction address
                    }
                  : null,
            ),
          )
        ],
      );

  Widget get submitBidWdiget => AlertDialog(
        title: const Text("Bid Amount"),
        actions: [
          ElevatedButton(
            onPressed: controller.auctionState.value == 0
                ? () async {
                    final bidAmount =
                        (await controller.submitBid()).toDouble() / 1e18;
                    String title =
                        bidAmount >= 0 ? "Bid Successful" : "Bid Unsuccessful";
                    String message =
                        "Amount: ${bidAmount.toPrecision(4).toString()} ETH";
                    final sb = GetSnackBar(
                      title: title,
                      message: message,
                      duration: const Duration(seconds: 3),
                    );
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
          color: helper.auctionStateColor(_state),
          child: SelectableText(helper.kAuctionState[_state]!),
        );
      }));

  Widget get supplyReserved =>
      textLayout("Reserved KCH: ", controller.supplyReserved);

  Widget get auctionTokenSupplyWidget => textLayout(
        "Auction Token Supply: ",
        controller.auctionTokenSupply,
      );

  Widget get endTimeWidget => textLayout(
        "End Time: ",
        controller.endTimeString,
      );
  Widget get startTimeWidget => textLayout(
        "Start Time: ",
        controller.startTimeString,
      );
  Widget get countdownWidget => textLayout(
        "Time left: ",
        controller.timeLeftString,
      );
}
