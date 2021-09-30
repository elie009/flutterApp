import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioBtn extends StatelessWidget {
  const RadioBtn({
    Key key,
    @required this.label,
    @required this.value,
    @required this.valueController,
    @required this.onChanged,
  }) : super(key: key);

  final String label;
  final int value;
  final int valueController;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: Radio(
        value: value,
        groupValue: valueController,
        onChanged: (newvalue) {
          onChanged(newvalue);
        },
        activeColor: Colors.green,
      ),
    );
  }
}
