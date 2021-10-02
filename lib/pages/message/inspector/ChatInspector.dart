import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/ChatModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/message/inquire/ChatInquire.dart';
import 'package:shared_preferences/shared_preferences.dart';

Map<String, dynamic> _chatData;
Map<String, dynamic> _userContact;
ChatModel chatObj;
CollectionReference chatReference = null;

Future chatInspector(
    UserBaseModel user, PropertyModel props, BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();

  DatabaseService().userCollection.doc(user.uid).get().then((value) {
    prefs.setString('uid', value.get('uid'));
    prefs.setString('image', value.get('image'));
  });

  _userContact =
      await DatabaseService().getUseContact(user.uid, props.ownerUid);
  String contactUid =
      _userContact == null ? props.ownerUid : _userContact['contactUid'];
  _chatData = await DatabaseService().getChatData(user.uid, contactUid);

  if (_chatData != null) {
    chatObj = new ChatModel(_chatData['chatId']);
    chatReference = DatabaseService()
        .chatCollection
        .doc(chatObj.getChatId)
        .collection('messages');
  }

  await DatabaseService()
      .userCollection
      .doc(props.ownerUid)
      .get()
      .then((value) {
    prefs.setString('owenerImage', value.get('image'));
    prefs.setString('ownerName', value.get('firstName'));
  });
  Navigator.push(
      context,
      ScaleRoute(
          page: ChatInquire(
              prefs: prefs,
              chatObj: chatObj,
              props: props,
              isNewContact: _userContact == null,
              isNewChat: _chatData == null,
              chatReference: chatReference)));
}
