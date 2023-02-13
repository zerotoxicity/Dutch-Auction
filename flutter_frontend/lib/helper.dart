// Helper Functions

import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Converts bigint to readable of 5 decimal place precision
/// e.g. 0.20000
String bigIntToString(BigInt bi, {placement = 1e18, int fractions = 4}) {
  assert(placement > 1, "must be more than 1");
  return (bi.toDouble() / placement).toStringAsFixed(fractions);
}

const String kChainlinkGoerliAddress =
    "0xA39434A63A52E749F02807ae27335515BA4b07F7";

const String kTokenAddress = "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512";
const String kAuctionContractAddress =
    "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9";

const String kRPCURL = "http://127.0.0.1:8545/";

const Map<int, String> kAuctionState = {
  -1: "NOT FOUND",
  0: "ONGOING",
  1: "CLOSED",
  2: "CLOSING",
};

const int kAuctionDuration = 5;

/// Run once every *n* seconds
const int kBackgroundPeriod = 5;
const int kConfirmationBlocks = 1;

const kPrivateKey =
    "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

/// Convert timestamp to human readable string
String convertTimestampToReadable(int timestamp) {
  print("Debug timestamp: $timestamp");
  if (timestamp <= 0) return "not available";
  final _dt = DateTime.fromMillisecondsSinceEpoch(timestamp);
  return DateFormat("dd/MM/yyyy HH:mm ").format(_dt);
  // return "${_dt.day}/${_dt.month}/${_dt.year}";
}

/// Calculate time difference in timestamp
int calculateTimeDifferenceFromNow(int v) {
  final duration = DateTime.now().difference(
    DateTime.fromMillisecondsSinceEpoch(v * 1000),
  );
  return duration.inSeconds;
}

void debugPrint(String printValue) {
  if (kDebugMode) {
    print(printValue);
  }
}

/// Show progress indicator when fetching async data
void showProgressIndicator(BuildContext context, bool isLoading,
    {String? title}) {
  print("showProgressIndicator() called. isLoading: $isLoading");
  if (isLoading) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext c) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator.adaptive(),
                Text(title ?? "Loading"),
              ],
            ),
          );
        });
  } else {
    Navigator.of(context).pop();
  }
}

Color auctionStateColor(int state) {
  if (state == 0) return Colors.greenAccent; // Active
  if (state == 1) return Colors.blue; // Closed
  if (state == 2) return Colors.lightBlue; // Closing
  return Colors.grey; // Unknownr
}
