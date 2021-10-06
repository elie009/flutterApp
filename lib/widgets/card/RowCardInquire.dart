import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/widgets/components/Button1.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class RowCardInquire extends StatelessWidget {
  PropertyItemModel props;
  RowCardInquire({
    Key key,
    @required this.props,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Center(
                        child: Image.asset(
                      "assets/images/popular_foods/ic_popular_food_1.png",
                      width: 110,
                      height: 100,
                    )),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: TextLabelFade(
                                  text: props.title,
                                  style: TextStyle(
                                      fontSize: 18,
                                      color: Color(0xFF3a3a3b),
                                      fontWeight: FontWeight.w400),
                                  width: 230),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              child: Text(
                                props.price.toString(),
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF3a3a3b),
                                    fontWeight: FontWeight.bold),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          InkWell(
                              onTap: () {
                                print('click book now');
                              },
                              child: Button1(
                                'Save',
                              )),
                          InkWell(
                              onTap: () {
                                print('click book now');
                              },
                              child: Button1(
                                'Book now',
                              )),
                        ],
                      ),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}
