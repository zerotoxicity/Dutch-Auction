import 'package:flutter_web3/flutter_web3.dart';

class KetchupTokenInterface {
  late ContractERC20 tokenContract;
  String tokenAddress;
  Web3Provider provider;

  KetchupTokenInterface({
    required this.tokenAddress,
    required this.provider,
  }) {
    tokenContract = ContractERC20(tokenAddress, provider);
  }

  // @note not in used for bidder
  Future<String?> fundAuction(int amount) async {
    TransactionResponse response = await tokenContract.contract.send(
      "fundAuction",
      [],
      TransactionOverride(value: BigInt.from(amount)),
    );
    TransactionReceipt receipt = await response.wait();
    return receipt.transactionHash;
  }

  currentPrice() async {
    tokenContract.balanceOf(await provider.getSigner().getAddress());
  }
}
