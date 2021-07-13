import 'package:flutter/material.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/home/HomePage.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BottomNavBarWidget extends StatefulWidget {
  @override
  _BottomNavBarWidgetState createState() => _BottomNavBarWidgetState();
}

class _BottomNavBarWidgetState extends State<BottomNavBarWidget> {
  int currentIndex = 0;
  List<Widget> pages;
  Widget currentPage;
  HomePage homePage;
  FoodDetailsPage foodDetailsPage;
  FoodOrderPage foodOrderPage;
  ProfilePage profilePage;

  @override
  void initState() {
    super.initState();
    homePage = HomePage();
    foodDetailsPage = FoodDetailsPage();
    foodOrderPage = FoodOrderPage();
    profilePage = ProfilePage();
    pages = [homePage, foodDetailsPage, foodOrderPage, profilePage];
    currentPage = homePage;
  }

  @override
  Widget build(BuildContext context) {
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
        onTap: (int index) {
          setState(() {
            currentPage = pages[index];
          });
        },
      ),
      body: currentPage,
    );
  }
}
