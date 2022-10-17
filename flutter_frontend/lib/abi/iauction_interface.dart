import 'package:flutter_frontend/abi/IAuctionInterface.abi.dart';
import 'package:flutter_web3/flutter_web3.dart';

/// For dart to interface with IAuctionInterface
class IAuctionInterface {
  late Contract contract;

  IAuctionInterface(String address, dynamic provider, {abi}) {
    contract = Contract(address, abi ?? kAuctionInterfaceABI, provider);
  }

  Future<BigInt> getAuctionNo() async => await callFn<BigInt>("getAuctionNo");

  Future<BigInt> getAuctionStartTime() async =>
      await callFn<BigInt>("getAuctionStartTime");

  Future<int> getAuctionState() async => await callFn<int>("getAuctionState");

  Future<BigInt> getSupplyReserved() async =>
      await callFn<BigInt>("getSupplyReserved");

  /// Auction's supply
  Future<BigInt> getAuctionSupply() async =>
      await callFn<BigInt>("getAuctionSupply");

  Future<BigInt> getTokenPrice(int auctionNo) async =>
      await callFn<BigInt>("getTokenPrice", [auctionNo]);

  Future<BigInt> getUserBidAmount(String address) async {
    return await callFn<BigInt>("getUserBidAmount", [address]);
  }

  Future<BigInt> getTotalBiddedAmount(int auctionNo) async {
    return await callFn<BigInt>("getTotalBiddedAmount", [auctionNo]);
  }

  Future<TransactionResponse?> insertBid(BigInt amount) async {
    return await contract.send(
      "insertBid",
      [],
      TransactionOverride(value: amount),
    );
  }

  Future<TransactionResponse> startAuction() async =>
      await contract.send("startAuction");

  Future checkIfAuctionShouldEnd() async {
    var result = await contract.call("checkIfAuctionShouldEnd");
    return result;
  }

  Future<void> withdraw() async => callFn<void>("withdraw");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    print("$fnName() called");
    late T result;
    result = await contract.call(fnName, a);
    return result;
  }
}
