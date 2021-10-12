import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/FileModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/FormITemPage.dart';
import 'package:flutter_app/pages/item/src/items/1001/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/1001/containers/SecondForm.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class FormLotInfo extends StatefulWidget {
  FormLotInfo({this.propcheck, this.catdata});
  final PropertyChecking propcheck;
  final CategoryFormModel catdata;

  @override
  State<StatefulWidget> createState() {
    return FormLotInfoState();
  }
}

class FormLotInfoState extends State<FormLotInfo> {
  static final formKey = GlobalKey<FormState>();

  static FormLotModel popItem = FormLotModel.init();

  static PropertyItemModel formatDbLotData(Map<String, dynamic> data) {
    return PropertyItemModel(
      title: data['title'] ?? '',
      conditionCode: data['conditionCode'] ?? 'foreclosed',
      priceselectionCode: data['priceselectionCode'] ?? '',
      price: data['price'] ?? 0.0,
      description: data['description'] ?? '',
      ismoreandsameitem: data['ismoreandsameitem'] ?? false,
      dealmethodCode: data['dealmethodCode'] ?? '',
      location_cityprovinceCode: data['location_cityprovinceCode'] ?? '',
      location_streetaddress: data['location_streetaddress'] ?? '',
      branchCode: data['branchCode'] ?? '',
      featureCode: data['featureCode'] ?? '',
      lotarea: data['lotarea'] ?? 0.0,
      bedroms: data['bedroms'] ?? 0,
      bathrooms: data['bathrooms'] ?? 0,
      floorarea: data['floorarea'] ?? 0.0,
      carspace: data['carspace'] ?? 0,
      furnishingCode: data['furnishingCode'] ?? '',
      roomCode: data['roomCode'] ?? '',
      numComments: data['numComments'] ?? 0,
      numLikes: data['numLikes'] ?? 0,
      numViews: data['numViews'] ?? 0,
      propid: data['propid'] ?? '',
      menuid: data['menuid'] ?? '',
      ownerUid: data['ownerUid'] ?? '',
      status: data['status'] ?? '',
      imageId: data['imageId'] ?? '',
      forSale: data['forSale'] ?? false,
      forRent: data['forRent'] ?? false,
      forInstallment: data['forInstallment'] ?? false,
      forSwap: data['forSwap'] ?? false,
      termCode: data['termCode'] ?? '',
    );
  }

  static get getModelValue {
    PropertyItemModel props = new PropertyItemModel(
      lotarea: popItem.unitdetails_lotarea.text.isEmpty
          ? 0.0
          : toDouble(popItem.unitdetails_lotarea.text),
      bedroms: popItem.unitdetails_bedroom.text.isEmpty
          ? 0
          : toInt(popItem.unitdetails_bedroom.text),
      bathrooms: popItem.unitdetails_bathroom.text.isEmpty
          ? 0
          : toInt(popItem.unitdetails_bathroom.text),
      floorarea: popItem.unitdetails_floorarea.text.isEmpty
          ? 0.0
          : toDouble(popItem.unitdetails_floorarea.text),
      carspace: popItem.unitdetails_parkingspace.text.isEmpty
          ? 0
          : toInt(popItem.unitdetails_parkingspace.text),
      furnishingCode: popItem.unitdetails_furnish.text.isEmpty
          ? ''
          : popItem.unitdetails_furnish.text,
      roomCode: popItem.unitdetails_room.text.isEmpty
          ? ''
          : popItem.unitdetails_room.text,
      termCode: popItem.unitdetails_termsCODE.isEmpty
          ? ''
          : popItem.unitdetails_termsCODE,
    );
    return props;
  }

  static List<String> imageUrls = <String>[];

