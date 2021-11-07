import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/utils/Constant.dart';

class SellerStat extends StatelessWidget {
  final UserBaseModel user;
  SellerStat({@required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350.0,
      height: 60.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(
            children: <Widget>[
              Text(
                user.post,
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Post",
                style: TextStyle(
                  color: grayColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          VerticalDivider(
            width: 70.0,
            color: primaryColor,
          ),
          Column(
            children: <Widget>[
              Text(
                '0',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Rating",
                style: TextStyle(
                  color: grayColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          VerticalDivider(
            width: 70.0,
            color: primaryColor,
          ),
          Column(
            children: <Widget>[
              Text(
                '0',
                style: TextStyle(
                  color: primaryColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Response",
                style: TextStyle(
                  color: grayColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
