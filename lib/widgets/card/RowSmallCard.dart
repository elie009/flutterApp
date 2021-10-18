import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class RowSmallCard extends StatelessWidget {
  bool checkVal;
  String productName;
  String productPrice;
  String description;
  String imageId;
  final Function onCheckChange;

  RowSmallCard({
    this.checkVal,
    this.productPrice,
    this.description,
    this.onCheckChange,
    @required this.productName,
    @required this.imageId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 100,
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
            padding: EdgeInsets.only(left: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Center(
                      child: Container(
                        width: 50,
                        height: 50,
                        child: imageId.isEmpty
                            ? Image.asset(
                                "assets/images/popular_foods/ic_popular_food_4.png",
                              )
                            : Image.network(
                                imageId,
                                fit: BoxFit.fitWidth,
                              ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: 10, right: 5, top: 10, bottom: 10),
                  child: Column(
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
                                child: TextLabelByLine(
                                  width: 0.5,
                                  text: productName,
                                  style: TextStyle(
                                      fontSize: 15,
                                      color: Color(0xFF3a3a3b),
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Container(
                                  child: TextLabelFade(
                                width: 230,
                                text: productPrice != null
                                    ? productPrice
                                    : description,
                                style: TextStyle(
                                    fontSize: 17,
                                    color: Color(0xFF3a3a3b),
                                    fontWeight: FontWeight.bold),
                              )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (onCheckChange != null)
                  Checkbox(
                    value: checkVal,
                    onChanged: (bool newValue) {
                      onCheckChange(newValue);
                    },
                  ),
              ],
            ),
          )),
    );
  }
}
