import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/src/items/view/unitSeller/SellerStat.dart';

class SellerInfo extends StatelessWidget {
  //final String uid;
  final UserBaseModel user;
  SellerInfo({this.user});

  @override
  Widget build(BuildContext context) {
    return user != null
        ? Container(
            margin: const EdgeInsets.only(left: 20.0, right: 20.0, top: 30),
            child: Column(children: [
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "Meet The Seller",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Container(
                      width: 80,
                      height: 80,
                      child: user.image.isEmpty
                          ? Image.asset(
                              "assets/images/popular_foods/ic_popular_food_4.png",
                            )
                          : Image.network(
                              user.image,
                              fit: BoxFit.fitWidth,
                            ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        user.location,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 10),
              SellerStat(user: user),
            ]))
        : Container();
  }
}
