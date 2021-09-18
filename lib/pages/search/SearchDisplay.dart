import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyObj.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'CardItem.dart';

class SearchDisplayPage extends StatefulWidget {
  String menuId;
  final SharedPreferences prefs;
  SearchDisplayPage({Key key, @required this.menuId, this.prefs})
      : super(key: key);

  @override
  _SearchDisplayPageState createState() => _SearchDisplayPageState();
}

class _SearchDisplayPageState extends State<SearchDisplayPage> {
  int counter = 3;

  @override
  Widget build(BuildContext context) {
    String propId = widget.menuId;
    print('>>>>> ' + propId);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Center(
            child: Text(
              "Item Carts",
              style: TextStyle(
                  color: Color(0xFF3a3737),
                  fontWeight: FontWeight.w600,
                  fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
          brightness: Brightness.light,
        ),
        body: StreamProvider<List<Property>>.value(
          value: DatabaseService().propery(propId),
          initialData: [],
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                SearchWidget(),
                Container(
                  padding: EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      PropertyCard(prefs: widget.prefs),
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
