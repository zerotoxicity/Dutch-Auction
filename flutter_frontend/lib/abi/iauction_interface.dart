import 'package:flutter_frontend/abi/IAuctionInterface.abi.dart';
import 'package:flutter_web3/flutter_web3.dart';

/// For dart to interface with IAuctionInterface
class IAuctionInterface {
  late Contract auctionContract;

  IAuctionInterface(String address, dynamic provider) {
    auctionContract = Contract(address, kAuctionInterfaceABI, provider);
  }

  Future<BigInt> getAuctionNo() async => await callFn<BigInt>("getAuctionNo");

  Future<BigInt> getAuctionStartTime() async =>
      await callFn<BigInt>("getAuctionStartTime");

  Future<int> getAuctionState() async => await callFn<int>("getAuctionState");

  Future<BigInt> getSupplyReserved() async =>
      await callFn<BigInt>("getSupplyReserved");

  Future<BigInt> getTokenPrice(int auctionNo) async =>
      await callFn<BigInt>("getTokenPrice", [auctionNo]);

  Future<BigInt> getUserBidAmount(String address) async {
    return await callFn<BigInt>("getUserBidAmount", [address]);
  }

  Future<TransactionResponse?> insertBid(BigInt amount) async {
    return await auctionContract.send(
      "insertBid",
      [],
      TransactionOverride(value: amount),
    );
  }

  Future<void> startAuction() async => callFn<void>("startAuction");

  Future<bool> checkIfAuctionShouldEnd() async =>
      callFn<bool>("checkIfAuctionShouldEnd");

  Future<void> withdraw() async => callFn<void>("withdraw");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    late T result;
    try {
      result = await auctionContract.call(fnName, a);
    } catch (e) {
      print("error $fnName: ${e.toString()}");
    }
    return result;
  }
}
