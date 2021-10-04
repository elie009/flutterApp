import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/pages/item/src/items/1002/FormObj.dart';
import 'package:flutter_app/widgets/components/RadioBtn.dart';

class ForSaleForm extends StatelessWidget implements LotForSaleObj {
  ForSaleForm(
      {this.optionCategory,
      this.onChangedOptionCategory,
      this.saleControllerFixPrice});

  final TextEditingController saleControllerFixPrice;
  final int optionCategory;
  final Function onChangedOptionCategory;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      salePriceOptionsFunc(),
      saleOptionCategory(),
    ]);
  }

  @override
  salePriceOptionsFunc() {
    return InputTextForm(
      isReadOnly: false,
      placeholder: "Price",
      isText: false,
      width: double.infinity,
      value: saleControllerFixPrice,
    );
  }

  @override
  saleOptionCategory() {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        SizedBox(
          width: 160,
          child: RadioBtn(
            label: "Entire",
            value: 1,
            valueController: optionCategory,
            onChanged: (int newValue) {
              onChangedOptionCategory(newValue);
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: RadioBtn(
            label: "Per sqm",
            value: 2,
            valueController: optionCategory,
            onChanged: (int newValue) {
              onChangedOptionCategory(newValue);
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: RadioBtn(
            label: "Per Ha",
            value: 3,
            valueController: optionCategory,
            onChanged: (int newValue) {
              onChangedOptionCategory(newValue);
            },
          ),
        ),
        SizedBox(
          width: 160,
          child: RadioBtn(
            label: "Other",
            value: 4,
            valueController: optionCategory,
            onChanged: (int newValue) {
              onChangedOptionCategory(newValue);
            },
          ),
        ),
      ],
    );
  }
}
