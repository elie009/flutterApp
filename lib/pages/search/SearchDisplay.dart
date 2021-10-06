import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/database/items/DatabaseServiceProps.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/pages/search/BodyContainer.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final AuthService _auth = AuthService();

    return Scaffold(
      body: StreamProvider<List<PropertyItemModel>>.value(
        value: DatabaseServiceProps().getByMenu('1001'),
        initialData: null,
        child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              backgroundColor: Color(0xFFFAFAFA),
              elevation: 0,
              title: Text(
                "What would you like to eat?",
                style: TextStyle(
                    color: Color(0xFF3a3737),
                    fontSize: 16,
                    fontWeight: FontWeight.w500),
              ),
              brightness: Brightness.light,
            ),
            body: BodyContainer()),
      ),
    );
  }
}
