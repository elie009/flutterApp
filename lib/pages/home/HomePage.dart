import 'package:flutter/material.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/pages/home/BodyContainer.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  final SharedPreferences prefs;
  const HomePage({Key key, this.prefs}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamProvider<List<MenuModel>>.value(
        value: DatabaseService().getStreamMenu,
        initialData: null,
        child: Scaffold(
          appBar: AppBar(
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
            actions: <Widget>[
              IconButton(
                  icon: Icon(
                    Icons.notifications_none,
                    color: Color(0xFF3a3737),
                  ),
                  onPressed: () async {
                    await _auth.signOut();
                  })
            ],
          ),
          body: BodyContainer(prefs: widget.prefs),
        ),
      ),
    );
  }
}
