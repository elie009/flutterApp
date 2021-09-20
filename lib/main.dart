import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/home/HomePage.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/pages/authentication/SignUpPage.dart';
import 'package:flutter_app/pages/wrapper.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/UserModel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;
  MyApp({this.prefs});
  @override
  Widget build(BuildContext context) {
    return StreamProvider<UserBaseModel>.value(
      value: AuthService().user,
      initialData: null,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'Roboto', hintColor: Color(0xFFd0cece)),
        home: Wrapper(prefs: prefs),
      ),
    );
  }
}
