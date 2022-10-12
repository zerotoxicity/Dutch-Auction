import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'style.dart';

Widget textLayout(
  String title,
  Rx rxBody, {
  TextStyle? headingStyle,
  TextStyle? bodyStyle,
}) {
  return Container(
    margin: const EdgeInsets.all(8),
    padding: const EdgeInsets.all(8),
    child: Column(
      children: [
        SelectableText(
          title,
          style: headingStyle ?? Style.headingTextStyle,
        ),
        Obx(
          () => SelectableText(
            rxBody.value,
            style: bodyStyle ?? Style.bodyTextStyle,
          ),
        )
      ],
    ),
  );
}
