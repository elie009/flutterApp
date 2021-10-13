import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/pages/item/src/items/1001/containers/filehandler/mutli.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';
import 'package:image_picker/image_picker.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:video_player/video_player.dart';

class UploadFileCard extends StatefulWidget {
  final String propsid;
  final List<Asset> uploadmedia;
  final Function onChangeUpload;
  UploadFileCard(
      {this.loopitems, this.onChangeUpload, this.uploadmedia, this.propsid});
  List<dynamic> loopitems;

  @override
  _UploadFileCardState createState() => _UploadFileCardState();
}

class _UploadFileCardState extends State<UploadFileCard> {
  ImagePicker picker = ImagePicker();
  VideoPlayerController _cameraVideoPlayerController;

  @override
  Widget build(BuildContext context) {
    widget.loopitems = widget.loopitems == null ? [] : widget.loopitems;
    return Row(
      children: <Widget>[
        InkWell(
          onTap: () {
            loadAssets();
          },
          child: Container(
              height: 150,
              width: 130,
              child:
                  Card(child: Icon(Icons.add, size: 30, color: primaryColor))),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: widget.loopitems.map((i) {
              int index = widget.loopitems.indexOf(i);
              if (i is StrObj) if (i.stat == 'DELETE') return Container();
              return InkWell(
                onTap: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return ModalBox(
                          isCloseDisplay: false,
                          body: modalContainer(index),
                        );
                      });
                },
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: 130,
                      child: Card(
                        child: Center(
                          child: i is Asset
                              ? AssetThumb(
                                  asset: widget.loopitems[index],
                                  height: 300,
                                  width: 300,
                                )
                              : Image.network(
                                  widget.loopitems[index].value,
                                  fit: BoxFit.fitWidth,
                                ),
                        ),
                      ),
                    )
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  modalContainer(int index) {
    return Column(
      children: [
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
                onPressed: () {
                  setState(() {
                    if (widget.loopitems[index] is StrObj) {
                      widget.loopitems[index].stat = 'DELETE';
                    } else {
                      widget.loopitems.removeAt(index);
                    }
                    Navigator.pop(context);
                  });
                },
                label: Text('Delete'),
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
                onPressed: () {
                  Navigator.pop(context);
                },
                label: Text('Cancel'),
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

  Future<void> loadAssets() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 2,
        enableCamera: false,
        //selectedAssets: loopitems,
        cupertinoOptions: CupertinoOptions(
          takePhotoIcon: "chat",
          doneButtonTitle: "Fatto",
        ),
        materialOptions: MaterialOptions(
          actionBarColor: "#abcdef",
          actionBarTitle: "Example App",
          allViewTitle: "All Photos",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } on Exception catch (e) {
      print(e.toString());
    }

    if (!mounted) return;

    setState(() {
      widget.loopitems.addAll(resultList);
      widget.onChangeUpload(resultList);
    });
  }
}
