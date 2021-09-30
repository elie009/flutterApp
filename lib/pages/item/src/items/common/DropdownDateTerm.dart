import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/DateHandler.dart';

// ignore: must_be_immutable
class DropdownDateTerm extends StatelessWidget {
  DropdownDateTerm({this.width, this.paceholder, this.value, this.onChanged});
  final String value;
  final Function onChanged;
  final String paceholder;
  final double width;

  var dropdownoption = termsDateCode;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Container(
        child: FormField<String>(
          builder: (FormFieldState<String> state) {
            return InputDecorator(
              decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0))),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  hint: Text(paceholder),
                  value: value,
                  isDense: true,
                  onChanged: (newValue) {
                    onChanged(newValue);
                  },
                  items: dropdownoption.map((DropdropValue value) {
                    return DropdownMenuItem<String>(
                      value: value.key,
                      child: Text(value.value),
                    );
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