  static Future postImage(Asset imageFile, String filename) async {
    double getAspectRatio(double originalSize, double desiredSize) =>
        desiredSize / originalSize;

    var aspectRatio = getAspectRatio(imageFile.originalWidth.toDouble(), 1300);
    int W = (imageFile.originalWidth * aspectRatio).round();
    int H = (imageFile.originalHeight * aspectRatio).round();

    aspectRatio = getAspectRatio(imageFile.originalWidth.toDouble(), 300);
    int thumbW = (imageFile.originalWidth * aspectRatio).round();
    int thumbH = (imageFile.originalHeight * aspectRatio).round();

    Reference thumbreference =
        FirebaseStorage.instance.ref().child("THUMB" + filename);
    UploadTask thumbuploadTask = thumbreference.putData(
        (await imageFile.getThumbByteData(thumbW, thumbH, quality: 80))
            .buffer
            .asUint8List());

    TaskSnapshot storageTaskSnapshot = await thumbuploadTask.whenComplete(() {
      print(thumbreference.getDownloadURL());
    });

    Reference reference = FirebaseStorage.instance.ref().child(filename);
    UploadTask uploadTask = reference.putData(
        (await imageFile.getByteData(quality: 50)).buffer.asUint8List());
    await uploadTask.whenComplete(() {
      print(reference.getDownloadURL());
    });
    print(storageTaskSnapshot.ref.getDownloadURL());
    return storageTaskSnapshot.ref.getDownloadURL();
  }

  static Future deleteImage(String fileid, String propid) async {
    FirebaseStorage.instance.ref().child("THUMB" + fileid).delete();
    Reference reference = FirebaseStorage.instance.ref().child(fileid);
    return reference.delete();
  }

  static void uploadImages(List<dynamic> images, PropertyItemModel props) {
    var primaImg = '';
    try {
      // images.map((imageFile) {
      //   // get index
      //   var index = images.indexOf(imageFile);
      // }).toList();
      images.map((imageFile) {
        String fileid = idFile;
        var index = images.indexOf(imageFile);
        if (imageFile is StrObj) {
          fileid = imageFile.key;

          if (imageFile.stat == "DELETE") {
            deleteImage(fileid, props.propid).then((value) {
              primaImg = primaImg.isEmpty ? primaImg : primaImg;
              if (images.length == 1) primaImg = '';
              DatabaseServiceItems.propertyCollection
                  .doc(props.propid)
                  .collection('media')
                  .doc(fileid)
                  .delete()
                  .then((value) async {
                props.imageId = primaImg;
                await DatabaseServiceItems().add(props);
              });
            });
          }
        }

        if (imageFile is Asset)
          postImage(imageFile, fileid).then((downloadUrl) {
            imageUrls.add(downloadUrl.toString());
            primaImg = primaImg.isEmpty ? downloadUrl.toString() : primaImg;
            DatabaseServiceItems.propertyCollection
                .doc(props.propid)
                .collection('media')
                .doc(fileid)
                .set({
              'urls': downloadUrl.toString(),
              'filename': imageFile.name,
              'fileid': fileid,
              'status': 'APPROVE',
              'uploaddate': getDateNow
            }).then((value) async {
              props.imageId = primaImg;
              await DatabaseServiceItems().add(props);
            });
            //}
          }).catchError((err) {
            print(err);
          });
      }).toList();
    } catch (e) {
      print(e.toString());
    }
  }

  static addLotToDB(String menuCode, String userui) async {
    PropertyItemModel props = FormLotInfoState.getModelValue;

    String propid = FormBaseDetailsState.propdetails.propsid == null
        ? menuCode + idProperty
        : FormBaseDetailsState.propdetails.propsid;

    props.propid = propid;
    props.menuid = menuCode;
    props.ownerUid = userui;
    props.status = 'UPLOAD';
    props.title = FormBaseDetailsState.propdetails.title.text;
    props.imageId = '';
    props.location_cityprovinceCode = '';
    props.location_streetaddress = '';
    props.description = FormBaseDetailsState.propdetails.description.text;
    props.price = toDouble(FormBaseDetailsState.propdetails.price.text);
    props.dealmethodCode = FormBaseDetailsState.propdetails.dealmethod.text;
    props.ismoreandsameitem = FormBaseDetailsState.propdetails.common_sameitem;

    props.forSale = FormBaseDetailsState.propdetails.isSale;
    props.forRent = FormBaseDetailsState.propdetails.isRent;
    props.forInstallment = FormBaseDetailsState.propdetails.isInstallment;
    props.forSwap = FormBaseDetailsState.propdetails.isSwap;
    props.conditionCode = FormBaseDetailsState.propdetails.condition.text;

    await DatabaseServiceItems().add(props).then((value) {
      uploadImages(FormBaseDetailsState.propdetails.loopitems, props);
    });
  }

  static CategoryFormModel catdata;

