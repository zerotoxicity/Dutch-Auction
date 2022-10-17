import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/screen/dashboard/controller.dart';
import 'package:get/get.dart';

class PastAuctionController extends GetxController {
  final RxList<AuctionModel> auctions = RxList.empty();
  late IAuctionInterface auctionContract;
  final userAddress = Get.find<DashboardController>().userAddress;

  @override
  void onInit() {
    super.onInit();
    auctionContract = Get.find<DashboardController>().auctionContract;
  }

  @override
  void onReady() async {
    super.onReady();
    await fetchAuctions();
  }

  Future<void> fetchAuctions() async {
    final latestNo = (await auctionContract.getAuctionNo()).toInt();
    print("auction no: $latestNo");
    print("user address: ${userAddress.value}");
    if (latestNo <= 0) return; // No past auction yet

    final iterable = Iterable.generate(latestNo, (i) async {
      print("fetch: $i");
      auctions.add(AuctionModel(
        auctionNo: i,
        totalBiddedAmount: await auctionContract.getTotalBiddedAmount(i),
        bidAmount: await auctionContract.getUserBidAmount(userAddress.value),
      ));
    });
    for (var i in iterable) {
      await i;
    }
    print("fetched ${auctions.length} past auctions");
    refresh();
  }
}

class AuctionModel {
  final int auctionNo;
  final BigInt totalBiddedAmount;
  // final BigInt auctionSupply;
  final int auctionState;
  final BigInt bidAmount;
  // final int startTime;

  AuctionModel({
    required this.auctionNo,
    // required this.startTime,
    required this.totalBiddedAmount,
    this.auctionState = 1,
    required this.bidAmount,
    // required this.auctionSupply,
  });
}
