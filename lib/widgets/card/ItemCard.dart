import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/item/ItemViewDetails.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class ItemCard extends StatelessWidget {
  const ItemCard({Key key, @required this.props, this.inputheight})
      : super(key: key);

  final double inputheight;

  final PropertyModel props;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, ScaleRoute(page: ItemViewDetails(props: props)));
      },
      child: Column(
        children: <Widget>[
          Container(
            height: inputheight,
            padding: EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 5),
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFfae3e2),
                blurRadius: 15.0,
                offset: Offset(0, 0.75),
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
                  width: 170,
                  height: null,
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          Align(
                            alignment: Alignment.topRight,
                            child: Container(
                              alignment: Alignment.topRight,
                              width: double.infinity,
                              padding: EdgeInsets.only(right: 5, top: 5),
                              child: Container(
                                height: 20,
                                width: 28,
                                decoration: BoxDecoration(
                                    shape: BoxShape.rectangle,
                                    color: Colors.white70,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFfae3e2),
                                        blurRadius: 25.0,
                                        offset: Offset(0.0, 0.75),
                                      ),
                                    ]),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Center(
                                child: Image.asset(
                              props.imageName.isEmpty
                                  ? Constants.itemCard1img
                                  : props.imageName,
                            )),
                          )
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  ScaleRoute(
                                      page: ItemViewDetails(props: props)));
                            },
                            child: Container(
                                alignment: Alignment.bottomLeft,
                                padding: EdgeInsets.only(left: 5, top: 5),
                                child: TextLabelFade(
                                    text: props.title,
                                    style: TextStyle(
                                        color: Color(0xFF6e6e71),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold))),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  ScaleRoute(
                                      page: ItemViewDetails(props: props)));
                            },
                            child: Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.only(right: 5),
                              child: Container(
                                height: 28,
                                width: 28,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white70,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFFfae3e2),
                                        blurRadius: 25.0,
                                        offset: Offset(0.0, 0.75),
                                      ),
                                    ]),
                                child: Icon(
                                  Icons.flag_outlined,
                                  color: Color(0xFFfb3132),
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  ScaleRoute(
                                      page: ItemViewDetails(props: props)));
                            },
                            child: Container(
                                alignment: Alignment.bottomLeft,
                                padding:
                                    EdgeInsets.only(left: 5, top: 0, right: 0),
                                child: TextLabelFade(
                                    text: '\P ' +
                                        // formatCurency(
                                        //     props.saleFixPrice.toString()),
                                        props.saleFixPrice.toString(),
                                    style: TextStyle(
                                        color: Color(0xFF6e6e71),
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold))),
                          )
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(context,
                              ScaleRoute(page: ItemViewDetails(props: props)));
                        },
                        child: Container(
                          alignment: Alignment.bottomLeft,
                          padding: EdgeInsets.only(left: 5, top: 5, right: 5),
                          child: TextLabelFade(
                              text: props.location,
                              style: TextStyle(
                                  color: Color(0xFF6e6e71),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(width: 1),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Container(
                                    padding: EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      Icons.message,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                    text: props.numComments.toString(),
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Container(
                                    padding: EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      Icons.thumb_up_outlined,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                    text: props.numLikes.toString(),
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          SizedBox(width: 5),
                          RichText(
                            text: TextSpan(
                              children: [
                                WidgetSpan(
                                  child: Container(
                                    padding: EdgeInsets.only(right: 3.0),
                                    child: Icon(
                                      Icons.remove_red_eye_outlined,
                                      size: 14,
                                      color: primaryColor,
                                    ),
                                  ),
                                ),
                                TextSpan(
                                    text: props.numViews.toString(),
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                          SizedBox(width: 1),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      )
                    ],
                  ),
                )),
          ),
        ],
      ),
    );
  }
}
