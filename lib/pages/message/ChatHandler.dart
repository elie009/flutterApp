import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/database.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'inbox/GallaryHandler.dart';

class ChatPage extends StatefulWidget {
  final SharedPreferences prefs;
  final String chatId;
  final String title;
  ChatPage({this.prefs, this.chatId, this.title});
  @override
  ChatPageState createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatPage> {
  CollectionReference chatReference;
  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;

  @override
  void initState() {
    super.initState();
    chatReference = DatabaseService()
        .chatCollection
        .doc(widget.chatId)
        .collection('messages');
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Text(documentSnapshot.get('sender_name'),
                style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: documentSnapshot.get('image_url') != ''
                  ? InkWell(
                      child: new Container(
                        child: Image.network(
                          documentSnapshot.get('image_url'),
                          fit: BoxFit.fitWidth,
                        ),
                        height: 150,
                        width: 150.0,
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        padding: EdgeInsets.all(5),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GalleryPage(
                              imagePath: documentSnapshot.get('image_url'),
                            ),
                          ),
                        );
                      },
                    )
                  : new Text(documentSnapshot.get('text')),
            ),
          ],
        ),
      ),
      new Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(left: 8.0),
              child: new CircleAvatar(
                backgroundImage:
                    new NetworkImage(documentSnapshot.get('profile_photo')),
              )),
        ],
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
              margin: const EdgeInsets.only(right: 8.0),
              child: new CircleAvatar(
                backgroundImage:
                    new NetworkImage(documentSnapshot.get('profile_photo')),
              )),
        ],
      ),
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Text(documentSnapshot.get('sender_name'),
                style: new TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold)),
            new Container(
              margin: const EdgeInsets.only(top: 5.0),
              child: documentSnapshot.get('image_url') != ''
                  ? InkWell(
                      child: new Container(
                        child: Image.network(
                          documentSnapshot.get('image_url'),
                          fit: BoxFit.fitWidth,
                        ),
                        height: 150,
                        width: 150.0,
                        color: Color.fromRGBO(0, 0, 0, 0.2),
                        padding: EdgeInsets.all(5),
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GalleryPage(
                              imagePath: documentSnapshot.get('image_url'),
                            ),
                          ),
                        );
                      },
                    )
                  : new Text(documentSnapshot.get('text')),
            ),
          ],
        ),
      ),
    ];
  }

  generateMessages(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>((doc) => Container(
              margin: const EdgeInsets.symmetric(vertical: 10.0),
              child: new Row(
                children: doc.get('sender_id') != widget.prefs.getString('uid')
                    ? generateReceiverLayout(doc)
                    : generateSenderLayout(doc),
              ),
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Container(
        padding: EdgeInsets.all(5),
        child: new Column(
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
              stream:
                  chatReference.orderBy('time', descending: true).snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return new Text("No Chat");
                return Expanded(
                  child: new ListView(
                    reverse: true,
                    children: generateMessages(snapshot),
                  ),
                );
              },
            ),
            new Divider(height: 1.0),
            new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _buildTextComposer(),
            ),
            new Builder(builder: (BuildContext context) {
              return new Container(width: 0.0, height: 0.0);
            })
          ],
        ),
      ),
    );
  }

  IconButton getDefaultSendButton() {
    return new IconButton(
      icon: new Icon(Icons.send),
      onPressed: _isWritting ? () => _sendText(_textController.text) : null,
    );
  }

  Widget _buildTextComposer() {
    return new IconTheme(
        data: new IconThemeData(
          color: _isWritting
              ? Theme.of(context).accentColor
              : Theme.of(context).disabledColor,
        ),
        child: new Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0),
          child: new Row(
            children: <Widget>[
              new Container(
                margin: new EdgeInsets.symmetric(horizontal: 4.0),
                child: new IconButton(
                    icon: new Icon(
                      Icons.photo_camera,
                      color: Theme.of(context).accentColor,
                    ),
                    onPressed: () async {
                      int timestamp = getDateNowMilliSecond;
                      Reference storageReference = FirebaseStorage.instance
                          .ref()
                          .child('chats/img_' + timestamp.toString() + '.jpg');

                      final imageFile = File(await ImagePicker.platform
                          .pickImage(source: ImageSource.gallery)
                          .then((pickedFile) => pickedFile.path));

                      UploadTask uploadTask =
                          storageReference.putFile(imageFile);
                      await uploadTask;
                      String fileUrl = await storageReference.getDownloadURL();
                      _sendImage(messageText: null, imageUrl: fileUrl);
                    }),
              ),
              new Flexible(
                child: new TextField(
                  controller: _textController,
                  onChanged: (String messageText) {
                    setState(() {
                      _isWritting = messageText.length > 0;
                    });
                  },
                  onSubmitted: _sendText,
                  decoration:
                      new InputDecoration.collapsed(hintText: "Send a message"),
                ),
              ),
              new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: getDefaultSendButton(),
              ),
            ],
          ),
        ));
  }

  Future<Null> _sendText(String text) async {
    _textController.clear();
    chatReference.add({
      'text': text,
      'sender_id': widget.prefs.getString('uid'),
      'sender_name': widget.prefs.getString('name'),
      'profile_photo': widget.prefs.getString('profile_photo'),
      'image_url': '',
      'time': FieldValue.serverTimestamp(),
    }).then((documentReference) {
      setState(() {
        _isWritting = false;
      });
    }).catchError((e) {});
  }

  void _sendImage({String messageText, String imageUrl}) {
    chatReference.add({
      'text': messageText,
      'sender_id': widget.prefs.getString('uid'),
      'sender_name': widget.prefs.getString('name'),
      'profile_photo': widget.prefs.getString('image'),
      'image_url': imageUrl,
      'time': FieldValue.serverTimestamp(),
    });
  }
}
