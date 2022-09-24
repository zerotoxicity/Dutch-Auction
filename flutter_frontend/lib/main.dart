import 'package:flutter/material.dart';
import 'package:flutter_frontend/controller.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/route_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  LoginPage({Key? key}) : super(key: key);

  final AuthController c = AuthController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(),
      body: Center(
        child: Column(children: [
          Obx(() => SelectableText(
              c.isConnected.value ? c.currentAddress.value : "Not connected")),
          const SizedBox(height: 10),
          ElevatedButton(
              onPressed: () async {
                print("Button pressed");
                await c.connect();
              },
              child: Obx(
                () => Text(c.isConnected.value ? "Disconnect" : "Connect"),
              ))
        ]),
      ),
    );
  }
}
