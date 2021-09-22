import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/card/ItemCard.dart';
import 'package:flutter_app/widgets/card/LargeItemCard.dart';
import 'package:provider/provider.dart';

class BodyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    final items = Provider.of<List<PropertyModel>>(context);
    return new Scaffold(
        body: new Container(
      child: new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: itemWidth / 275,
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: items.map((PropertyModel i) {
          return ItemCard(props: i);
        }).toList(),
      ),
    ));
  }
}
