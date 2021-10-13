import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class InputTextArea extends StatelessWidget {
  InputTextArea({this.placeholder, this.value, this.width});
  final String placeholder;
  final TextEditingController value;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextFormField(
        minLines: 5,
        maxLines: 7,
        decoration: InputDecoration(
            border: OutlineInputBorder(),
            isDense: true,
            labelText: placeholder),
        // decoration: InputDecoration(
        //   prefixIcon: const Icon(
        //     Icons.home,
        //     color: Colors.grey,
        //   ),
        //   hintText: placeholder,
        //   border: OutlineInputBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
        //   ),
        // ),
        controller: value,
      ),
    );
  }
}
