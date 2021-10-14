import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:provider/provider.dart';

// ignore: must_be_immutable
class DropdownCategory extends StatelessWidget {
  DropdownCategory({this.width, this.paceholder, this.value, this.onChanged});
  final String value;
  final Function onChanged;
  final String paceholder;
  final double width;
  static Map<String, String> frequencyOptions = Constants.category;

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
                  value: value.isEmpty ? null : value,
                  isDense: true,
                  onChanged: (newValue) {
                    onChanged(newValue);
                  },
                  items: frequencyOptions
                      .map((key, value) {
                        return MapEntry(
                            key,
                            DropdownMenuItem<String>(
                              value: key,
                              child: Text(value),
                            ));
                      })
                      .values
                      .toList(),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
