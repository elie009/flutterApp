import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';

/* List input   F002
* String        F004
* Doubles       F005
*/

class InputTextForm extends StatelessWidget {
  const InputTextForm({
    Key key,
    @required this.label,
    @required this.value,
    @required this.onChanged,
    @required this.fieldCode,
  }) : super(key: key);
  final String label;
  final String value;
  final Function onChanged;
  final String fieldCode;

  @override
  Widget build(BuildContext context) {
    var inputText = TextEditingController();

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(width: 1.0, color: grayColor),
        ),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
              child: Text(
            label,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          )),
          TextField(
            keyboardType: TextInputType.text,
            controller: inputText,
            decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  borderSide: BorderSide(
                    width: 0,
                    color: primaryColor,
                    style: BorderStyle.none,
                  ),
                ),
                filled: true,
                fillColor: whiteColor,
                hintStyle: new TextStyle(color: grayColor, fontSize: 18),
                hintText: "Enter here"),
          ),
          Expanded(
              child: Text(
            value.isNotEmpty && value != '0.0' ? value : 'Set',
            textAlign: TextAlign.right,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: blackColor),
          )),
          SizedBox(
            width: 10,
          ),
          IconButton(
            onPressed: () {
           
            },
            icon: Icon(
              Icons.edit,
              color: primaryColor,
              size: 25,
            ),
          )
        ],
      ),
    );
  }
}
