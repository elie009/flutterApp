import 'package:flutter/cupertino.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/widgets/card/ItemCard.dart';

class SuggetItem extends StatelessWidget {
  List<PropertyItemModel> similaritem;
  SuggetItem({this.similaritem});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    final double itemWidth = size.width / 2;

    return Column(
      children: [
        Align(
          alignment: Alignment.topLeft,
          child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Suggested For You',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              )),
        ),
        new GridView.count(
          crossAxisCount: 2,
          childAspectRatio: itemWidth / 275,
          controller: new ScrollController(keepScrollOffset: false),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          children: similaritem.map((PropertyItemModel i) {
            return ItemCard(props: i);
          }).toList(),
        ),
      ],
    );
  }
}
