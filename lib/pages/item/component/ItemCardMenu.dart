import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/pages/message/inspector/ChatInspector.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:provider/provider.dart';

import '../PopupOffer.dart';

class ItemCardMenu extends StatelessWidget {
  final PropertyModel props;
  ItemCardMenu({@required this.props});
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

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
              onPressed: () {
                chatInspector(user, props, context);
              },
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
