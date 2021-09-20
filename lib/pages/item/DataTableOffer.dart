import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/pages/item/ItemDisplay.dart';
import 'package:flutter_app/pages/search/CardItem.dart';

class DataTableOffer extends StatefulWidget {
  @override
  _DataTableOfferState createState() => _DataTableOfferState();
}

class _DataTableOfferState extends State<DataTableOffer> {
  @override
  Widget build(BuildContext context) {
    return Cards(
      props: null,
    );
  }
}

class Cards extends StatelessWidget {
  PropertyModel props;
  Cards({Key key, @required this.props}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        height: 360,
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
              padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    for (var i = 1; i <= 100; i++)
                      Column(children: <Widget>[
                        Row(
                          children: <Widget>[
                            Flexible(
                              flex: 1,
                              fit: FlexFit.loose,
                              child: new Text(
                                i.toString(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: true,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                            SizedBox(
                              width: 5,
                            ),
                            Flexible(
                              flex: 3,
                              fit: FlexFit.tight,
                              child: new Text(
                                "P 200,000,000,000.00",
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15),
                              ),
                            ),
                          ],
                        ),
                        new Padding(
                            padding: EdgeInsets.all(1.0),
                            child: new Divider(thickness: 1)),
                        SizedBox(
                          height: 10,
                        ),
                      ]),
                  ],
                ),
              ),
            )));
  }
}
