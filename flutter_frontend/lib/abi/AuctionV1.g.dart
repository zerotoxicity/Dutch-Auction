// Generated code, do not modify. Run `build_runner build` to re-generate!
// @dart=2.12
import 'package:web3dart/web3dart.dart' as _i1;
import 'dart:typed_data' as _i2;

final _contractAbi = _i1.ContractAbi.fromJson(
    '[{"anonymous":false,"inputs":[{"indexed":false,"internalType":"address","name":"previousAdmin","type":"address"},{"indexed":false,"internalType":"address","name":"newAdmin","type":"address"}],"name":"AdminChanged","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"beacon","type":"address"}],"name":"BeaconUpgraded","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint8","name":"version","type":"uint8"}],"name":"Initialized","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"previousOwner","type":"address"},{"indexed":true,"internalType":"address","name":"newOwner","type":"address"}],"name":"OwnershipTransferred","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"uint256","name":"amount","type":"uint256"}],"name":"Receiving","type":"event"},{"anonymous":false,"inputs":[{"indexed":false,"internalType":"bool","name":"value","type":"bool"}],"name":"ShouldAuctionEnd","type":"event"},{"anonymous":false,"inputs":[{"indexed":true,"internalType":"address","name":"implementation","type":"address"}],"name":"Upgraded","type":"event"},{"inputs":[],"name":"checkIfAuctionShouldEnd","outputs":[{"internalType":"bool","name":"","type":"bool"}],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"getAuctionNo","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAuctionStartTime","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getAuctionState","outputs":[{"internalType":"uint8","name":"","type":"uint8"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getSupplyReserved","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"getTokenPrice","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"auctionNo","type":"uint256"}],"name":"getTokenPriceWithNo","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"auctionNo","type":"uint256"}],"name":"getTotalBidAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"uint256","name":"auctionNo","type":"uint256"}],"name":"getTotalBiddedAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"account","type":"address"}],"name":"getUserBidAmount","outputs":[{"internalType":"uint256","name":"","type":"uint256"}],"stateMutability":"view","type":"function"},{"inputs":[{"internalType":"address","name":"ketchupToken","type":"address"}],"name":"initialize","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"insertBid","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"owner","outputs":[{"internalType":"address","name":"","type":"address"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"proxiableUUID","outputs":[{"internalType":"bytes32","name":"","type":"bytes32"}],"stateMutability":"view","type":"function"},{"inputs":[],"name":"renounceOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"startAuction","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newOwner","type":"address"}],"name":"transferOwnership","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newImplementation","type":"address"}],"name":"upgradeTo","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[{"internalType":"address","name":"newImplementation","type":"address"},{"internalType":"bytes","name":"data","type":"bytes"}],"name":"upgradeToAndCall","outputs":[],"stateMutability":"payable","type":"function"},{"inputs":[],"name":"withdraw","outputs":[],"stateMutability":"nonpayable","type":"function"},{"inputs":[],"name":"withdrawAll","outputs":[],"stateMutability":"nonpayable","type":"function"},{"stateMutability":"payable","type":"receive"}]',
    'AuctionV1');

