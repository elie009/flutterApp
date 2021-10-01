import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/search/BodyContent.dart';
import 'package:flutter_app/widgets/section/SearchWidget.dart';
import 'package:flutter_app/widgets/section/CommonPageDisplay.dart';

class BodyContainer extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _BodyContainer();
}

class _BodyContainer extends State<BodyContainer> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(children: [
        SearchWidget(),
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
