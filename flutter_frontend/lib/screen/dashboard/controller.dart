import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_frontend/helper.dart';
import 'package:get/get.dart';

/// @note Right now we're only interested in localchain 1337 id
class DashboardController extends GetxController {
  TextEditingController auctionAddressEditingController =
      TextEditingController();
  TextEditingController tokenAddressEditingController = TextEditingController();

  String tokenAddress = kTokenAddress;
  String auctionAddress = kAuctionContractAddress;

  void clearAuctionAddress() => auctionAddressEditingController.clear();
  void clearTokenAddress() => tokenAddressEditingController.clear();
}
