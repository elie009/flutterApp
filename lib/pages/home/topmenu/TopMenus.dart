import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/pages/search/BodyContainer.dart';
import 'package:flutter_app/pages/search/SearchDisplay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopMenus extends StatefulWidget {
  @override
  _TopMenusState createState() => _TopMenusState();
}

class _TopMenusState extends State<TopMenus> {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<MenuModel>>(context);

    return Container(
        height: 100,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            if (items != null)
              for (var i in items)
                TopMenuTiles(
                  name: i.name,
                  imageUrl: "ic_burger",
                  slug: "",
                )
          ],
        ));
  }
}

class TopMenuTiles extends StatelessWidget {
  String name = 'Burger';
  String imageUrl = 'ic_burger';
  String slug = '';

  // final ItemModel items;
  // TopMenuTiles({this.items});

  TopMenuTiles({
    Key key,
    @required this.name,
    @required this.imageUrl,
    @required this.slug,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        print('this top menu item');
        Navigator.push(context, ScaleRoute(page: BodyContainer()));
      },
      child: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: new BoxDecoration(boxShadow: [
              new BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 25.0,
                offset: Offset(0.0, 0.75),
              ),
            ]),
            child: Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(3.0),
                  ),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  child: Center(
                      child: Image.asset(
                    'assets/images/topmenu/' + imageUrl + ".png",
                    width: 24,
                    height: 24,
                  )),
                )),
          ),
          Text(name,
              style: TextStyle(
                  color: Color(0xFF6e6e71),
                  fontSize: 14,
                  fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
