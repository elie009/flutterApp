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
import 'ChatHandler.dart';
import 'RegistrationHandler.dart';

class MessagePage extends StatefulWidget {
  final SharedPreferences prefs;
  MessagePage({this.prefs});
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  int _currentIndex = 0;
  String _tabTitle = "Contacts";
  List<Widget> _children = [Container(), Container()];

  final ContactPicker _contactPicker = new ContactPicker();
  CollectionReference contactsReference;
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;

  final GlobalKey<FormState> _formStateKey = GlobalKey<FormState>();
  final _yourNameController = TextEditingController();
  bool editName = false;
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
      widget.prefs.setString('profile_photo', profileSnapshot.get("uid"));

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
            if (!snapshot.hasData) return new Text("No Contacts");

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

  Future<void> getProfilePicture() async {
    final imageFile = File(await ImagePicker.platform
        .pickImage(source: ImageSource.gallery)
        .then((pickedFile) => pickedFile.path));

    Reference storageReference = FirebaseStorage.instance
        .ref()
        .child('profiles/${widget.prefs.getString('uid')}');
    UploadTask uploadTask = storageReference.putFile(imageFile);

    await uploadTask;
    String fileUrl = await storageReference.getDownloadURL();
    profileReference.update({'lastName': fileUrl});
  }

  generateProfileTab() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (profileSnapshot != null
                ? (profileSnapshot.get('lastName') != null
                    ? InkWell(
                        child: Container(
                          width: 190.0,
                          height: 190.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  '${profileSnapshot.get('lastName')}'),
                            ),
                          ),
                        ),
                        onTap: () {
                          getProfilePicture();
                        },
                      )
                    : Container())
                : Container()),
            SizedBox(
              height: 20,
            ),
            (!editName && profileSnapshot != null
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('${profileSnapshot.get("lastName")}'),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            editName = true;
                          });
                        },
                      ),
                    ],
                  )
                : Container()),
            (editName
                ? Form(
                    key: _formStateKey,
                    autovalidate: true,
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 10, bottom: 10),
                          child: TextFormField(
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please Enter Name';
                              }
                              if (value.trim() == "")
                                return "Only Space is Not Valid!!!";
                              return null;
                            },
                            controller: _yourNameController,
                            decoration: InputDecoration(
                              focusedBorder: new UnderlineInputBorder(
                                  borderSide: new BorderSide(
                                      width: 2, style: BorderStyle.solid)),
                              labelText: "Your Name",
                              icon: Icon(
                                Icons.verified_user,
                              ),
                              fillColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Container()),
            (editName
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      RaisedButton(
                        child: Text(
                          'UPDATE',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          if (_formStateKey.currentState.validate()) {
                            profileReference
                                .update({'lastName': _yourNameController.text});
                            setState(() {
                              editName = false;
                            });
                          }
                        },
                        color: Colors.lightBlue,
                      ),
                      RaisedButton(
                        child: Text('CANCEL'),
                        onPressed: () {
                          setState(() {
                            editName = false;
                          });
                        },
                      )
                    ],
                  )
                : Container())
          ]),
    );
  }

  generateContactList(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map((doc) => InkWell(
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

  openContacts() async {
    Contact contact = await _contactPicker.selectContact();
    if (contact != null) {
      String phoneNumber = contact.phoneNumber.number
          .toString()
          .replaceAll(new RegExp(r"\s\b|\b\s"), "")
          .replaceAll(new RegExp(r'[^\w\s]+'), '');
      if (phoneNumber.length == 10) {
        phoneNumber = '+91$phoneNumber';
      }
      if (phoneNumber.length == 12) {
        phoneNumber = '+$phoneNumber';
      }
      if (phoneNumber.length > 10) {
        DocumentReference mobileRef = DatabaseService()
            .mobileCollection
            .doc(phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''));
        await mobileRef.get().then((documentReference) {
          if (documentReference.exists) {
            contactsReference.add({
              'uid': documentReference['uid'],
              'name': contact.fullName,
              'date': getDateNow,
            });
          } else {
            print('User Not Registered');
          }
        }).catchError((e) {});
      } else {
        print('Wrong Mobile Number');
      }
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      switch (_currentIndex) {
        case 0:
          _tabTitle = "Contacts";
          break;
        case 1:
          _tabTitle = "Profile";
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      generateContactTab(),
      generateProfileTab(),
    ];
    return MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_tabTitle),
            actions: <Widget>[
              (_currentIndex == 0
                  ? Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            openContacts();
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.backspace),
                          onPressed: () {
                            FirebaseAuth.instance.signOut().then((response) {
                              widget.prefs.remove('is_verified');
                              widget.prefs.remove('mobile_number');
                              widget.prefs.remove('uid');
                              widget.prefs.remove('name');
                              widget.prefs.remove('profile_photo');
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      RegistrationPage(prefs: widget.prefs),
                                ),
                              );
                            });
                          },
                        )
                      ],
                    )
                  : Container())
            ],
          ),
          body: _children[_currentIndex],
          bottomNavigationBar: BottomNavigationBar(
            onTap: onTabTapped, // new
            currentIndex: _currentIndex, // new
            items: [
              new BottomNavigationBarItem(
                icon: Icon(Icons.mail),
                title: Text('Contacts'),
              ),
              new BottomNavigationBarItem(
                icon: Icon(Icons.verified_user),
                title: Text('Profile'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
