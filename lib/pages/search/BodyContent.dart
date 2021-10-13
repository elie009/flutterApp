import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/widgets/card/ItemCard.dart';
import 'package:provider/provider.dart';

class BodyContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;
    var items = Provider.of<List<PropertyItemModel>>(context);
    items = items == null ? [] : items;
    return new Scaffold(
        body: new Container(
      child: new GridView.count(
        crossAxisCount: 2,
        childAspectRatio: itemWidth / 275,
        controller: new ScrollController(keepScrollOffset: false),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: items.map((PropertyItemModel i) {
          return ItemCard(props: i);
        }).toList(),
      ),
    ));
  }
}
