import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/home/HomePage.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/widgets/BottomNavBarWidget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Wrapper extends StatelessWidget {
  final SharedPreferences prefs;
  Wrapper({this.prefs});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserModel>(context);
    if (user == null) {
      return SignInPage(prefs: prefs);
    } else {
      return BottomNavBarWidget(prefs: prefs);
    }
  }
}
