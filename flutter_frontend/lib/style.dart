import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class Style {
  static final headingTextStyle = TextStyle(fontSize: 20);

  static final bodyTextStyle =
      const TextStyle(fontWeight: FontWeight.bold, fontSize: 30);

  TextTheme textTheme = TextTheme(bodyText1: bodyTextStyle);
}
