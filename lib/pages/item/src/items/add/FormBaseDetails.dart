import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormLandingPage.dart';
import 'package:flutter_app/pages/item/src/items/add/containers/FirstForm.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class FormBaseDetails extends StatefulWidget {
  FormBaseDetails({this.propcheck});
  final PropertyChecking propcheck;
  @override
  State<StatefulWidget> createState() {
    return FormBaseDetailsState();
  }
}

class FormBaseDetailsState extends State<FormBaseDetails> {
  static final formKey = GlobalKey<FormState>();
  static FormDetailsModel propdetails = FormDetailsModel.init();

  static CategoryFormModel catdata;

  static get getUploadMedia {
    return propdetails.uploadmedia;
  }

  static get getDataValue {
    bool hascondition = (catdata.condition_brandnew != null ||
        catdata.condition_likebrandnew != null ||
        catdata.condition_wellused != null ||
        catdata.condition_heavilyused != null ||
        catdata.condition_new != null ||
        catdata.condition_preselling != null ||
        catdata.condition_preowned != null ||
        catdata.condition_foreclosed != null ||
        catdata.condition_used != null);
    return [
      if (catdata.title != null)
        MapData(label: "Title", key: "title", value: propdetails.title.text),
      if (hascondition)
        MapData(
            label: "Condition",
            key: "condition",
            value: propdetails.condition.text.isEmpty
                ? ''
                : Constants.conditions[propdetails.condition.text]),
      if (catdata.description != null)
        MapData(
            label: "Description",
            key: "description",
            value: propdetails.description.text),
      if (catdata.priceinput_price != null)
        MapData(label: "Price", key: "price", value: propdetails.price.text),
      MapData(
          label: "Deal Method",
          key: "dealmethod",
          value: propdetails.dealmethod.text.isEmpty
              ? ''
              : Constants.dealmethod[propdetails.dealmethod.text]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    propdetails.isSale = widget.propcheck.sale;
    propdetails.isRent = widget.propcheck.rental;
    propdetails.isInstallment = widget.propcheck.installment;
    propdetails.isSwap = widget.propcheck.swap;

    return Container(
        child: Form(
      key: formKey,
      child: Column(
        children: <Widget>[
          FirstForm(
            //loopitems: propdetails.loopitems,
            //propsid: propdetails.propsid,
            //uploadmedia: propdetails.uploadmedia,
            //common_price: propdetails.price,
            // common_dealmethod: propdetails.dealmethod,
            // common_condition: propdetails.condition,
            // common_title: propdetails.title,
            // common_description: propdetails.description,
            // common_sameitem: propdetails.common_sameitem,

            propdetails: propdetails,
            catdata: catdata,
            onChanged: (newValue) {
              setState(() {
                propdetails.common_sameitem = newValue;
              });
            },
            onChangeUpload: (newValue) {
              setState(() {
                propdetails.uploadmedia = newValue;
              });
            },
            onChangedCondtion: (newValue) {
              setState(() {
                propdetails.condition.text = newValue;
              });
            },
          ),
        ],
      ),
    ));
  }
}

class FormDetailsModel {
  TextEditingController title;
  TextEditingController condition;
  TextEditingController description;
  TextEditingController dealmethod;
  TextEditingController price;
  TextEditingController downpayment;
  TextEditingController installment_count;
  TextEditingController installment_amort;
  TextEditingController installment_equity;

  List<Asset> uploadmedia = <Asset>[];
  List<dynamic> loopitems = <dynamic>[];
  bool isSale;
  bool isRent;
  bool isInstallment;
  bool isSwap;
  String propsid;
  bool common_sameitem;

  FormDetailsModel.init() {
    this.title = new TextEditingController();
    this.condition = new TextEditingController();
    this.description = new TextEditingController();
    this.dealmethod = new TextEditingController();
    this.price = new TextEditingController();
    this.downpayment = new TextEditingController();
    this.installment_count = new TextEditingController();
    this.installment_amort = new TextEditingController();
    this.installment_equity = new TextEditingController();

    this.common_sameitem = false;
    this.isSale = false;
    this.isRent = false;
    this.isInstallment = false;
    this.isSwap = false;
  }

  FormDetailsModel.snapshot(PropertyItemModel props) {
    this.title = new TextEditingController();
    this.condition = new TextEditingController();
    this.description = new TextEditingController();
    this.dealmethod = new TextEditingController();
    this.price = new TextEditingController();
    this.downpayment = new TextEditingController();
    this.installment_count = new TextEditingController();
    this.installment_amort = new TextEditingController();
    this.installment_equity = new TextEditingController();

    this.title.text = props.title;
    this.condition.text = props.conditionCode;
    this.description.text = props.description;
    this.price.text = props.price.toString();
    this.dealmethod.text = props.dealmethodCode;
    this.propsid = props.propid;
    this.common_sameitem = props.ismoreandsameitem;

    this.isSale = props.forSale;
    this.isRent = props.forRent;
    this.isInstallment = props.forInstallment;
    this.isSwap = props.forSwap;
    this.uploadmedia = <Asset>[];

    this.downpayment.text = props.installment_downpayment.toString();
    this.installment_count.text = props.installment_monthstopay.toString();
    this.installment_amort.text = props.installment_amort.toString();
    this.installment_equity.text = props.installment_equity.toString();
  }

  FormDetailsModel({
    this.title,
    this.condition,
    this.description,
  });
}
