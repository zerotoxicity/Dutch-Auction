import 'package:flutter/material.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/past_auction/controller.dart';
import 'package:get/get.dart';

/// List of past auction
class PastAuction extends StatelessWidget {
  PastAuction({Key? key}) : super(key: key);
  final controller = Get.find<PastAuctionController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Past Auctions"),
        ),
        body: FutureBuilder<void>(
            future: controller.fetchAuctions(),
            builder: ((context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              }
              if (snapshot.connectionState == ConnectionState.done) {
                return GridView.builder(
                  itemCount: controller.auctions.length,
                  itemBuilder: (context, index) {
                    print("auction card: $index");
                    return AuctionCard(
                        auctionModel: controller.auctions[index]);
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8.0,
                    crossAxisSpacing: 12.0,
                  ),
                );
              }
              return const Center(
                child: SelectableText("No past auctions"),
              );
            })));
  }
}

/// Individual auction
class AuctionCard extends StatelessWidget {
  const AuctionCard({Key? key, required this.auctionModel}) : super(key: key);

  final AuctionModel auctionModel;

  Widget bodyText(String title, String content) {
    return SelectableText.rich(
      TextSpan(children: [
        TextSpan(text: title),
        TextSpan(
          text: content,
          style: const TextStyle(fontWeight: FontWeight.w600),
        )
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    const spacing = EdgeInsets.all(8);
    return Container(
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: spacing,
      margin: spacing,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SelectableText.rich(
            TextSpan(text: "Auction no:", children: [
              TextSpan(
                text: " ${auctionModel.auctionNo}",
                style: const TextStyle(fontWeight: FontWeight.w600),
              )
            ]),
          ),
          const SizedBox(height: 8),
          bodyText(
            "Total Bidded Amount (ETH):",
            bigIntToString(auctionModel.totalBiddedAmount),
          ),
          bodyText(
            "Bidded Amount (ETH):",
            bigIntToString(auctionModel.bidAmount),
          ),
          bodyText(
            "Start time: ",
            convertTimestampToReadable(auctionModel.startTime),
          ),
          bodyText(
            "End time: ",
            convertTimestampToReadable(auctionModel.endTime),
          ),
        ],
      ),
    );
  }
}
