import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/pages/search/BodyContainer.dart';
import 'package:flutter_app/pages/search/SearchDisplay.dart';
import 'package:flutter_app/widgets/card/SmallItemCard.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopMenus extends StatefulWidget {
  @override
  _TopMenusState createState() => _TopMenusState();
}

class _TopMenusState extends State<TopMenus> {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<CategoryModel>>(context);

    return Container(
        height: 90,
        child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            if (items != null)
              for (var i in items)
                SmallItemCard(
                  category: i,
                  onChanged: (String menuid) {
                    setState(() {
                      Navigator.push(
                          context,
                          ScaleRoute(
                              page: SearchDisplayPage(
                            menuId: menuid,
                          )));
                    });
                  },
                )
          ],
        ));
  }
}

class TopMenuTiles extends StatelessWidget {
  String name = 'Burger';
  String imageUrl = 'ic_burger';
  String slug = '';
  CategoryModel menu;

  TopMenuTiles({
    Key key,
    @required this.menu,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        //Navigator.push(context, ScaleRoute(page: BodyContainer()));
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
