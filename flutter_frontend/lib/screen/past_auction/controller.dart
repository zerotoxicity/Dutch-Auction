import 'package:flutter_frontend/abi/iauction_interface.dart';
import 'package:flutter_frontend/screen/auction/controller.dart';
import 'package:get/get.dart';

class PastAuctionController extends GetxController {
  final RxList<AuctionModel> auctions = <AuctionModel>[].obs;
  late IAuctionInterface auctionContract;
  final userAddress = Get.find<AuctionController>().userAddress;

  @override
  void onInit() {
    super.onInit();
    auctionContract = Get.find<AuctionController>().auctionContract;
  }

  @override
  void onReady() async {
    super.onReady();
    await fetchAuctions();
  }

  Future<void> fetchAuctions() async {
    final latestNo = (await auctionContract.getAuctionNo()).toInt();
    print("latest auction no: $latestNo");
    if (latestNo <= 0) return; // No past auction yet

    final _auctions = <AuctionModel>[];

    final iterable = Iterable.generate(latestNo, (i) async {
      final _totalBiddedAmount = await auctionContract.getTotalBiddedAmount(i);
      final _bidAmount =
          await auctionContract.getUserBidAmount(userAddress.value, i);
      final _startTime = await auctionContract.getAuctionStartTime(i);
      final _endTime = await auctionContract.getAuctionEndTime(i);
      _auctions.add(AuctionModel(
        auctionNo: i,
        totalBiddedAmount: _totalBiddedAmount,
        bidAmount: _bidAmount,
        startTime: _startTime.toInt() * 1000,
        endTime: _endTime.toInt() * 1000,
      ));
    });
    for (var i in iterable) {
      await i;
    }
    print("fetched ${_auctions.length} past auctions");
    auctions.assignAll(_auctions);
  }
}

class AuctionModel {
  final int auctionNo;
  final BigInt totalBiddedAmount;
  final int auctionState;
  final BigInt bidAmount;
  final int startTime;
  final int endTime;

  AuctionModel({
    required this.auctionNo,
    required this.startTime,
    required this.endTime,
    required this.totalBiddedAmount,
    this.auctionState = 1,
    required this.bidAmount,
    // required this.auctionSupply,
  });
}
