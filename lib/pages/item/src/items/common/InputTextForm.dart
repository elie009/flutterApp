import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputTextForm extends StatelessWidget {
  InputTextForm(
      {this.isText,
      this.isRadioBtnInputTextSet,
      this.isReadOnly,
      this.value,
      this.placeholder,
      this.width});
  final TextEditingController value;
  final String placeholder;
  final double width;
  final bool isText;
  final bool isReadOnly;
  final bool isRadioBtnInputTextSet;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        readOnly: isReadOnly,
        keyboardType: isText ? TextInputType.text : TextInputType.number,
        maxLines: 1,
        decoration: InputDecoration(
          hintText: placeholder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        // ignore: missing_return
        validator: (resultvalue) {
          if (resultvalue.trim().isEmpty) {
            return placeholder + " is Required";
          }
        },
        controller: value,
      ),
    );
  }
}
