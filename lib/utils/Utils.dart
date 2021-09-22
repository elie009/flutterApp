import 'dart:ui';

import 'package:flutter/material.dart';

final primaryColor = Color(0xFFfd2c2c);
final whiteColor = Colors.white;
final grayColor = Color(0xFFa4a1a1);
final lightgrayColor = Colors.grey.shade300;
final blackColor = Colors.black;
final linkColor = Colors.blueAccent;

String doubleToString(String number) {
  return number.toString();
}

double widthScreen(BuildContext context) {
  return MediaQuery.of(context).size.width;
}
