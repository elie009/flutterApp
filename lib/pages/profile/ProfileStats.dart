import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

class ProfileStats extends StatelessWidget {
  final int follower;
  final int following;
  final int post;
  ProfileStats(
      {@required this.follower, @required this.following, @required this.post});

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
                follower.toString(),
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Follower",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VerticalDivider(
            width: 70.0,
            color: whiteColor,
          ),
          Column(
            children: <Widget>[
              Text(
                following.toString(),
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 22.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 2.0,
              ),
              Text(
                "Following",
                style: TextStyle(
                  color: whiteColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          VerticalDivider(
            width: 70.0,
            color: whiteColor,
          ),
          Column(
            children: <Widget>[
              Text(
                post.toString(),
                style: TextStyle(
                  color: whiteColor,
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
                  color: whiteColor,
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
