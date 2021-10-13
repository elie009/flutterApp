import 'dart:io';

import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/pages/item/src/items/1001/FormObj.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextArea.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/widgets/card/UploadFileCard.dart';
import 'package:flutter_app/widgets/components/CheckBox.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';
import 'package:multi_image_picker2/multi_image_picker2.dart';

class FirstForm extends StatelessWidget implements FirstFormObj {
  FirstForm(
      {this.common_price,
      this.onChangeUpload,
      this.uploadmedia,
      this.onChanged,
      this.common_title,
      this.catdata,
      this.common_condition,
      this.loopitems,
      this.onChangedCondtion,
      this.common_sameitem,
      this.common_dealmethod,
      this.propsid,
      this.common_description});

  final TextEditingController common_price;
  final TextEditingController common_title;
  final TextEditingController common_description;
  final TextEditingController common_condition;
  final TextEditingController common_dealmethod;

  final Function onChanged;
  final Function onChangedCondtion;
  final bool common_sameitem;
  final Function onChangeUpload;
  final List<Asset> uploadmedia;
  final List<dynamic> loopitems;
  final String propsid;

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
        price(),
        SizedBox(height: 20),
        if (hascondition) condition(context),
        description(),
        if (catdata.deal_delivery != null) dealMethod(context),
        if (catdata.ismoreandsameitem != null) morethanOneITem(),
        Container(
          height: 150,
          width: double.infinity,
          child: UploadFileCard(
            loopitems: loopitems,
            uploadmedia: uploadmedia,
            onChangeUpload: onChangeUpload,
            propsid: propsid,
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
              common_condition.text.isEmpty ? null : common_condition.text,
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
              common_dealmethod.text.isEmpty ? null : common_dealmethod.text,
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
            common_dealmethod.text = value;
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
          value: common_description,
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
            value: common_sameitem,
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
      value: common_price,
    );
  }

  @override
  title() {
    return InputTextForm(
      isReadOnly: false,
      placeholder: "Title",
      isText: true,
      width: double.infinity,
      value: common_title,
    );
  }
}
