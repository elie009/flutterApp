import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormObj.dart';
import 'package:flutter_app/pages/item/src/items/common/DropdownDateTerm.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class SecondForm extends StatelessWidget implements SecondFormObj {
  SecondForm(
      {this.propcheck,
      this.brandvalue,
      this.termsvalue,
      this.onChangedTerm,
      this.lotarea,
      this.bedrooms,
      this.bathrooms,
      this.floorarea,
      this.parkingspace,
      this.onChangedFurnish,
      this.furnishing,
      this.catdata,
      this.onChangedBrand});
  final PropertyChecking propcheck;

  final TextEditingController lotarea;
  final TextEditingController bedrooms;
  final TextEditingController bathrooms;
  final TextEditingController floorarea;
  final TextEditingController parkingspace;
  final TextEditingController furnishing;

  final Function onChangedBrand;
  final Function onChangedTerm;
  final Function onChangedFurnish;
  final String brandvalue;
  final String termsvalue;

  final CategoryFormModel catdata;

  @override
  UDfurnishing(BuildContext context) {
    return CustomRadioButton(
      elevation: 0,
      defaultSelected: furnishing.text.isEmpty ? null : furnishing.text,
      unSelectedColor: Theme.of(context).canvasColor,
      buttonLables: [
        "Unfurnished",
        "Semi Furnished",
        "Fully Furnished",
      ],
      buttonValues: [
        'unfurnished',
        'semifurnished',
        'fullyfurnished',
      ],
      buttonTextStyle: ButtonTextStyle(
          selectedColor: Colors.white,
          unSelectedColor: Colors.black,
          textStyle: TextStyle(fontSize: 14)),
      radioButtonValue: (value) {
        onChangedFurnish(value);
      },
      selectedColor: Theme.of(context).accentColor,
      spacing: 0,
      padding: 10,
      enableButtonWrap: true,
      enableShape: true,
      horizontal: false,
      width: 140,
      absoluteZeroSpacing: false,
    );
  }

  @override
  UDmeasureAndCount() {
    return Column(
      children: <Widget>[
        if (catdata.unitdetails_lotarea != null)
          InputTextForm(
            isReadOnly: false,
            placeholder: "Lot Area (sqm)",
            isText: false,
            width: double.infinity,
            value: lotarea,
          ),
        if (catdata.unitdetails_lotarea != null) SizedBox(height: 20),
        if (catdata.unitdetails_bedroom != null)
          InputTextForm(
            isReadOnly: false,
            placeholder: "Bedrooms",
            isText: false,
            width: double.infinity,
            value: bedrooms,
          ),
        if (catdata.unitdetails_bedroom != null) SizedBox(height: 20),
        if (catdata.unitdetails_bathroom != null)
          InputTextForm(
            isReadOnly: false,
            placeholder: "Bathrooms",
            isText: false,
            width: double.infinity,
            value: bathrooms,
          ),
        if (catdata.unitdetails_bathroom != null) SizedBox(height: 20),
        if (catdata.unitdetails_floorarea != null)
          InputTextForm(
            isReadOnly: false,
            placeholder: "Foor Area",
            isText: false,
            width: double.infinity,
            value: floorarea,
          ),
        if (catdata.unitdetails_floorarea != null) SizedBox(height: 20),
        if (catdata.unitdetails_parkingspace != null)
          InputTextForm(
            isReadOnly: false,
            placeholder: "Parking space",
            isText: false,
            width: double.infinity,
            value: parkingspace,
          ),
        if (catdata.unitdetails_parkingspace != null) SizedBox(height: 20),
      ],
    );
  }

  @override
  UDroom(BuildContext context) {
    return CustomRadioButton(
      elevation: 0,
      unSelectedColor: Theme.of(context).canvasColor,
      buttonLables: [
        "Private room",
        "Shared",
      ],
      buttonValues: [
        'privateroom',
        'shared',
      ],
      buttonTextStyle: ButtonTextStyle(
          selectedColor: Colors.white,
          unSelectedColor: Colors.black,
          textStyle: TextStyle(fontSize: 16)),
      radioButtonValue: (value) {
        print(value);
      },
      selectedColor: Theme.of(context).accentColor,
      spacing: 0,
      padding: 10,
      enableButtonWrap: true,
      enableShape: true,
      horizontal: false,
      width: 150,
      absoluteZeroSpacing: false,
    );
  }

  @override
  brand() {
    return DropdownDateTerm(
      onChanged: onChangedBrand,
      value: brandvalue,
      paceholder: "Select Brand",
      width: double.infinity,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Align(
        alignment: Alignment.centerLeft,
        child: TextLabelFade(
            text: 'Unit Details',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      ),
      SizedBox(height: 10),
      UDmeasureAndCount(),
      if (catdata.unitdetails_furnish_fullyfurnish != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Furnishing',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.unitdetails_furnish_fullyfurnish != null)
        SizedBox(height: 10),
      if (catdata.unitdetails_furnish_fullyfurnish != null)
        UDfurnishing(context),
      if (catdata.unitdetails_furnish_fullyfurnish != null)
        SizedBox(height: 20),
      if (catdata.unitdetails_room_private != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Room',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.unitdetails_room_private != null) SizedBox(height: 10),
      if (catdata.unitdetails_room_private != null) UDroom(context),
      if (catdata.unitdetails_room_private != null) SizedBox(height: 20),
      if (catdata.brandCODE != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Brand',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.brandCODE != null) SizedBox(height: 10),
      if (catdata.brandCODE != null) brand(),
      if (catdata.brandCODE != null) SizedBox(height: 20),
      if (catdata.unitdetails_termsCODE != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Terms',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.unitdetails_termsCODE != null) SizedBox(height: 10),
      if (catdata.unitdetails_termsCODE != null) terms(),
    ]);
  }

  @override
  feature() {}

  @override
  terms() {
    return DropdownDateTerm(
      onChanged: onChangedTerm,
      value: termsvalue,
      paceholder: "Select Terms",
      width: double.infinity,
    );
  }
}
