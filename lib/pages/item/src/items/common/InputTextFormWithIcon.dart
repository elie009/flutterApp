import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputTextFormWithIcon extends StatelessWidget {
  InputTextFormWithIcon({this.icons, this.placeholder, this.width, this.value});
  final double width;
  final TextEditingController value;
  final String placeholder;
  final Widget icons;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        maxLines: 1,
        controller: value,
        decoration: InputDecoration(
          prefixIcon: icons,
          hintText: placeholder,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
        ),
        // ignore: missing_return
        validator: (value) {
          if (value.trim().isEmpty) {
            return placeholder + " is Required";
          }
        },
      ),
    );
  }
}
