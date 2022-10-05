import 'package:flutter/material.dart';
import 'package:flutter_frontend/web3_controller.dart';
import 'package:flutter_frontend/screen/dashboard/screen.dart';
import 'package:flutter_frontend/unknown_screen.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ketchup Auction',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginPage(),
      unknownRoute:
          GetPage(name: "/unknown", page: () => const UnknownScreen()),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final Web3Controller c = Get.put(Web3Controller());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        actions: [
          ElevatedButton(
              onPressed: () {
                c.connect().then((_) async {
                  const GetSnackBar(
                    title: "Authentication",
                    message: "Login successfully!",
                    duration: Duration(seconds: 2),
                  ).show();
                  await Get.offAll(DashboardScreen());
                });
              },
              child: Obx(
                () => Text(c.isConnected.value ? "Disconnect" : "Connect"),
              ))
        ],
      ),
      body: Center(
        child: Obx(() => SelectableText(
            c.isConnected.value ? c.currentAddress.value : "Not connected")),
      ),
    );
  }
}
