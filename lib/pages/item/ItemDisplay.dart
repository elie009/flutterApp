import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/ChatModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/widgets/components/CarouselSlider.dart';
import 'package:flutter_app/pages/item/PopupOffer.dart';
import 'package:flutter_app/pages/message/inquire/ChatInquire.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'component/AddCartMenu.dart';

class ItemDetailsPage extends StatefulWidget {
  PropertyModel props;
  ItemDetailsPage({Key key, @required this.props}) : super(key: key);

  @override
  _ItemDetailsPageState createState() => _ItemDetailsPageState();
}

class _ItemDetailsPageState extends State<ItemDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    PropertyModel props = widget.props;
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
                onPressed: () {})
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
              CarouselComponent(),
              FoodTitleWidget(
                  productName: props.title,
                  productPrice: "P " + oCcy.format(props.fixPrice),
                  productHost: props.location),
              SizedBox(
                height: 15,
              ),
              ItemMenu(),
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
              //BottomMenu(ownerUid: props.ownerUid, propsId: props.propid),
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

Map<String, dynamic> _chatData;
Map<String, dynamic> _userContact;
ChatModel chatObj;
CollectionReference chatReference;

Future startAsyncInit(UserBaseModel user, String ownerUid, String propsId,
    BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  DatabaseService().userCollection.doc(user.uid).get().then((value) {
    prefs.setString('uid', value.get('uid'));
    prefs.setString('image', value.get('image'));
  });

  //wala pani na gamit
  DatabaseService().userCollection.doc(ownerUid).get().then((value) {
    new UserBaseModel(
      value.get('uid'),
      value.get('firstName'),
      value.get('image'),
      value.get('lastName'),
      value.get('phoneNumber'),
      value.get('status'),
      value.get('email'),
    );
    prefs.setString('owenerImage', value.get('image'));
  });

  _userContact = await DatabaseService().getUseContact(user.uid, ownerUid);
  String contactUid =
      _userContact == null ? ownerUid : _userContact['contactUid'];
  if (_userContact == null) {
    DatabaseService().userCollection.doc(user.uid).collection('contacts').add({
      'contactUid': ownerUid,
      'propsId': propsId,
      'date': getDateNow,
      'contactId': idContact,
    });
  }

  _chatData = await DatabaseService().getChatData(user.uid, contactUid);

  if (_chatData == null) {
    DatabaseService()
        .addChat(user.uid, ownerUid, propsId)
        .then((documentReference) {
      chatObj = new ChatModel(documentReference.id);
    }).catchError((e) {});
  } else {
    chatObj = new ChatModel(_chatData['chatId']);
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
