import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/profile/inventory/InventoryPage.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:provider/provider.dart';

class PostingPage extends StatefulWidget {
  @override
  PostingPageState createState() => new PostingPageState();
}

class PostingPageState extends State<PostingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFAFAFA),
        elevation: 0,
        brightness: Brightness.light,
        actions: <Widget>[
          IconButton(
              icon: Icon(
                Icons.business_center,
                color: Color(0xFF3a3737),
              ),
              onPressed: () {})
        ],
      ),
      body: Container(
        color: whiteColor,
        child: Inventory(),
      ),
    );
  }
}

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Center(
      child: StreamProvider<List<PropertyItemModel>>.value(
        value: DatabaseServiceItems().getByUid(user.uid),
        initialData: [],
        child: Container(
          child: Column(
            children: <Widget>[
              InventoryPage(isPosting: true),
            ],
          ),
        ),
      ),
    );
  }
}
