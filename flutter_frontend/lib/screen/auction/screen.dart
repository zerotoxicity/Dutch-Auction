import 'package:flutter/material.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';
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
      body: ListView.builder(
        itemCount: controller.auctions.length,
        itemBuilder: (context, index) {
          final _auction = controller.auctions;
          return AuctionCard(auctionModel: _auction[index]);
        },
      ),
    );
  }
}

/// Individual auction
class AuctionCard extends StatelessWidget {
  const AuctionCard({Key? key, required this.auctionModel}) : super(key: key);

  final AuctionModel auctionModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(children: [
        Text("Auction no: ${auctionModel.auctionNo}"),
        Text(
            "Total bidded amount: ${bigIntToString(auctionModel.totalBiddedAmount)}"),
        Text("Bid amount: ${bigIntToString(auctionModel.bidAmount)}")
      ]),
    );
  }
}
