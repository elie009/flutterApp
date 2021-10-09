import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:video_player/video_player.dart';

class UploadFileCard extends StatefulWidget {
  final List<File> itemStoreMedia;
  final Function onChangeUpload;
  UploadFileCard({this.onChangeUpload, this.itemStoreMedia});

  @override
  _UploadFileCardState createState() => _UploadFileCardState();
}

class _UploadFileCardState extends State<UploadFileCard> {
  File _cameraVideo;
  static File _image;
  List<File> items = [null];

  ImagePicker picker = ImagePicker();
  VideoPlayerController _cameraVideoPlayerController;

  String _error = 'No Error Dectected';
  List<Asset> images = <Asset>[];

  @override
  Widget build(BuildContext context) {
    items = items == null ? [] : items;
    items = widget.itemStoreMedia == null ? items : widget.itemStoreMedia;
    return ListView(
      scrollDirection: Axis.horizontal,
      children: items.map((i) {
        int index = items.indexOf(i);
        return InkWell(
          onTap: () {
            loadAssets();
            // showModalBottomSheet<void>(
            //     context: context,
            //     builder: (BuildContext context) {
            //       return ModalBox(
            //         isCloseDisplay: false,
            //         body: modalContainer(),
            //         //body:pickImages(),
            //       );
            //     });
          },
          child: Column(
            children: [
              Container(
                height: 150,
                width: 130,
                child: Card(
                  child: index == 0
                      ? Icon(Icons.add, size: 30, color: primaryColor)
                      : Center(child: Image.file(i)),
                ),
              )
            ],
          ),
        );
      }).toList(),
    );
  }

  modalContainer() {
    return Column(
      children: [
        showImgMediaOption(),
        SizedBox(
          height: 10,
        ),
        Row(
          children: [
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue, padding: EdgeInsets.all(10)),
                icon: Icon(Icons.camera_alt_outlined),
                onPressed: () {},
                label: Text('Image'),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Colors.blue, padding: EdgeInsets.all(10)),
                icon: Icon(Icons.play_circle_fill_outlined),
                onPressed: () {},
                label: Text('Video'),
              ),
            ),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ],
    );
  }

  showImgMediaOption() {
    return Row(
      children: [
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, padding: EdgeInsets.all(10)),
            icon: Icon(Icons.camera),
            onPressed: () {
              _pickImageFromGallery();
            },
            label: Text('Camera'),
          ),
        ),
        SizedBox(
          width: 10,
        ),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                primary: Colors.blue, padding: EdgeInsets.all(10)),
            icon: Icon(Icons.play_circle_fill_outlined),
            onPressed: () {},
            label: Text('Galery'),
          ),
        ),
        SizedBox(
          width: 10,
        )
      ],
    );
  }

  // This funcion will helps you to pick a Video File from Camera
  _pickVideoFromCamera() async {
    PickedFile pickedFile = await picker.getVideo(source: ImageSource.camera);

    _cameraVideo = File(pickedFile.path);

    _cameraVideoPlayerController = VideoPlayerController.file(_cameraVideo)
      ..initialize().then((_) {
        setState(() {});
        _cameraVideoPlayerController.play();
      });
  }

  _pickImageFromGallery() async {
    PickedFile pickedFile =
        await picker.getImage(source: ImageSource.gallery, imageQuality: 50);

    File image = File(pickedFile.path);

    setState(() {
      _image = image;
      items.add(_image);
      widget.onChangeUpload(items);
    });
  }

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];
    String error = 'No Error Detected';

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 300,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      error = e.toString();
    }

    if (!mounted) return;

    setState(() {
      images = resultList;
      // _error = error;
    });
  }
}
