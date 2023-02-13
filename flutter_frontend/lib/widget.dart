import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'style.dart';

Widget textLayout(
  String title,
  Rx rxBody, {
  TextStyle? headingStyle,
  TextStyle? bodyStyle,
  VoidCallback? onTap,
}) {
  return Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        SelectableText.rich(
          TextSpan(
            text: title,
            recognizer:
                onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
          ),
          style: headingStyle ?? headingTextStyle,
        ),
        Obx(
          () => SelectableText(
            rxBody.value,
            style: bodyStyle ?? bodyTextStyle,
          ),
        )
      ],
    ),
  );
}

/// Vertical layout button with title
Widget customIconButton(
  String title,
  Widget icon, {
  required VoidCallback? onPressed,
}) {
  return Column(
    children: [
      IconButton(onPressed: onPressed, icon: icon, tooltip: title),
      Text(title)
    ],
  );
}