  static get getRentDataValue {
    return [
      if (catdata.unitdetails_lotarea != null)
        MapData(
            label: "Lot Area",
            key: "lotarea",
            value: popItem.unitdetails_lotarea == null
                ? ''
                : popItem.unitdetails_lotarea.text),
      if (catdata.unitdetails_bedroom != null)
        MapData(
            label: "Bedrooms",
            key: "bedrooms",
            value: popItem.unitdetails_bedroom == null
                ? ''
                : popItem.unitdetails_bedroom.text),
      if (catdata.unitdetails_bathroom != null)
        MapData(
            label: "Bathrooms",
            key: "bathrooms",
            value: popItem.unitdetails_bathroom == null
                ? ''
                : popItem.unitdetails_bathroom.text),
      if (catdata.unitdetails_floorarea != null)
        MapData(
            label: "Floor Area",
            key: "floorarea",
            value: popItem.unitdetails_floorarea == null
                ? ''
                : popItem.unitdetails_floorarea.text),
      if (catdata.unitdetails_termsCODE != null)
        MapData(
            label: "Term",
            key: "term",
            value: popItem.unitdetails_termsCODE.isEmpty
                ? ''
                : Constants.termsDateCode[popItem.unitdetails_termsCODE]),
      if (catdata.unitdetails_furnish_fullyfurnish != null)
        MapData(
            label: "Furnishing",
            key: "furnishing",
            value: popItem.unitdetails_furnish.text.isEmpty
                ? ''
                : Constants.furnishing[popItem.unitdetails_furnish.text]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          SecondForm(
            furnishing: popItem.unitdetails_furnish,
            brandvalue: popItem.unitdetails_brandCODE,
            lotarea: popItem.unitdetails_lotarea,
            bedrooms: popItem.unitdetails_bedroom,
            bathrooms: popItem.unitdetails_bathroom,
            floorarea: popItem.unitdetails_floorarea,
            parkingspace: popItem.unitdetails_parkingspace,
            onChangedTerm: (val) {
              setState(() {
                popItem.unitdetails_termsCODE = val;
              });
            },
            onChangedFurnish: (val) {
              setState(() {
                popItem.unitdetails_furnish.text = val;
              });
            },
            onChangedBrand: (val) {
              setState(() {
                popItem.unitdetails_brandCODE = val;
              });
            },
            termsvalue: popItem.unitdetails_termsCODE,
            propcheck: widget.propcheck,
            catdata: widget.catdata,
          ),
          SizedBox(height: 20),
        ],
      ),
    ));
  }
}

class FormLotModel {
  String propsId;

  TextEditingController unitdetails_lotarea;
  TextEditingController unitdetails_bedroom;
  TextEditingController unitdetails_bathroom;
  TextEditingController unitdetails_floorarea;
  TextEditingController unitdetails_parkingspace;
  TextEditingController unitdetails_furnish;
  TextEditingController unitdetails_room;
  String unitdetails_termsCODE;
  String unitdetails_brandCODE;

  FormLotModel.init() {
    this.unitdetails_lotarea = new TextEditingController();
    this.unitdetails_bedroom = new TextEditingController();
    this.unitdetails_bathroom = new TextEditingController();
    this.unitdetails_floorarea = new TextEditingController();
    this.unitdetails_parkingspace = new TextEditingController();
    this.unitdetails_furnish = new TextEditingController();
    this.unitdetails_room = new TextEditingController();
    this.unitdetails_termsCODE = '';
    this.unitdetails_brandCODE = '';
  }

  FormLotModel.snapshot(PropertyItemModel props) {
    this.unitdetails_lotarea = new TextEditingController();
    this.unitdetails_bedroom = new TextEditingController();
    this.unitdetails_bathroom = new TextEditingController();
    this.unitdetails_floorarea = new TextEditingController();
    this.unitdetails_parkingspace = new TextEditingController();
    this.unitdetails_furnish = new TextEditingController();
    this.unitdetails_room = new TextEditingController();

    this.unitdetails_lotarea.text = props.lotarea.toString();
    this.unitdetails_bedroom.text = props.bedroms.toString();
    this.unitdetails_bathroom.text = props.bathrooms.toString();
    this.unitdetails_floorarea.text = props.floorarea.toString();
    this.unitdetails_parkingspace.text = props.carspace.toString();
    this.unitdetails_furnish.text = props.furnishingCode;
    this.unitdetails_room.text = props.roomCode;
    this.unitdetails_termsCODE = props.termCode;
    this.unitdetails_brandCODE = props.branchCode;
  }

  FormLotModel({
    this.unitdetails_lotarea,
  });
}
