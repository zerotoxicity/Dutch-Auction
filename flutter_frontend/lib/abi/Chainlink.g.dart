// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"inputs":[],"name":"decimals","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"description","outputs":[{"internalType":"string","name":"","type":"string"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint80","name":"_roundId","type":"uint80"}],"name":"getRoundData","outputs":[{"internalType":"uint80","name":"roundId","type":"uint80"},{"internalType":"int256","name":"answer","type":"int256"},{"internalType":"uint256","name":"startedAt","type":"uint256"},{"internalType":"uint256","name":"updatedAt","type":"uint256"},{"internalType":"uint80","name":"answeredInRound","type":"uint80"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"latestRoundData","outputs":[{"internalType":"uint80","name":"roundId","type":"uint80"},{"internalType":"int256","name":"answer","type":"int256"},{"internalType":"uint256","name":"startedAt","type":"uint256"},{"internalType":"uint256","name":"updatedAt","type":"uint256"},{"internalType":"uint80","name":"answeredInRound","type":"uint80"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"version","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"}]',
    'Chainlink');

class Chainlink extends _i1.GeneratedContract {
  Chainlink(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> decimals({_i1.BlockNum? atBlock}) async {
    final function = self.function('decimals');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<String> description({_i1.BlockNum? atBlock}) async {
    final function = self.function('description');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as String);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<GetRoundData> getRoundData(BigInt _roundId,
      {_i1.BlockNum? atBlock}) async {
    final function = self.function('getRoundData');
    final params = [_roundId];
    final response = await read(function, params, atBlock);
    return GetRoundData(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<LatestRoundData> latestRoundData({_i1.BlockNum? atBlock}) async {
    final function = self.function('latestRoundData');
    final params = [];
    final response = await read(function, params, atBlock);
    return LatestRoundData(response);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> version({_i1.BlockNum? atBlock}) async {
    final function = self.function('version');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }
}

class GetRoundData {
  GetRoundData(List<dynamic> response)
      : roundId = (response[0] as BigInt),
        answer = (response[1] as BigInt),
        startedAt = (response[2] as BigInt),
        updatedAt = (response[3] as BigInt),
        answeredInRound = (response[4] as BigInt);

  final BigInt roundId;

  final BigInt answer;

  final BigInt startedAt;

  final BigInt updatedAt;

  final BigInt answeredInRound;
}

class LatestRoundData {
  LatestRoundData(List<dynamic> response)
      : roundId = (response[0] as BigInt),
        answer = (response[1] as BigInt),
        startedAt = (response[2] as BigInt),
        updatedAt = (response[3] as BigInt),
        answeredInRound = (response[4] as BigInt);

  final BigInt roundId;

  final BigInt answer;

  final BigInt startedAt;

  final BigInt updatedAt;

  final BigInt answeredInRound;
}
