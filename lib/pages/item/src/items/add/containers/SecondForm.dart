import 'package:custom_radio_grouped_button/custom_radio_grouped_button.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/WishListModel.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/item/src/items/add/FormObj.dart';
import 'package:flutter_app/pages/item/src/items/add/containers/WishItemModal.dart';
import 'package:flutter_app/pages/item/src/items/common/DropdownDateTerm.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/card/WishItemCardRow.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class SecondForm extends StatelessWidget implements SecondFormObj {
  SecondForm(
      {this.propcheck,
      this.brandvalue,
      this.isDeletebtnDisply,
      this.onChangedWishListDelete,
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
      this.onChangedWishListOkbtn,
      this.onChangedWishListCheckbox,
      this.wishlist,
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
  final Function onChangedWishListOkbtn;
  final Function onChangedWishListDelete;
  final Function onChangedWishListCheckbox;
  final String brandvalue;
  final String termsvalue;

  final List<WishListModel> wishlist;
  final CategoryFormModel catdata;
  final bool isDeletebtnDisply;

  @override
  UDfurnishing(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: CustomRadioButton(
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
      ),
    );
  }

  @override
  UDmeasureAndCount() {
    return Column(
      children: <Widget>[
        if (catdata.unitdetails_lotarea != null)
          displayitem("Lot Area (sqm)", lotarea),
        if (catdata.unitdetails_bedroom != null)
          displayitem("Bedrooms", bedrooms),
        if (catdata.unitdetails_bathroom != null)
          displayitem("Bathrooms", bathrooms),
        if (catdata.unitdetails_floorarea != null)
          displayitem("Foor Area", floorarea),
        if (catdata.unitdetails_parkingspace != null)
          displayitem("Parking space", parkingspace),
      ],
    );
  }

  displayitem(String label, dynamic value) {
    return Container(
      padding: EdgeInsets.only(bottom: 20),
      child: InputTextForm(
        isReadOnly: false,
        placeholder: label,
        isText: false,
        width: double.infinity,
        value: value,
      ),
    );
  }

  @override
  UDroom(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: CustomRadioButton(
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
      ),
    );
  }

  @override
  brand() {
    return Container(
      padding: EdgeInsets.only(top: 10, bottom: 20),
      child: DropdownDateTerm(
        onChanged: onChangedBrand,
        value: brandvalue,
        paceholder: "Select Brand",
        width: double.infinity,
      ),
    );
  }

  TextEditingController title = new TextEditingController();
  TextEditingController message = new TextEditingController();
  TextEditingController category = new TextEditingController();

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
        UDfurnishing(context),
      if (catdata.unitdetails_room_private != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Room',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.unitdetails_room_private != null) UDroom(context),
      if (catdata.brandCODE != null)
        Align(
          alignment: Alignment.centerLeft,
          child: TextLabelFade(
              text: 'Brand',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
      if (catdata.brandCODE != null) brand(),
      if (catdata.unitdetails_termsCODE != null)
        Container(
          padding: EdgeInsets.only(bottom: 10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: TextLabelFade(
                text: 'Terms',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ),
        ),
      if (catdata.unitdetails_termsCODE != null) terms(),
      if (propcheck.swap)
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              child: TextButton(
                child: Text('Add Wishlist'),
                style: TextButton.styleFrom(
                  primary: Colors.white,
                  backgroundColor: Colors.teal,
                  onSurface: Colors.grey,
                ),
                onPressed: () {
                  title = new TextEditingController();
                  message = new TextEditingController();
                  category = new TextEditingController();
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return WishItemModal(
                          dropdownWishlistitem: category,
                          title: title,
                          message: message,
                          onClickOk: onChangedWishListOkbtn,
                        );
                      });
                },
              ),
            ),
            if (isDeletebtnDisply)
              Container(
                padding: EdgeInsets.all(10),
                child: TextButton(
                  onPressed: () {
                    onChangedWishListDelete();
                  },
                  child: Text('Delete'),
                  style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.teal,
                    onSurface: Colors.grey,
                  ),
                ),
              ),
          ],
        ),
      if (propcheck.swap) wishlistConent(context)
    ]);
  }

  wishlistConent(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                'Wishlist',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: primaryColor),
              ),
            ),
          ),
          for (WishListModel wishitem in wishlist)
            if (wishitem.localstatus != 'DELETE')
              WishItemCardRow(
                onClickCard: () {
                  title.text = wishitem.title;
                  message.text = wishitem.message;
                  category.text = wishitem.categoryid;
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return WishItemModal(
                          itemid: wishitem.wishid,
                          dropdownWishlistitem: category,
                          title: title,
                          message: message,
                          onClickOk: onChangedWishListOkbtn,
                        );
                      });
                },
                wishItem: wishitem,
                onChangeCheckbox: (bool newValue) {
                  int index = wishlist.indexOf(wishitem);
                  onChangedWishListCheckbox(newValue, index);
                },
              )
        ],
      ),
    );
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
