import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

class Button1 extends StatelessWidget {
  final String label;

  Button1(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: 100.0,
        height: 35.0,
        decoration: BoxDecoration(
          color: primaryColor,
          border: Border.all(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(5.0),
        ),
        child: Center(
          child: Text(
            label,
            style: new TextStyle(
                fontSize: 12.0,
                color: Colors.white,
                fontWeight: FontWeight.w300),
          ),
        ));
  }
}
