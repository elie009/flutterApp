import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/database.dart';
import 'package:flutter_app/model/ContactModel.dart';
import 'package:flutter_app/model/ChatModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:flutter_app/widgets/card/RowCardInquire.dart';
import 'package:flutter_app/widgets/components/UserImage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatInquire extends StatefulWidget {
  final SharedPreferences prefs;
  final ChatModel chatObj;
  final PropertyModel props;
  bool isNewContact;
  bool isNewChat;
  CollectionReference chatReference;

  ChatInquire({
    this.prefs,
    this.chatObj,
    this.props,
    this.isNewContact,
    this.isNewChat,
    this.chatReference,
  });
  @override
  ChatPageState createState() {
    return new ChatPageState();
  }
}

class ChatPageState extends State<ChatInquire> {
  CollectionReference chatReference;
  final TextEditingController _textController = new TextEditingController();
  bool _isWritting = false;
  CollectionReference contactsReference;
  DocumentReference profileReference;
  bool newitem;
  final Radius messageCard = Radius.circular(15.0);

  @override
  void initState() {
    super.initState();
    chatReference = widget.chatReference;
    newitem = widget.isNewContact || widget.isNewChat;
  }

  List<Widget> generateSenderLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Container(
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
                      onTap: () {},
                    )
                  : new Container(
                      padding: EdgeInsets.all(13.0),
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: messageCard,
                            bottomLeft: messageCard,
                            topRight: messageCard),
                        color: primaryColor,
                      ),
                      child: new Text(
                        documentSnapshot.get('text'),
                        style: TextStyle(color: whiteColor),
                      ),
                    ),
            ),
            new Text(
                documentSnapshot.get('time') == null
                    ? ''
                    : formatTimeStamp(documentSnapshot.get('time').toDate()),
                style: new TextStyle(
                    fontSize: 14.0,
                    color: grayColor,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    ];
  }

  List<Widget> generateReceiverLayout(DocumentSnapshot documentSnapshot) {
    return <Widget>[
      new Expanded(
        child: new Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
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
                      onTap: () {},
                    )
                  : new Container(
                      padding: EdgeInsets.all(8.0),
                      margin: EdgeInsets.all(4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topLeft: messageCard,
                            topRight: messageCard,
                            bottomRight: messageCard),
                        color: whiteColor,
                      ),
                      child: new Text(
                        documentSnapshot.get('text'),
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
            ),
            new Text(
                documentSnapshot.get('time') == null
                    ? ''
                    : formatTimeStamp(documentSnapshot.get('time').toDate()),
                style: new TextStyle(
                    fontSize: 14.0,
                    color: grayColor,
                    fontWeight: FontWeight.w500)),
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
        iconTheme: IconThemeData(
          color: primaryColor, //change your color here
        ),
        backgroundColor: whiteColor,
        title: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // ClipRRect(
            //   borderRadius: BorderRadius.circular(20.0),
            //   child: new Container(
            //       child: new CircleAvatar(
            //     backgroundImage:
            //         new NetworkImage(widget.prefs.getString('owenerImage')),
            //   )),
            // ),
            UserImage(image: widget.prefs.getString('owenerImage')),
            Container(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.prefs.getString('ownerName'),
                  style: TextStyle(color: primaryColor),
                ))
          ],
        ),
        actions: [
          Icon(
            Icons.menu,
            color: primaryColor,
          ),
          SizedBox(width: 20),
        ],
      ),
      body: Container(
        color: shadeWhite,
        padding: EdgeInsets.all(5),
        child: new Column(
          children: <Widget>[
            RowCardInquire(props: widget.props),
            (newitem
                ? Expanded(
                    child: new ListView(reverse: true, children: <Widget>[
                    Container(
                      margin: const EdgeInsets.symmetric(vertical: 10.0),
                      child: new Row(),
                    )
                  ]))
                : StreamBuilder<QuerySnapshot>(
                    stream: chatReference
                        .orderBy('time', descending: true)
                        .snapshots(),
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
                  )),
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

    if (widget.isNewContact) {
      DatabaseService()
          .userCollection
          .doc(widget.prefs.getString('uid'))
          .collection('contacts')
          .doc(widget.props.propid)
          .set({
        'contactUid': widget.props.ownerUid,
        'propsId': widget.props.propid,
        'name': widget.prefs.getString('ownerName'),
        //'contactId': idContact,
        'lastMessage': text,
        'datetime': getDateNow,
        'status': 'UNREAD',
      }).then((value) {
        widget.isNewContact = false;
      });
    } else {
      DatabaseService()
          .userCollection
          .doc(widget.prefs.getString('uid'))
          .collection('contacts')
          .doc(widget.props.propid)
          .set({
        'contactUid': widget.props.ownerUid,
        'propsId': widget.props.propid,
        'name': widget.prefs.getString('ownerName'),
        //'contactId': idContact,
        'lastMessage': text,
        'datetime': getDateNow,
        'status': 'READ',
      });
    }

    if (widget.isNewChat) {
      String chatId = idChat;

      DatabaseService()
          .addChat(widget.prefs.getString('uid'), widget.props.ownerUid,
              widget.props.propid, chatId)
          .then((value) {
        setState(() {
          chatReference = DatabaseService()
              .chatCollection
              .doc(chatId)
              .collection('messages');
          newitem = false;
          widget.isNewChat = false;
        });
        _addMessage(text);
      });
    }
    _addMessage(text);
  }

  void _addMessage(String text) {
    chatReference.add({
      'text': text,
      'sender_id': widget.prefs.getString('uid'),
      'sender_name': widget.prefs.getString('name'),
      'profile_photo': widget.prefs.getString('image'),
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
