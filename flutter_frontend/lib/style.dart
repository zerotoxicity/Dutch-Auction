import 'package:flutter/material.dart';

class Style {
  static TextTheme textTheme = const TextTheme(bodyText1: bodyTextStyle);

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    shape: const StadiumBorder(),
  );
}

const headingTextStyle = TextStyle(fontSize: 20);
const bodyTextStyle = TextStyle(fontWeight: FontWeight.bold, fontSize: 30);
