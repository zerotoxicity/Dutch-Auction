import "package:flutter_web3/flutter_web3.dart";

// Auction Contract: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9

/// Functions required by bidder only
class AuctionInterface {
  String auctionAddress;
  late Contract contract;
  AuctionInterface({
    required this.auctionAddress,
    required abi,
    required Web3Provider provider,
  }) {
    /// Contract that's able to read/write
    contract = Contract(auctionAddress, Interface(abi), provider.getSigner());
  }

  // * Listener
  void isAuctionEnded(Function handler) =>
      contract.on("ShouldAuctionEnd", handler);

  void isReceiving(Function handler) => contract.on("Receiving", handler);

  // * Read only functions
  Future getTokenPrice() async {
    int? tokenPrice;
    try {
      var _result = await contract.call<BigInt>("getTokenPrice");
      if (tokenPrice is BigInt) {
        return tokenPrice;
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<int?> getAuctionState() async {
    try {
      return await contract.call("getAuctionState");
    } catch (e) {
      print(e.toString());
    }
    return null;
  }

  Future<bool> checkIfAuctionShouldEnd() async {
    return await contract.call<bool>("checkIfAuctionShouldEnd");
  }

  Future<BigInt?> getAuctionNo() async {
    return await contract.call<BigInt>("getAuctionNo");
  }

  // * Read/Write functions

  Future<String> insertBid(int bidAmount) async {
    final TransactionResponse tx = await contract.send(
      "insertBid",
      [],
      TransactionOverride(value: BigInt.from(bidAmount)),
    );
    await tx.wait();
    return tx.hash;
  }

  Future<String?> withdrawToken() async {
    final TransactionResponse tx = await contract.send("withdraw");
    return tx.hash;
  }
}
