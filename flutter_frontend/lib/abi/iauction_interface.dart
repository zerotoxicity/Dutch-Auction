import 'package:flutter_frontend/abi/IAuctionInterface.abi.dart';
import 'package:flutter_frontend/helper.dart';
import 'package:flutter_web3/flutter_web3.dart';

/// For dart to interface with IAuctionInterface
class IAuctionInterface {
  late Contract contract;
  late dynamic provider;
  late dynamic abi;

  IAuctionInterface(String address, this.provider,
      {this.abi = kAuctionInterfaceABI}) {
    contract = Contract(address, abi, provider);
  }

  void updateContract(String address) {
    contract = Contract(address, abi, provider);
  }

  Future<BigInt> getAuctionNo() async => await callFn<BigInt>("getAuctionNo");

  Future<BigInt> getAuctionStartTime(int auctionNo) async {
    try {
      return await contract.call<BigInt>("getAuctionStartTime", [auctionNo]);
    } catch (e) {
      return BigInt.zero;
    }
  }

  Future<BigInt> getAuctionEndTime(int auctionNo) async {
    return await callFn<BigInt>("getAuctionEndTime", [auctionNo]);
  }

  Future<int> getAuctionState() async => await callFn<int>("getAuctionState");

  /// Returns current supply reserved by bidders
  Future<BigInt> getSupplyReserved() async =>
      await callFn<BigInt>("getSupplyReserved");

  /// Auction supply
  Future<BigInt> getAuctionSupply() async =>
      await callFn<BigInt>("getAuctionSupply");

  Future<BigInt> getTokenPrice(int auctionNo) async =>
      await callFn<BigInt>("getTokenPrice", [auctionNo]);

  Future<BigInt> getUserBidAmount(String address, int auctionNo) async {
    return await callFn<BigInt>("getUserBidAmount", [address, auctionNo]);
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

  /// Returns a single duration in seconds period of an auction
  Future<BigInt> viewAuctionDuration() async {
    return await callFn<BigInt>("viewAuctionDuration");
  }

  Future<void> withdraw() async => contract.call<void>("withdraw");

  Future<T> callFn<T>(String fnName, [List<dynamic> a = const []]) async {
    // print("$fnName() called");
    late T result;
    result = await contract.call(fnName, a);
    return result;
  }
}
