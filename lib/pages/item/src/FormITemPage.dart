import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/1001/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/FormComplete.dart';
import 'package:flutter_app/pages/item/src/items/1001/FormInfo.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/AlertBox.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormItemPage extends StatefulWidget {
  FormItemPage(
      {this.propcheck, this.menuCode, this.props, this.user, this.catdata});

  final PropertyChecking propcheck;
  final String menuCode;
  final UserBaseModel user;
  final PropertyItemModel props;
  final CategoryFormModel catdata;
  @override
  _FormItemPageState createState() => _FormItemPageState();
}

class _FormItemPageState extends State<FormItemPage> {
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

  List<MapData> inputdata;
  @override
  Widget build(BuildContext context) {
    List<MapData> inputdata = [];
    List<MapData> secondForm = [];
    FormBaseDetailsState.catdata = widget.catdata;
    FormLotInfoState.catdata = widget.catdata;

    if (widget.props != null && isNew) {
      FormBaseDetailsState.propdetails =
          FormDetailsModel.snapshot(widget.props);
      getData(widget.props.propid);

      DatabaseServiceItems.propertyCollection
          .where('propid', isEqualTo: widget.props.propid)
          .get()
          .then((value) {
        Map<String, dynamic> data = value.docs.single.data();
        //FormLotInfoState.formatDbLotData(data);
        FormLotInfoState.popItem =
            FormLotModel.snapshot(FormLotInfoState.formatDbLotData(data));
      });
      isNew = false;
    }
    List<Asset> uploadMedia = FormBaseDetailsState.getUploadMedia;
    if (uploadMedia.length > 1) print('xxxx');
    inputdata.addAll(FormBaseDetailsState.getDataValue);
    secondForm.addAll(FormLotInfoState.getRentDataValue);
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
            FormLotInfo(propcheck: widget.propcheck, catdata: widget.catdata),
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
                print('backkkk');
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
                      FormLotInfoState.formKey.currentState.validate()) {
                    currentStep = currentStep + 1;
                  }
                } else {
                  currentStep = 0;
                }
              });
              if (currentStep == 0) {
                FormLotInfoState.addLotToDB(widget.menuCode, widget.user.uid);
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

Future backToProfilePage(BuildContext context) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Navigator.push(context, ScaleRoute(page: ProfilePage(prefs: prefs)));
}

class MapData {
  String label;
  String key;
  String value;
  MapData({this.label, this.key, this.value});
}
