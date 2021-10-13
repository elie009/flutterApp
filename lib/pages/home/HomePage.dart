import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryModel.dart';
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
      body: StreamProvider<List<CategoryModel>>.value(
        value: DatabaseService().getStreamMenu,
        initialData: null,
        child: Scaffold(
          body: BodyContainer(prefs: widget.prefs),
        ),
      ),
    );
  }
}
