import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/ModalBox.dart';

class SearchWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
      child: TextField(
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
          prefixIcon: Icon(
            Icons.search,
            color: primaryColor,
          ),
          fillColor: Color(0xFFFAFAFA),
          suffixIcon: IconButton(
            icon: Icon(Icons.sort),
            color: primaryColor,
            onPressed: () {
              ModalBox();
              showModalBottomSheet<void>(
                  context: context,
                  builder: (BuildContext context) {
                    return ModalBox();
                  });
            },
          ),
          hintStyle: new TextStyle(color: Color(0xFFd0cece), fontSize: 18),
          hintText: "What would your like to buy?",
        ),
      ),
    );
  }
}
