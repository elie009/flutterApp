import 'package:flutter/material.dart';
import 'package:flutter_app/model/item_model.dart';
import 'package:flutter_app/pages/home/BodyContainer.dart';
import 'package:flutter_app/service/auth.dart';
import 'package:flutter_app/service/database.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamProvider<List<ItemModel>>.value(
        value: DatabaseService().items,
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
          body: BodyContainer(),
        ),
      ),
    );
  }
}
