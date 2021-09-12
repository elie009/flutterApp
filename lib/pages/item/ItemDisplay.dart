import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/object/ChatHandlerObj.dart';
import 'package:flutter_app/object/ProperyObj.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/pages/item/CarouselSlider.dart';
import 'package:flutter_app/pages/item/PopupOffer.dart';
import 'package:flutter_app/pages/message/ChatInquire.dart';
import 'package:flutter_app/pages/message/MessagePage.dart';
import 'package:flutter_app/pages/message/RegistrationHandler.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:flutter_app/widgets/BottomNavBarWidget.dart';
import 'package:flutter_app/widgets/FoodDetailsSlider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ItemDetailsPage extends StatefulWidget {
  Property props;
  final SharedPreferences prefs;
  ItemDetailsPage({Key key, @required this.props, this.prefs})
      : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    Property props = widget.props;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.business_center,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () {
                  Navigator.push(context, ScaleRoute(page: FoodOrderPage()));
                })
          ],
        ),
        body: Container(
          padding: EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              CarouselDemo(),
              FoodTitleWidget(
                  productName: props.title,
                  productPrice: "P " + oCcy.format(props.fixPrice),
                  productHost: props.location),
              SizedBox(
                height: 15,
              ),
              AddToCartMenu(),
              SizedBox(
                height: 15,
              ),
              PreferredSize(
                preferredSize: Size.fromHeight(50.0),
                child: TabBar(
                  labelColor: Color(0xFFfd3f40),
                  indicatorColor: Color(0xFFfd3f40),
                  unselectedLabelColor: Color(0xFFa4a1a1),
                  indicatorSize: TabBarIndicatorSize.label,
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(
                      text: 'Details',
                    ),
                    Tab(
                      text: 'Reviews',
                    ),
                  ], // list of tabs
                ),
              ),
              Container(
                height: 150,
                child: TabBarView(
                  children: [
                    Container(
                      color: Colors.white24,
                      child: DetailContentMenu(description: props.description),
                    ),
                    Container(
                      color: Colors.white24,
                      child: DetailContentMenu(description: props.description),
                    ), // class name
                  ],
                ),
              ),
              BottomMenu(
                  prefs: widget.prefs,
                  ownerUid: props.ownerUid,
                  propsId: props.getPropId()),
            ],
          ),
        ),
      ),
    );
  }
}

class FoodTitleWidget extends StatelessWidget {
  String productName;
  String productPrice;
  String productHost;

  FoodTitleWidget({
    Key key,
    @required this.productName,
    @required this.productPrice,
    @required this.productHost,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              productName,
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
            Text(
              productPrice,
              style: TextStyle(
                  fontSize: 20,
                  color: Color(0xFF3a3a3b),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(
          height: 5,
        ),
        Row(
          children: <Widget>[
            Text(
              productHost,
              style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1f1f1f),
                  fontWeight: FontWeight.w400),
            ),
          ],
        )
      ],
    );
  }
}

class BottomMenu extends StatelessWidget {
  final SharedPreferences prefs;
  final String ownerUid;
  final String propsId;
  BottomMenu({this.prefs, this.ownerUid, this.propsId});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Column(
            children: <Widget>[
              Icon(
                Icons.timelapse,
                color: Color(0xFF404aff),
                size: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "12pm-3pm",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFa9a9a9),
                    fontWeight: FontWeight.w300),
              )
            ],
          ),
          Column(
            children: <Widget>[
              Icon(
                Icons.directions,
                color: Color(0xFF23c58a),
                size: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "3.5 km",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFa9a9a9),
                    fontWeight: FontWeight.w300),
              )
            ],
          ),
          Column(
            children: <Widget>[
              Icon(
                Icons.map,
                color: Color(0xFFff0654),
                size: 35,
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                "Map View",
                style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFa9a9a9),
                    fontWeight: FontWeight.w300),
              )
            ],
          ),
          Column(children: <Widget>[
            IconButton(
              onPressed: () {
                startAsyncInit(prefs, ownerUid, propsId, context);
              },
              icon: Icon(Icons.message),
              color: Color(0xFFe95959),
              iconSize: 35,
            ),
            SizedBox(
              height: 15,
            ),
            Text(
              "Chat Now",
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w300),
            )
          ]),
          SizedBox()
        ],
      ),
    );
  }
}

Map<String, dynamic> _chatData;
Map<String, dynamic> _userContact;
ChatHandler chatObj;
CollectionReference chatReference;

Future startAsyncInit(SharedPreferences prefs, String ownerUid, String propsId,
    BuildContext context) async {
  _userContact =
      await DatabaseService().getUseContact(prefs.getString('uid'), ownerUid);
  String contactUid =
      _userContact == null ? ownerUid : _userContact['contactUid'];
  if (_userContact == null) {
    DatabaseService()
        .userCollection
        .doc(prefs.getString('uid'))
        .collection('contacts')
        .add({
      'contactUid': ownerUid,
      'propsId': propsId,
      'date': getDateNow,
      'contactId': contactID,
    });
  }

  _chatData =
      await DatabaseService().getChatData(prefs.getString('uid'), contactUid);

  if (_chatData == null) {
    DatabaseService()
        .addChat(prefs.getString('uid'), ownerUid, propsId)
        .then((documentReference) {
      chatObj = new ChatHandler(documentReference.id);
    }).catchError((e) {});
  } else {
    chatObj = new ChatHandler(_chatData['chatId']);
  }

  chatReference = DatabaseService()
      .chatCollection
      .doc(chatObj.getChatId)
      .collection('messages');

  Navigator.push(
      context,
      ScaleRoute(
          page: ChatPage(
        prefs: prefs,
        chatObj: chatObj,
      )));
}

class AddToCartMenu extends StatelessWidget {
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
              color: Color(0xFFfd2c2c),
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
              icon: Icon(Icons.save_alt),
              color: Color(0xFFfd2c2c),
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
              color: Color(0xFFfd2c2c),
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

class DetailContentMenu extends StatelessWidget {
  String description;
  DetailContentMenu({Key key, @required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(
        description,
        style: TextStyle(
            fontSize: 14.0,
            color: Colors.black87,
            fontWeight: FontWeight.w400,
            height: 1.50),
        textAlign: TextAlign.justify,
      ),
    );
  }
}
