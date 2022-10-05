import 'dart:io';

void main() {
  var file = File("./abi/IAuctionInterface.abi.json");

  var result = file.readAsStringSync();

  print("Result: $result");
}
