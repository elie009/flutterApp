import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/message/inbox/MessageLandingPage.dart';
import 'package:flutter_app/pages/message/inquire/HomeMessagePage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

CollectionReference contactsReference;
DocumentReference profileReference;

Future messageInspector(UserBaseModel user, BuildContext context) async {
  contactsReference =
      DatabaseService().userCollection.doc(user.uid).collection('contacts');
  print(contactsReference);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  DatabaseService().userCollection.doc(user.uid).get().then((value) {
    prefs.setString('uid', value.get('uid'));
    prefs.setString('image', value.get('image'));
    prefs.setString('firstName', value.get('firstName'));
  });

  print('-----------<');
  print(prefs.setString('uid', user.uid));
  contactsReference.snapshots().forEach((e) {
    print('----------->');
    print(e.docs);

    print('viewpoint B3');
    DatabaseService()
        .chatCollection
        .where('contact1', isEqualTo: 'FH3SHsyElpgXmRgSFLWBnxmIU4T2')
        .where('contact2', isEqualTo: 'nwpxhS8cqDgYw8QtcKKYuQogMf92')
        .get()
        .then((value) {
      print('>>>>>>');
      print(value);
    });
    print('viewpoint B4');
  });

  return Navigator.push(
      context,
      ScaleRoute(
          page: HomeMessagePage(
        prefs: prefs,
        //contactsReference: contactsReference,
      )));
}
