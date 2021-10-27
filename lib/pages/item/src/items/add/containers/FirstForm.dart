import 'dart:io';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/pages/item/src/items/add/FormBaseDetails.dart';
import 'package:flutter_app/pages/item/src/items/add/FormObj.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextArea.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/widgets/card/UploadFileCard.dart';
import 'package:flutter_app/widgets/components/CheckBox.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class FirstForm extends StatelessWidget implements FirstFormObj {
  FirstForm({
    this.catdata,
    //this.common_title,
    //this.common_condition,
    //this.common_sameitem,
    //this.common_dealmethod,
    //this.common_description,
    this.common_installment_amort,
    this.common_installment_count,
    this.common_installment_downpayment,
    //this.common_price,
    //this.uploadmedia,
    //this.loopitems,
    //this.propsid,

    this.propdetails,
    
    this.onChanged,
    this.onChangeUpload,
    this.onChangedCondtion,
  });

  final FormDetailsModel propdetails;

  final TextEditingController common_installment_amort;
  final TextEditingController common_installment_downpayment;
  final TextEditingController common_installment_count;

  //final TextEditingController common_title;
  //final TextEditingController common_description;
  //final TextEditingController common_condition;
  //final TextEditingController common_dealmethod;

  final Function onChanged;
  final Function onChangedCondtion;
  //final bool common_sameitem;
  final Function onChangeUpload;

  //final TextEditingController common_price;
  //final List<Asset> uploadmedia;
  //final List<dynamic> loopitems;
  //final String propsid;

  final CategoryFormModel catdata;

  @override
  Widget build(BuildContext context) {
    bool hascondition = (catdata.condition_brandnew != null ||
        catdata.condition_likebrandnew != null ||
        catdata.condition_wellused != null ||
        catdata.condition_heavilyused != null ||
        catdata.condition_new != null ||
        catdata.condition_preselling != null ||
        catdata.condition_preowned != null ||
        catdata.condition_foreclosed != null ||
        catdata.condition_used != null);
    return Column(
      children: <Widget>[
        title(),
        SizedBox(height: 20),
        if (catdata.priceinput_price != null) price(),
        if (catdata.priceinput_downpayment != null) downpayment(),
        if (catdata.priceinput_amortization != null) amortization(),
        if (catdata.payments_count != null) installmentCount(),
        SizedBox(height: 20),
        if (hascondition) condition(context),
        description(),
        if (catdata.deal_delivery != null) dealMethod(context),
        if (catdata.ismoreandsameitem != null) morethanOneITem(),
        Container(
          height: 150,
          width: double.infinity,
          child: UploadFileCard(
            loopitems: propdetails.loopitems,
            uploadmedia: propdetails.uploadmedia,
            onChangeUpload: onChangeUpload,
            propsid: propdetails.propsid,
          ),
        ),
      ],
    );
  }

  @override
  condition(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Condition',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(height: 10),
        CustomRadioButton(
          defaultSelected:
              propdetails.condition.text.isEmpty ? null : propdetails.condition.text,
          elevation: 0,
          unSelectedColor: Theme.of(context).canvasColor,
          buttonLables: [
            if (catdata.condition_brandnew != null) "Brand New",
            if (catdata.condition_likebrandnew != null) "Like New",
            if (catdata.condition_wellused != null) "Well Used",
            if (catdata.condition_heavilyused != null) "Heavily Used",
            if (catdata.condition_new != null) "New",
            if (catdata.condition_used != null) "Used",
            if (catdata.condition_preselling != null) "Pre-Selling",
            if (catdata.condition_preowned != null) "Pre-Owned",
            if (catdata.condition_foreclosed != null) "Foreclosed",
          ],
          buttonValues: [
            if (catdata.condition_brandnew != null) 'brandnew',
            if (catdata.condition_likebrandnew != null) 'likenew',
            if (catdata.condition_wellused != null) 'wellused',
            if (catdata.condition_heavilyused != null) 'heavilyused',
            if (catdata.condition_new != null) 'new',
            if (catdata.condition_used != null) 'used',
            if (catdata.condition_preselling != null) 'preselling',
            if (catdata.condition_preowned != null) 'preowned',
            if (catdata.condition_foreclosed != null) 'foreclosed',
          ],
          buttonTextStyle: ButtonTextStyle(
              selectedColor: Colors.white,
              unSelectedColor: Colors.black,
              textStyle: TextStyle(fontSize: 16)),
          radioButtonValue: (value) {
            onChangedCondtion(value);
          },
          selectedColor: Theme.of(context).accentColor,
          spacing: 0,
          padding: 10,
          enableButtonWrap: true,
          enableShape: true,
          horizontal: false,
          width: 140,
          absoluteZeroSpacing: false,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  dealMethod(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Deal method',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        SizedBox(height: 10),
        CustomRadioButton(
          defaultSelected:
              propdetails.dealmethod.text.isEmpty ? null : propdetails.dealmethod.text,
          elevation: 0,
          unSelectedColor: Theme.of(context).canvasColor,
          buttonLables: [
            "Meet up",
            "Delivery",
          ],
          buttonValues: [
            'meetup',
            'delivery',
          ],
          buttonTextStyle: ButtonTextStyle(
              selectedColor: Colors.white,
              unSelectedColor: Colors.black,
              textStyle: TextStyle(fontSize: 16)),
          radioButtonValue: (value) {
            propdetails.dealmethod.text = value;
          },
          selectedColor: Theme.of(context).accentColor,
          spacing: 0,
          padding: 10,
          enableButtonWrap: true,
          enableShape: true,
          horizontal: false,
          width: 140,
          absoluteZeroSpacing: false,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  description() {
    return Column(
      children: [
        InputTextArea(
          placeholder: "Desciption",
          width: double.infinity,
          value: propdetails.description,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  location() {
    // TODO: implement location
    throw UnimplementedError();
  }

  @override
  morethanOneITem() {
    return Column(
      children: [
        LabeledCheckbox(
            label: 'I have more than 1 of the Same item',
            value: propdetails.common_sameitem,
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            onChanged: onChanged),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  price() {
    return InputTextForm(
      isReadOnly: false,
      placeholder: "Price",
      isText: false,
      width: double.infinity,
      value: propdetails.price,
    );
  }

  @override
  title() {
    return InputTextForm(
      isReadOnly: false,
      placeholder: "Title",
      isText: true,
      width: double.infinity,
      value: propdetails.title,
    );
  }

  @override
  amortization() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: InputTextForm(
        isReadOnly: false,
        placeholder: "Monthly amortization",
        isText: false,
        width: double.infinity,
        value: common_installment_amort,
      ),
    );
  }

  @override
  downpayment() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: InputTextForm(
        isReadOnly: false,
        placeholder: "Downpayment",
        isText: false,
        width: double.infinity,
        value: common_installment_downpayment,
      ),
    );
  }

  @override
  installmentCount() {
    return Container(
      padding: EdgeInsets.only(top: 20),
      child: InputTextForm(
        isReadOnly: false,
        placeholder: "Months to pay",
        isText: false,
        width: double.infinity,
        value: common_installment_count,
      ),
    );
  }
}
