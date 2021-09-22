import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/utils/Utils.dart';

import '../PopupOffer.dart';

class ItemMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Column(children: <Widget>[
            IconButton(
              onPressed: () {
                Navigator.push(context, ScaleRoute(page: BookingPage()));
              },
              icon: Icon(Icons.access_time),
              color: primaryColor,
              iconSize: 30,
            ),
            Text(
              "Book",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            )
          ]),
          SizedBox(
            width: 30,
          ),
          PopupOffer(),
          SizedBox(
            width: 30,
          ),
          Column(children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.message_outlined),
              color: primaryColor,
              iconSize: 30,
            ),
            Text(
              "Message",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            )
          ]),
          SizedBox(
            width: 30,
          ),
          Column(children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.save_alt),
              color: primaryColor,
              iconSize: 30,
            ),
            Text(
              "Save",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            )
          ]),
          SizedBox(
            width: 30,
          ),
          Column(children: <Widget>[
            IconButton(
              onPressed: () {},
              icon: Icon(Icons.emoji_flags_outlined),
              color: primaryColor,
              iconSize: 30,
            ),
            Text(
              "Follow",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            )
          ]),
        ],
      ),
    );
  }
}