class AuctionV1 extends _i1.GeneratedContract {
  AuctionV1(
      {required _i1.EthereumAddress address,
      required _i1.Web3Client client,
      int? chainId})
      : super(_i1.DeployedContract(_contractAbi, address), client, chainId);

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> checkIfAuctionShouldEnd(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('checkIfAuctionShouldEnd');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getAuctionNo({_i1.BlockNum? atBlock}) async {
    final function = self.function('getAuctionNo');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getAuctionStartTime({_i1.BlockNum? atBlock}) async {
    final function = self.function('getAuctionStartTime');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getAuctionState({_i1.BlockNum? atBlock}) async {
    final function = self.function('getAuctionState');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getSupplyReserved({_i1.BlockNum? atBlock}) async {
    final function = self.function('getSupplyReserved');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getTokenPrice({_i1.BlockNum? atBlock}) async {
    final function = self.function('getTokenPrice');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getTokenPriceWithNo(BigInt auctionNo,
      {_i1.BlockNum? atBlock}) async {
    final function = self.function('getTokenPriceWithNo');
    final params = [auctionNo];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getTotalBidAmount(BigInt auctionNo,
      {_i1.BlockNum? atBlock}) async {
    final function = self.function('getTotalBidAmount');
    final params = [auctionNo];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getTotalBiddedAmount(BigInt auctionNo,
      {_i1.BlockNum? atBlock}) async {
    final function = self.function('getTotalBiddedAmount');
    final params = [auctionNo];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<BigInt> getUserBidAmount(_i1.EthereumAddress account,
      {_i1.BlockNum? atBlock}) async {
    final function = self.function('getUserBidAmount');
    final params = [account];
    final response = await read(function, params, atBlock);
    return (response[0] as BigInt);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> initialize(_i1.EthereumAddress ketchupToken,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('initialize');
    final params = [ketchupToken];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> insertBid(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('insertBid');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i1.EthereumAddress> owner({_i1.BlockNum? atBlock}) async {
    final function = self.function('owner');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i1.EthereumAddress);
  }

  /// The optional [atBlock] parameter can be used to view historical data. When
  /// set, the function will be evaluated in the specified block. By default, the
  /// latest on-chain block will be used.
  Future<_i2.Uint8List> proxiableUUID({_i1.BlockNum? atBlock}) async {
    final function = self.function('proxiableUUID');
    final params = [];
    final response = await read(function, params, atBlock);
    return (response[0] as _i2.Uint8List);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> renounceOwnership(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('renounceOwnership');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> startAuction(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('startAuction');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> transferOwnership(_i1.EthereumAddress newOwner,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('transferOwnership');
    final params = [newOwner];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> upgradeTo(_i1.EthereumAddress newImplementation,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('upgradeTo');
    final params = [newImplementation];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> upgradeToAndCall(
      _i1.EthereumAddress newImplementation, _i2.Uint8List data,
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('upgradeToAndCall');
    final params = [newImplementation, data];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdraw(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('withdraw');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// The optional [transaction] parameter can be used to override parameters
  /// like the gas price, nonce and max gas. The `data` and `to` fields will be
  /// set by the contract.
  Future<String> withdrawAll(
      {required _i1.Credentials credentials,
      _i1.Transaction? transaction}) async {
    final function = self.function('withdrawAll');
    final params = [];
    return write(credentials, transaction, function, params);
  }

  /// Returns a live stream of all AdminChanged events emitted by this contract.
  Stream<AdminChanged> adminChangedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('AdminChanged');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return AdminChanged(decoded);
    });
  }

  /// Returns a live stream of all BeaconUpgraded events emitted by this contract.
  Stream<BeaconUpgraded> beaconUpgradedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('BeaconUpgraded');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return BeaconUpgraded(decoded);
    });
  }

  /// Returns a live stream of all Initialized events emitted by this contract.
  Stream<Initialized> initializedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Initialized');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Initialized(decoded);
    });
  }

  /// Returns a live stream of all OwnershipTransferred events emitted by this contract.
  Stream<OwnershipTransferred> ownershipTransferredEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('OwnershipTransferred');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return OwnershipTransferred(decoded);
    });
  }

  /// Returns a live stream of all Receiving events emitted by this contract.
  Stream<Receiving> receivingEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Receiving');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Receiving(decoded);
    });
  }

  /// Returns a live stream of all ShouldAuctionEnd events emitted by this contract.
  Stream<ShouldAuctionEnd> shouldAuctionEndEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('ShouldAuctionEnd');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return ShouldAuctionEnd(decoded);
    });
  }

  /// Returns a live stream of all Upgraded events emitted by this contract.
  Stream<Upgraded> upgradedEvents(
      {_i1.BlockNum? fromBlock, _i1.BlockNum? toBlock}) {
    final event = self.event('Upgraded');
    final filter = _i1.FilterOptions.events(
        contract: self, event: event, fromBlock: fromBlock, toBlock: toBlock);
    return client.events(filter).map((_i1.FilterEvent result) {
      final decoded = event.decodeResults(result.topics!, result.data!);
      return Upgraded(decoded);
    });
  }
}

class AdminChanged {
  AdminChanged(List<dynamic> response)
      : previousAdmin = (response[0] as _i1.EthereumAddress),
        newAdmin = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress previousAdmin;

  final _i1.EthereumAddress newAdmin;
}

class BeaconUpgraded {
  BeaconUpgraded(List<dynamic> response)
      : beacon = (response[0] as _i1.EthereumAddress);

  final _i1.EthereumAddress beacon;
}

class Initialized {
  Initialized(List<dynamic> response) : version = (response[0] as BigInt);

  final BigInt version;
}

class OwnershipTransferred {
  OwnershipTransferred(List<dynamic> response)
      : previousOwner = (response[0] as _i1.EthereumAddress),
        newOwner = (response[1] as _i1.EthereumAddress);

  final _i1.EthereumAddress previousOwner;

  final _i1.EthereumAddress newOwner;
}

class Receiving {
  Receiving(List<dynamic> response) : amount = (response[0] as BigInt);

  final BigInt amount;
}

class ShouldAuctionEnd {
  ShouldAuctionEnd(List<dynamic> response) : value = (response[0] as bool);

  final bool value;
}

class Upgraded {
  Upgraded(List<dynamic> response)
      : implementation = (response[0] as _i1.EthereumAddress);

  final _i1.EthereumAddress implementation;
}
