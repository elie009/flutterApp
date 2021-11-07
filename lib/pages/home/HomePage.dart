import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/home/BodyContainer.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Scaffold(
      body: StreamProvider<List<CategoryModel>>.value(
        value: DatabaseCategory().getAllCategory,
        initialData: null,
        child: Scaffold(
          body: BodyContainer(user: user),
        ),
      ),
    );
  }
}
