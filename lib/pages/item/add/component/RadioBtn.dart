import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class RadioBtn extends StatelessWidget {
  const RadioBtn({
    Key key,
    @required this.label,
    @required this.value,
    @required this.onChanged,
  }) : super(key: key);

  final String label;
  final int value;
  final Function onChanged;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      leading: Radio(
        value: 2,
        groupValue: value,
        onChanged: (newvalue) {
          onChanged(newvalue);
        },
        activeColor: Colors.green,
      ),
    );
  }
}
