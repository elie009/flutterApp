import 'package:flutter/material.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/home/HomePage.dart';
import 'package:flutter_app/pages/message/inbox/HomeMessagePage.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavBarWidget extends StatefulWidget {
  final SharedPreferences prefs;
  const BottomNavBarWidget({Key key, this.prefs}) : super(key: key);
  @override
  _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int _selectedIndex = 0;
  List<Widget> pages;
  Widget currentPage;
  HomePage homePage;
  FoodDetailsPage nearByLocationPage;
  HomeMessagePage messagePage;

  FoodOrderPage foodOrderPage;
  ProfilePage profilePage;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      currentPage = pages[index];
    });
  }

  @override
  void initState() {
    super.initState();
    print(widget.prefs);
    homePage = HomePage();
    nearByLocationPage = FoodDetailsPage();
    messagePage = HomeMessagePage(prefs: widget.prefs);
    foodOrderPage = FoodOrderPage();
    profilePage = ProfilePage(prefs: widget.prefs);
    pages = [
      homePage,
      nearByLocationPage,
      messagePage,
      foodOrderPage,
      profilePage
    ];
    currentPage = homePage;
  }

  @override
  Widget build(BuildContext context) {
    print('BottomNavBarWidget');
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            title: Text(
              'Home',
              style: TextStyle(color: Color(0xFF2c2b2b)),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            title: Text(
              'Near By',
              style: TextStyle(color: Color(0xFF2c2b2b)),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            title: Text(
              'Message',
              style: TextStyle(color: Color(0xFF2c2b2b)),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            title: Text(
              'Cart',
              style: TextStyle(color: Color(0xFF2c2b2b)),
            ),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.user),
            title: Text(
              'Account',
              style: TextStyle(color: Color(0xFF2c2b2b)),
            ),
          ),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
        currentIndex: _selectedIndex,
      ),
      body: currentPage,
    );
  }
}
