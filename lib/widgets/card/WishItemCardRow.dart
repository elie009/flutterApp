import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/WishListModel.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class WishItemCardRow extends StatelessWidget {
  final WishListModel wishItem;
  final Function onChangeCheckbox;
  final Function onClickCard;
  WishItemCardRow({
    @required this.onClickCard,
    @required this.wishItem,
    @required this.onChangeCheckbox,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onClickCard();
      },
      child: Container(
        width: double.infinity,
        height: 110,
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
                          child: Image.asset(
                        "assets/images/popular_foods/ic_popular_food_4.png",
                        width: 50,
                        height: 50,
                      )),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 10, top: 10, bottom: 10),
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
                                    width: 0.4,
                                    text: wishItem.title,
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
                                    width: 190,
                                    text: wishItem.message,
                                    style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF3a3a3b),
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 40,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Checkbox(
                    value: wishItem.isSelect,
                    onChanged: (bool newValue) {
                      onChangeCheckbox(newValue);
                    },
                  ),
                ],
              ),
            )),
      ),
    );
  }
}
