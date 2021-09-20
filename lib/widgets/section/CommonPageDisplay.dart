import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/BodyContent.dart';

class CommonPageDisplay extends StatefulWidget {
  final dynamic body;
  CommonPageDisplay({this.body});
  @override
  _CommonPageDisplayState createState() => _CommonPageDisplayState();
}

class _CommonPageDisplayState extends State<CommonPageDisplay> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          Expanded(
            child: widget.body,
          )
        ],
      ),
    );
  }
}
