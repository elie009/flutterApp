import 'dart:ui';

import 'package:flutter/material.dart';

final primaryColor = Color(0xFFfd2c2c);
final whiteColor = Colors.white;
final shadeWhite = Colors.grey.shade200;
final grayColor = Color(0xFFa4a1a1);
final lightgrayColor = Colors.grey.shade300;
final blackColor = Colors.black;
final linkColor = Colors.blueAccent;
final yellowamber = Colors.amber;

final String defaultProfileImg = 'assets/images/profile/profile.jpeg';

String doubleToString(String number) {
  return number.toString();
}

double widthScreen(BuildContext context) {
  return MediaQuery.of(context).size.width;
}

class Constants {
  static final String lotCode = '1001';
  static final String resCode = '1002';

  static final String itemCard1img =
      'assets/images/bestfood/ic_best_food_8.jpeg';

  static String getConditionStr(int code) {
    return code == 1 ? 'NEW' : 'USED';
  }

  static final collectionLot = 'lot';

  static List<StrObj> termsDateCode = [
    StrObj(key: '1', value: 'for entile lot'),
    StrObj(key: '2', value: 'per sqm'),
    StrObj(key: '3', value: 'per hectares'),
    StrObj(key: '4', value: 'other options'),
  ];

  static String convertTermsCodeToDate(String code) {
    String resultValue = '';
    termsDateCode.forEach((element) {
      if (element.key == code) resultValue = element.value;
    });
    return resultValue;
  }
}

class StrObj {
  String key;
  String value;
  StrObj({this.key, this.value});
}
