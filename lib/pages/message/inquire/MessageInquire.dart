import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/utils/DateHandler.dart';

import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import '../ChatHandler.dart';
import '../RegistrationHandler.dart';

class InquireMessage extends StatefulWidget {
  final SharedPreferences prefs;
  InquireMessage({this.prefs});
  @override
  _InquireMessageState createState() => _InquireMessageState();
}

class _InquireMessageState extends State<InquireMessage> {
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;

  final _yourNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    contactsReference = DatabaseService()
        .userCollection
        .doc(widget.prefs.getString('uid'))
        .collection('contacts');

    profileReference =
        DatabaseService().userCollection.doc(widget.prefs.getString('uid'));

    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
     
      widget.prefs.setString('name', profileSnapshot.get("firstName"));
      widget.prefs.setString('uid', profileSnapshot.get("uid"));
      widget.prefs.setString('profile_photo', profileSnapshot.get("image"));

      setState(() {
        _yourNameController.text = profileSnapshot.get("firstName");
      });
    });
  }

  generateContactTab() {
    return Column(
      children: <Widget>[
        StreamBuilder<QuerySnapshot>(
          stream: contactsReference.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            snapshot.data.docs.forEach((e) async {
              QuerySnapshot result = await DatabaseService()
                  .chatCollection
                  .where('contact1', isEqualTo: widget.prefs.getString('uid'))
                  .where('contact2', isEqualTo: e["uid"])
                  .get();
              List<DocumentSnapshot> documents = result.docs;

              if (documents.length == 0) {
                result = await await DatabaseService()
                    .chatCollection
                    .where('contact2',
                        isEqualTo: widget.prefs.getString('name'))
                    .where('contact1', isEqualTo: e["name"])
                    .get();
                documents = result.docs;
                if (documents.length == 0) {
                  await DatabaseService().chatCollection.add({
                    'contact1': widget.prefs.getString('uid'),
                    'contact2': e["uid"]
                  }).then((documentReference) {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          prefs: widget.prefs,
                          chatId: documentReference.id,
                          title: e["name"],
                        ),
                      ),
                    );
                  }).catchError((e) {});
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        prefs: widget.prefs,
                        chatId: documents[0].id,
                        title: e["name"],
                      ),
                    ),
                  );
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ChatPage(
                      prefs: widget.prefs,
                      chatId: documents[0].id,
                      title: e["name"],
                    ),
                  ),
                );
              }
            });
            //if (!snapshot.hasData) return new Text("No Contacts");
            return Expanded(
              child: new ListView(
                children: generateContactList(snapshot),
              ),
            );
          },
        )
      ],
    );
  }

  generateContactList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>((doc) => InkWell(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                ),
                child: ListTile(
                  title: Text(doc["name"]),
                  subtitle: Text(doc["name"]),
                  trailing: Icon(Icons.chevron_right),
                ),
              ),
              onTap: () async {
                QuerySnapshot result = await DatabaseService()
                    .chatCollection
                    .where('contact1', isEqualTo: widget.prefs.getString('uid'))
                    .where('contact2', isEqualTo: doc["uid"])
                    .get();
                List<DocumentSnapshot> documents = result.docs;
                if (documents.length == 0) {
                  result = await await DatabaseService()
                      .chatCollection
                      .where('contact2',
                          isEqualTo: widget.prefs.getString('name'))
                      .where('contact1', isEqualTo: doc["name"])
                      .get();
                  documents = result.docs;
                  if (documents.length == 0) {
                    await DatabaseService().chatCollection.add({
                      'contact1': widget.prefs.getString('uid'),
                      'contact2': doc["uid"]
                    }).then((documentReference) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            prefs: widget.prefs,
                            chatId: documentReference.id,
                            title: doc["name"],
                          ),
                        ),
                      );
                    }).catchError((e) {});
                  } else {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          prefs: widget.prefs,
                          chatId: documents[0].id,
                          title: doc["name"],
                        ),
                      ),
                    );
                  }
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        prefs: widget.prefs,
                        chatId: documents[0].id,
                        title: doc["name"],
                      ),
                    ),
                  );
                }
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {}
}
