import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/model/WishListModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/add/FormComplete.dart';
import 'package:flutter_app/pages/item/src/items/add/FormUploader.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/AlertBox.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class FormLandingPage extends StatefulWidget {
  FormLandingPage(
      {this.propcheck, this.menuCode, this.props, this.user, this.catdata});

  final PropertyChecking propcheck;
  final String menuCode;
  final UserBaseModel user;
  final PropertyItemModel props;
  final CategoryFormModel catdata;
  @override
  _FormLandingPageState createState() => _FormLandingPageState();
}

class _FormLandingPageState extends State<FormLandingPage> {
  var currentStep = 0;
  bool isNew = true;

  Future<dynamic> getData(String propsid) async {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('media')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          var e = StrObj(
              stat: 'GET',
              key: element.data()['fileid'],
              value: element.data()['urls']);
          FormBaseDetailsState.propdetails.loopitems.add(e);
        });
      });
    });
  }

  Future<dynamic> getWishlistData(String propsid) async {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('wishlist')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          var e = WishListModel(
              categoryid: element.data()['categoryid'],
              title: element.data()['title'],
              message: element.data()['message'],
              wishid: element.data()['wishid'],
              isSelect: element.data()['isSelect']);
          FormUploaderState.popItem.wishlist.add(e);
        });
      });
    });
  }

  List<MapData> inputdata;
  @override
  Widget build(BuildContext context) {
    List<MapData> inputdata = [];
    List<MapData> secondForm = [];
    FormBaseDetailsState.catdata = widget.catdata;
    FormUploaderState.catdata = widget.catdata;

    if (widget.props != null && isNew) {
      FormBaseDetailsState.propdetails =
          FormDetailsModel.snapshot(widget.props);
      getData(widget.props.propid);
      if (widget.propcheck.swap) getWishlistData(widget.props.propid);

      DatabaseServiceItems.propertyCollection
          .where('propid', isEqualTo: widget.props.propid)
          .get()
          .then((value) {
        Map<String, dynamic> data = value.docs.single.data();
        FormUploaderState.popItem =
            FormLotModel.snapshot(FormUploaderState.formatDbLotData(data));
      });
      isNew = false;
    }
    List<Asset> uploadMedia = FormBaseDetailsState.getUploadMedia;
    if (uploadMedia.length > 1) print('xxxx');
    inputdata.addAll(FormBaseDetailsState.getDataValue);
    secondForm.addAll(FormUploaderState.getRentDataValue);
    List<Step> steps = [
      Step(
        title: Text('Step 1'),
        content: FormBaseDetails(propcheck: widget.propcheck),
        state: currentStep == 0 ? StepState.editing : StepState.indexed,
        isActive: true,
      ),
      Step(
        title: Text('Step 2'),
        content:
            FormUploader(propcheck: widget.propcheck, catdata: widget.catdata),
        state: currentStep == 1 ? StepState.editing : StepState.indexed,
        isActive: true,
      ),
      Step(
        title: Text('Complete'),
        content: FormComplete(inputdata, secondForm),
        state: StepState.complete,
        isActive: true,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Item Form'),
        backgroundColor: primaryColor,
      ),
      body: Container(
        child: Theme(
          data: ThemeData(
              accentColor: yellowamber,
              primarySwatch: Colors.orange,
              colorScheme: ColorScheme.light(primary: Colors.orange)),
          child: Stepper(
            currentStep: this.currentStep,
            steps: steps,
            type: StepperType.horizontal,
            onStepTapped: (step) {
              setState(() {
                currentStep = step;
              });
            },
            onStepContinue: () {
              setState(() {
                if (currentStep < steps.length - 1) {
                  if (currentStep == 0 &&
                      FormBaseDetailsState.formKey.currentState.validate()) {
                    currentStep = currentStep + 1;
                  } else if (currentStep == 1 &&
                      FormUploaderState.formKey.currentState.validate()) {
                    currentStep = currentStep + 1;
                  }
                } else {
                  currentStep = 0;
                }
              });
              if (currentStep == 0) {
                FormUploaderState.addLotToDB(widget.menuCode, widget.user.uid);
                Navigator.pop(context);

                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) => AlertBox(
                          title: 'Successfully',
                          message: 'Transation are saved',
                        ));
              }
            },
            onStepCancel: () {
              setState(() {
                if (currentStep > 0) {
                  currentStep = currentStep - 1;
                } else {
                  currentStep = 0;
                }
              });
            },
          ),
        ),
      ),
    );
  }
}

class MapData {
  String label;
  String key;
  String value;
  MapData({this.label, this.key, this.value});
}
