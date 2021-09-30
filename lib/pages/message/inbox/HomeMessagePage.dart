import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/items/DatabaseServiceProps.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/message/inspector/ChatInspector.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';
import 'package:flutter_app/widgets/section/SearchWidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';

class HomeMessagePage extends StatefulWidget {
  final SharedPreferences prefs;
  HomeMessagePage({this.prefs});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomeMessagePage> {
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

      widget.prefs.setString('name', profileSnapshot.get('firstName'));
      widget.prefs.setString('profile_photo', profileSnapshot.get("image"));

      setState(() {
        _yourNameController.text = profileSnapshot.get("firstName");
      });
    });
  }

  generateContactTab(UserBaseModel user) {
    print('viewpoint PA');
    print(contactsReference.snapshots());
    return Column(
      children: <Widget>[
        SearchWidget(),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: contactsReference.snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return new Text("No Contacts");
              return Expanded(
                child: new ListView(
                  children: generateContactList(user, snapshot),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Future<void> getProfilePicture() async {
  //   var image = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   StorageReference storageReference = FirebaseStorage.instance
  //       .ref()
  //       .child('profiles/${widget.prefs.getString('uid')}');
  //   StorageUploadTask uploadTask = storageReference.putFile(image);
  //   await uploadTask.onComplete;
  //   print('File Uploaded');
  //   String fileUrl = await storageReference.getDownloadURL();
  //   profileReference.updateData({'profile_photo': fileUrl});
  // }

  generateProfileTab() {
    return Center(
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            (profileSnapshot != null
                ? (profileSnapshot.get('firstName') != null
                    ? InkWell(
                        child: Container(
                          width: 190.0,
                          height: 190.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              fit: BoxFit.fill,
                              image: NetworkImage(
                                  '${profileSnapshot.get('image')}'),
                            ),
                          ),
                        ),
                        onTap: () {
                          //getProfilePicture();
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
                      Text('${profileSnapshot.get("firstName")}'),
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
                          // if (_formStateKey.currentState.validate()) {
                          //   profileReference
                          //       .updateData({'name': _yourNameController.text});
                          //   setState(() {
                          //     editName = false;
                          //   });
                          // }
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

  generateContactList(
      UserBaseModel user, AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>(
          (doc) => InkWell(
            child: Container(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: new NetworkImage(
                      'https://images.unsplash.com/photo-1453728013993-6d66e9c9123a?ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8cGhvdG9ncmFwaGVyfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&w=1000&q=80'),
                ),
                title: Row(
                  children: [
                    Text(
                      doc["name"],
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Text(
                      toDateTimeStr(doc["datetime"]),
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 15),
                    ),
                  ],
                ),
                subtitle: TextLabelFade(
                    text: doc["lastMessage"],
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: doc["status"] == 'UNREAD'
                            ? FontWeight.bold
                            : FontWeight.w500)),
                trailing: Icon(Icons.arrow_forward_ios),
              ),
            ),
            onTap: () async {
              QuerySnapshot result = await DatabaseService()
                  .chatCollection
                  .where('contact1', isEqualTo: widget.prefs.getString('uid'))
                  .where('contact2', isEqualTo: doc["contactUid"])
                  .get();

              List<DocumentSnapshot> documents = result.docs;
              if (documents.length == 0) {
                result = await DatabaseService()
                    .chatCollection
                    .where('contact2', isEqualTo: widget.prefs.getString('uid'))
                    .where('contact1', isEqualTo: doc["contactUid"])
                    .get();
                documents = result.docs;
                if (documents.length == 0) {
                  await DatabaseService().chatCollection.add({
                    'contact1': widget.prefs.getString('uid'),
                    'contact2': doc["contactUid"]
                  }).then((documentReference) {
                    print('viewpoint 10');
                    // Navigator.of(context).push(
                    //   MaterialPageRoute(
                    //     builder: (context) => ChatPage(
                    //       prefs: widget.prefs,
                    //       chatId: documentReference.documentID,
                    //       title: doc["name"],
                    //     ),
                    //   ),
                    // );
                  }).catchError((e) {});
                } else {
                  print('viewpoint 11');
                  // Navigator.of(context).push(
                  //   MaterialPageRoute(
                  //     builder: (context) => ChatPage(
                  //       prefs: widget.prefs,
                  //       chatId: documents[0].documentID,
                  //       title: doc["name"],
                  //     ),
                  //   ),
                  // );
                }
              } else {
                print('viewpoint 12');
                DatabaseServiceProps()
                    .propertyCollection
                    .doc(doc["propsId"])
                    .get()
                    .then((value) {
                  PropertyModel props = new PropertyModel.snaphot(value);
                  chatInspector(user, props, context);
                });
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => ChatPage(
                //       prefs: widget.prefs,
                //       chatId: documents[0].documentID,
                //       title: doc["name"],
                //     ),
                //   ),
                // );
              }
            },
          ),
        )
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
      if (phoneNumber.length == 13) {
        DocumentReference mobileRef = DatabaseService()
            .mobileCollection
            .doc(phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''));
        await mobileRef.get().then((documentReference) {
          if (documentReference.exists) {
            contactsReference.add({
              'uid': documentReference['uid'],
              'name': contact.fullName,
              'mobile': phoneNumber.replaceAll(new RegExp(r'[^\w\s]+'), ''),
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
    final user = Provider.of<UserBaseModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_tabTitle),
      ),
      body: generateContactTab(user),
    );
  }
}
