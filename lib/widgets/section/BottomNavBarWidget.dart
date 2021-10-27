import 'package:circle_bottom_navigation/circle_bottom_navigation.dart';
import 'package:circle_bottom_navigation/widgets/tab_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/home/HomePage.dart';
import 'package:flutter_app/pages/message/inbox/HomeMessagePage.dart';
import 'package:flutter_app/pages/posting/PostingPage.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBarWidget extends StatefulWidget {
  final SharedPreferences prefs;
  const BottomNavBarWidget({Key key, this.prefs}) : super(key: key);
  @override
  _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int currentPage = 0;
  final double barHeight = 50;
  final double circleSize = 50;
  final double fontSize = 12;
  final double iconSize = 25;

  @override
  Widget build(BuildContext context) {
    final List<Widget> _pages = [
      HomePage(),
      FoodDetailsPage(),
      PostingPage(),
      HomeMessagePage(prefs: widget.prefs),
      ProfilePage(prefs: widget.prefs)
    ];
    return Scaffold(
      body: _pages[currentPage],
      bottomNavigationBar: CircleBottomNavigation(
        circleColor: primaryColor,
        barHeight: barHeight,
        circleSize: circleSize,
        initialSelection: currentPage,
        inactiveIconColor: Colors.grey,
        textColor: Colors.black,
        //hasElevationShadows: false,
        tabs: [
          TabData(
            icon: Icons.home_outlined,
            iconSize: iconSize,
            title: 'Home',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          TabData(
            icon: Icons.assignment_turned_in_outlined,
            iconSize: iconSize,
            title: 'Interest',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          TabData(
            icon: Icons.attach_money,
            iconSize: iconSize,
            title: 'Trade',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          TabData(
            icon: Icons.message_outlined,
            iconSize: iconSize,
            title: 'Message',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
          TabData(
            icon: FontAwesomeIcons.user,
            iconSize: iconSize,
            title: 'Account',
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ],
        onTabChangedListener: (index) => setState(() {
          currentPage = index;
        }),
      ),
    );
  }
}
