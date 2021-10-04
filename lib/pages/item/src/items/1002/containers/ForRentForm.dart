import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/item/src/items/1002/FormObj.dart';
import 'package:flutter_app/pages/item/src/items/common/DropdownDateTerm.dart';
import 'package:flutter_app/pages/item/src/items//common/InputTextArea.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/widgets/components/RadioBtn.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class ForRentForm extends StatelessWidget implements LotFormRentObj {
  ForRentForm(
      {this.onChangedTermsOfRent,
      this.onChangedMinContract,
      this.rentControllerFixPrice,
      this.rentMinContractRangeNum,
      this.onChangedOptionCategory,
      this.rentConditions,
      this.optionCategory,
      this.rentTermsOfRentCode,
      this.rentMinContractRangeCode});
  final Function onChangedTermsOfRent;
  final Function onChangedMinContract;
  final Function onChangedOptionCategory;
  final TextEditingController rentControllerFixPrice;
  final TextEditingController rentMinContractRangeNum;
  final TextEditingController rentConditions;
  final int optionCategory;

  final String rentMinContractRangeCode;
  final String rentTermsOfRentCode;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        rentTermsOfPaymentFunc(),
        SizedBox(height: 20),
        rentOptionCategory(),
        SizedBox(height: 20),
        rentPriceOptionsFunc(),
        SizedBox(height: 20),
        Align(
          alignment: Alignment.topLeft,
          child: TextLabelFade(
            text: "Minimun Contract Range",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
            width: 170,
          ),
        ),
        SizedBox(height: 5),
        rentMinContractRageFunc(),
        SizedBox(height: 20),
        rentConditionsFunc(),
      ],
    );
  }

  @override
  rentConditionsFunc() {
    return InputTextArea(
      placeholder: 'Agreement',
      value: rentConditions,
      width: double.infinity,
    );
  }

  @override
  rentMinContractRageFunc() {
    return Wrap(
      alignment: WrapAlignment.start,
      children: [
        InputTextForm(
            isReadOnly: false,
            isText: false,
            width: 150,
            placeholder: 'Range number',
            value: rentMinContractRangeNum),
        SizedBox(width: 10),
        DropdownDateTerm(
          onChanged: onChangedMinContract,
          value: rentMinContractRangeCode,
          paceholder: "Select Option",
          width: 200,
        ),
      ],
    );
  }

  @override
  rentTermsOfPaymentFunc() {
    return DropdownDateTerm(
      onChanged: onChangedTermsOfRent,
      value: rentTermsOfRentCode,
      paceholder: "Select Terms of payment",
      width: double.infinity,
    );
  }

  @override
  rentPriceOptionsFunc() {
    return InputTextForm(
      isReadOnly: false,
      placeholder: "Rate",
      isText: false,
      width: double.infinity,
      value: rentControllerFixPrice,
    );
  }

  @override
  rentOptionCategory() {
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
