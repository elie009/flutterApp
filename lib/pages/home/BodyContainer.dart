import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/BestFoodWidget.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:flutter_app/widgets/TopMenu/TopMenus.dart';

class BodyContainer extends StatefulWidget {
  BodyContainer({Key key}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BodyContainer();
}

class _BodyContainer extends State<BodyContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(children: <Widget>[
          SearchWidget(),
          TopMenus(),
          PopularFoodsWidget(),
          BestFoodWidget(),
        ]),
      ),
    );
  }
}
