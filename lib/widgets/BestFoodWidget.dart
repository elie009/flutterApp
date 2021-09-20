import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/BodyContent.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BestFoodWidget extends StatefulWidget {
  final SharedPreferences prefs;
  BestFoodWidget({this.prefs});
  @override
  _BestFoodWidgetState createState() => _BestFoodWidgetState();
}

class _BestFoodWidgetState extends State<BestFoodWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: BodyContent(),
          )
        ],
      ),
    );
  }
}
