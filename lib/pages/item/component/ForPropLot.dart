import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/section/IconText.dart';

class ForPropResidence extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Column(children: [
        SizedBox(height: 20),
        IconText(
            text: "Lot area by sqm",
            value: "200",
            icon: Icons.label_important_outline),
        SizedBox(height: 20),
        IconText(
            text: "Floor area by sqm",
            value: "100",
            icon: Icons.label_important_outline),
        SizedBox(height: 20),
        IconText(
            text: "Bedrooms", value: "4", icon: Icons.label_important_outline),
        SizedBox(height: 20),
        IconText(
            text: "Bathrooms", value: "3", icon: Icons.label_important_outline),
        SizedBox(height: 20),
        IconText(
            text: "Car Space", value: "2", icon: Icons.label_important_outline),
        SizedBox(height: 20),
      ]),
    );
  }
}
