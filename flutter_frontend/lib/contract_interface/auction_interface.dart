import "package:flutter_web3/flutter_web3.dart";

// Auction Contract: 0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9

// @note to be deprecated
/// Functions required by bidder only
class AuctionInterface {
  String auctionAddress;
  late Contract contract;
  Web3Provider provider;
  AuctionInterface({
    required this.auctionAddress,
    required abi,
    required this.provider,
  }) {
    /// Contract that's able to read/write
    provider
        .getSigner()
        .getAddress()
        .then((value) => print("Signer Address: $value"));
    contract = Contract(auctionAddress, Interface(abi), provider.getSigner());
  }

  // * Listener
  void isAuctionEnded(Function handler) =>
      contract.on("ShouldAuctionEnd", handler);

  void isReceiving(Function handler) => contract.on("Receiving", handler);

  // * Read only functions
  Future<BigInt?> getTokenPrice(BigInt auctionNo) async {
    try {
      return await contract.call<BigInt>("getTokenPrice", [auctionNo]);
    } catch (e) {
      print(e.toString());
    }
    return null;
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
    try {
      var result = await contract.call<BigInt>("getAuctionNo");
      return result;
    } catch (e) {
      print("error: ${e.toString()}");
    }
    return null;
  }

  // * Read/Write functions

  Future<String?> insertBid(int bidAmount) async {
    try {
      final TransactionResponse tx = await contract.send(
        "insertBid",
        [],
        TransactionOverride(
          value: BigInt.from(bidAmount),
        ),
      );
      await tx.wait();
      return tx.hash;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> withdrawToken() async {
    final TransactionResponse tx = await contract.send("withdraw");
    return tx.hash;
  }
}
