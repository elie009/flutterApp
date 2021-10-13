import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/pages/search/SearchDisplay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card/ItemCard.dart';

class PopularFoodsWidget extends StatefulWidget {
  final SharedPreferences prefs;
  PopularFoodsWidget({this.prefs});
  @override
  _PopularFoodsWidgetState createState() => _PopularFoodsWidgetState();
}

class _PopularFoodsWidgetState extends State<PopularFoodsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          PopularFoodTitle(),
          Expanded(
            child: PopularFoodItems(),
          )
        ],
      ),
    );
  }
}

class PopularFoodTitle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Popluar",
            style: TextStyle(
                fontSize: 20,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w300),
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  ScaleRoute(
                      page: SearchDisplayPage(
                    menuId: '1001',
                  )));
            },
            child: Text(
              "See all",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w100),
            ),
          ),
        ],
      ),
    );
  }
}

class PopulateList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var items = Provider.of<List<PropertyItemModel>>(context);
    items = items == null ? [] : items;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: items.map((PropertyItemModel i) {
        return ItemCard(props: i);
      }).toList(),
    );
  }
}

class PopularFoodItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamProvider<List<PropertyItemModel>>.value(
      value: DatabaseServiceItems().getAll(),
      initialData: null,
      child: PopulateList(),
    ));
  }
}
