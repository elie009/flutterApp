import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/home/BodyContent.dart';
import 'package:flutter_app/pages/home/topmenu/TopMenus.dart';
import 'package:flutter_app/widgets/section/SearchWidget.dart';
import 'package:flutter_app/widgets/section/CommonPageDisplay.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BodyContainer extends StatefulWidget {
  final SharedPreferences prefs;
  BodyContainer({Key key, this.prefs}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BodyContainer();
}

class _BodyContainer extends State<BodyContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SearchWidget(),
        TopMenus(),
        Expanded(
            child: Container(
          height: 400,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(child: CommonPageDisplay(body: BodyContent())),
            ],
          ),
        ))
      ]),
    );
  }
}
