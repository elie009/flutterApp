import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/utils/Utils.dart';

class InputPage extends StatefulWidget {
  @override
  _InputPageState createState() => _InputPageState();
}

class _InputPageState extends State<InputPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFFAFAFA),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Center(
                child: Text(
                  "Item Carts",
                  style: TextStyle(
                      color: Color(0xFF3a3737),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              brightness: Brightness.light,
            ),
            body: Container(
              color: lightgrayColor,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 10,
                  ),
                  Card(
                    child: TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          borderSide: BorderSide(
                            width: 0,
                            color: Color(0xFFfb3132),
                            style: BorderStyle.none,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
                        hintStyle: new TextStyle(
                            color: Color(0xFFd0cece), fontSize: 18),
                        hintText: "Please input title",
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      width: double.infinity,
                      height: 45.0,
                      decoration: new BoxDecoration(
                        color: primaryColor,
                        border: Border.all(color: Colors.white, width: 2.0),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Center(
                        child: Text(
                          'Submit',
                          style: new TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
