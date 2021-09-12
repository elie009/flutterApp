import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/BestFoodWidget.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:flutter_app/widgets/TopMenu/TopMenus.dart';
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
      child: SingleChildScrollView(
        child: Column(children: <Widget>[
          SearchWidget(prefs: widget.prefs),
          TopMenus(prefs: widget.prefs),
          PopularFoodsWidget(prefs: widget.prefs),
          BestFoodWidget(prefs: widget.prefs),
        ]),
      ),
    );
  }
}
