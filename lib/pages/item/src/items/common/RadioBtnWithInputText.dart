import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';
import 'package:flutter_app/widgets/components/RadioBtn.dart';

class RadioBtnWithInputText extends StatelessWidget {
  const RadioBtnWithInputText(
      {Key key,
      this.label,
      this.option,
      this.value,
      this.condition,
      this.placeholder,
      this.onChanged,
      this.controllerValue});

  final String label;
  final int option;
  final int value;
  final Function onChanged;
  final TextEditingController controllerValue;
  final bool condition;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      children: [
        SizedBox(
          width: 160,
          child: RadioBtn(
            label: label,
            value: value,
            valueController: option,
            onChanged: (int newValue) {
              onChanged(newValue);
            },
          ),
        ),
        InputTextForm(
            isReadOnly: condition,
            value: controllerValue,
            width: 200,
            isText: false,
            isRadioBtnInputTextSet: option != -1,
            placeholder: placeholder),
      ],
    );
  }
}
