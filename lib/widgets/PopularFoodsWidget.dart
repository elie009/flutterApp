import 'package:flutter/material.dart';
import 'package:flutter_app/animation/RotationRoute.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/search/SearchDisplay.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card/ItemCard.dart';

class PopularFoodsWidget extends StatefulWidget {
  final SharedPreferences prefs;
  PopularFoodsWidget({this.prefs});
  @override
  _PopularFoodsWidgetState createState() => _PopularFoodsWidgetState();
}

class _PopularFoodsWidgetState extends State<PopularFoodsWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 350,
      width: double.infinity,
      child: Column(
        children: <Widget>[
          PopularFoodTitle(prefs: widget.prefs),
          Expanded(
            child: PopularFoodItems(),
          )
        ],
      ),
    );
  }
}

class PopularFoodTitle extends StatelessWidget {
  final SharedPreferences prefs;
  PopularFoodTitle({this.prefs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            "Popluar Foods",
            style: TextStyle(
                fontSize: 20,
                color: Color(0xFF3a3a3b),
                fontWeight: FontWeight.w300),
          ),
          GestureDetector(
            onTap: () {
              print('test home');
              Navigator.push(
                  context,
                  ScaleRoute(
                      page: SearchDisplayPage(
                    menuId: '1001',
                    prefs: prefs,
                  )));
            },
            child: Text(
              "See all",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w100),
            ),
          ),
        ],
      ),
    );
  }
}

class PopularFoodItems extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: <Widget>[
        ItemCard(
            title: "Lot for sale",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: '150000000.00',
            numberOflikes: '9',
            numberOfdislikes: '1',
            numberOfComment: '13',
            location: "Talisay City, Cebu"),
        ItemCard(
            title: "Yuta data data",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "6500.00",
            numberOflikes: "4",
            numberOfdislikes: "0",
            numberOfComment: '5',
            location: "Lapu-Lapu City, Cebu"),
        ItemCard(
            title: "For assume Casa mira south",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "500000.00",
            numberOflikes: "4",
            numberOfdislikes: "0",
            numberOfComment: '5',
            location: "Naga City, Cebu"),
        ItemCard(
            title: "Lot for rent per SQM",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "50.00",
            numberOflikes: "6",
            numberOfdislikes: "1",
            numberOfComment: '5',
            location: "Lapu-Lapu City, Cebu"),
        ItemCard(
            title: "House and lot for assume",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "300000.00",
            numberOflikes: "2",
            numberOfdislikes: "2",
            numberOfComment: '3',
            location: "Lapu-Lapu City, Cebu"),
        ItemCard(
            title: "Baratu nga yuta data-data",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "3500.00",
            numberOflikes: "1",
            numberOfdislikes: "0",
            numberOfComment: '2',
            location: "Balamban, Cebu"),
        ItemCard(
            title: "House for Rent",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "12000.00",
            numberOflikes: "12",
            numberOfdislikes: "1",
            numberOfComment: '15',
            location: "Cebu City, Cebu"),
        ItemCard(
            title: "Condo dool sa ayala center",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "3000000.00",
            numberOflikes: "0",
            numberOfdislikes: "0",
            numberOfComment: '0',
            location: "Cebu City, Cebu"),
        ItemCard(
            title: "House and lot",
            imageUrl: "assets/images/popular_foods/ic_popular_food_3.png",
            price: "2500000.00",
            numberOflikes: "8",
            numberOfdislikes: "0",
            numberOfComment: '10',
            location: "Lapu-Lapu City, Cebu"),
      ],
    );
  }
}
