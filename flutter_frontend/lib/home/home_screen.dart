import 'package:flutter/material.dart';
import 'package:flutter_frontend/home/home_controller.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:get/get.dart';

import '../helper.dart';

// Shows the current ICO activities, login required
class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final controller = HomeController();
  final Web3Controller web3Controller = Get.find<Web3Controller>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: [
          FutureBuilder<BigInt>(
              future: web3Controller.getNativeTokenBalance(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator.adaptive();
                }
                if (snapshot.hasData) {
                  print("result: ${snapshot.data}");
                  return Center(
                      child: Text("Eth: ${bigIntToInt(snapshot.data!)}"));
                }
                return Container();
              }),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              print("Sign out");
            },
          )
        ],
      ),
      body: Center(
          child: Column(
        children: [],
      )),
    );
  }
}
