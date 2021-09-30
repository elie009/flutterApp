import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class FormComplete extends StatefulWidget {
  var inputdata = List<MapData>();
  var inputSale = List<MapData>();
  var inputRent = List<MapData>();
  FormComplete(this.inputdata, this.inputSale, this.inputRent);

  @override
  State<StatefulWidget> createState() {
    return FormCompleteState();
  }
}

class FormCompleteState extends State<FormComplete> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Align(
            alignment: Alignment.topLeft,
            child: TextLabelFade(
                text: "Main Details",
                style: TextStyle(
                    fontSize: 17,
                    color: primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          for (MapData data in widget.inputdata)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    data.label + " : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Text(data.value, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.topLeft,
            child: TextLabelFade(
                text: "Sale Details",
                style: TextStyle(
                    fontSize: 17,
                    color: primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          for (MapData data in widget.inputSale)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    data.label + " : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Text(data.value, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.topLeft,
            child: TextLabelFade(
                text: "Rental Details",
                style: TextStyle(
                    fontSize: 17,
                    color: primaryColor,
                    fontWeight: FontWeight.bold)),
          ),
          for (MapData data in widget.inputRent)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Text(
                    data.label + " : ",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Text(data.value, style: TextStyle(fontSize: 16)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
