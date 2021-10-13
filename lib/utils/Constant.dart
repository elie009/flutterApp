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

  static final collectionLot = 'lot';
  static final collectionRes = 'lot';

  static final String itemCard1img =
      'assets/images/bestfood/ic_best_food_8.jpeg';

  static String getConditionStr(int code) {
    return code == 1 ? 'NEW' : 'USED';
  }

  static Map<String, String> conditions = {
    'brandnew': 'Brand New',
    'likenew': 'Like New',
    'wellused': 'Well Used',
    'heavilyused': 'Heavily Used',
    'new': 'New',
    'used': 'Used',
    'preselling': 'Pre-Selling',
    'preowned': 'Pre-Owned',
    'foreclosed': 'Foreclosed',
  };

  static Map<String, String> dealmethod = {
    'meetup': 'Meet up',
    'delivery': 'Delivery',
  };

  static Map<String, String> termsDateCode = {
    'A01001': 'Hours',
    'A01002': 'Days',
    'A01003': 'Weeks',
    'A01004': 'Months',
    'A01005': 'Years',
    'A01006': 'Others',
  };

  static Map<String, String> furnishing = {
    'unfurnished': 'Unfurnished',
    'semifurnished': 'Semi Furnished',
    'fullyfurnished': 'Fully Furnished',
  };

 
}

class StrObj {
  String key;
  String value;
  String stat;
  StrObj({this.key, this.value, this.stat});
}
