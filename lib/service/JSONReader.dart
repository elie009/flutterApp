import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_app/model/UserModel.dart';

class JSONReader {
  String JSONlocation = "";

  static Future<void> readJson() async {
    final String response =
        await rootBundle.loadString('assets/demodata/userJSON.json');
    final data = await json.decode(response);
  }
}
