import 'dart:io';
import 'dart:async';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/UserObj.dart';
import 'package:image_picker/image_picker.dart';

File imageFile;

class ImagePickerWidget extends StatefulWidget {
  UserBase usrobj;
  ImagePickerWidget({this.usrobj});
  @override
  _ImagePickerWidgetState createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  void takePhotoByCamera() async {
    File image = (await ImagePicker.platform
        .pickImage(source: ImageSource.camera)) as File;
    setState(() {
      imageFile = image;
    });
  }

  Future<void> takePhotoByGallery() async {
    File imageFile = File(await ImagePicker.platform
        .pickImage(source: ImageSource.gallery)
        .then((pickedFile) => pickedFile.path));
    Reference storageReference =
        FirebaseStorage.instance.ref().child('profiles/${widget.usrobj.uid}');
    UploadTask uploadTask = storageReference.putFile(imageFile);

    await uploadTask;
    String fileUrl = await storageReference.getDownloadURL();

    widget.usrobj.image = fileUrl;
    DatabaseService().updateUserData(widget.usrobj);
  }

  void removePhoto() {
    setState(() {
      imageFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 250.0,
      width: 250.0,
      margin: EdgeInsets.only(left: 30.0, top: 25.0),
      child: Column(
        children: <Widget>[
          Text(
            "Profile photo",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 20.0, top: 20.0),
            child: Row(
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.camera),
                  onPressed: takePhotoByCamera,
                  label: Text("Camera"),
                ),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                ),
                FlatButton.icon(
                  icon: Icon(Icons.image),
                  onPressed: takePhotoByGallery,
                  label: Text("Gallery"),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(right: 40.0, top: 10.0),
            child: Row(
              children: <Widget>[
                FlatButton.icon(
                  icon: Icon(Icons.delete),
                  onPressed: removePhoto,
                  label: Text("Remove"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
