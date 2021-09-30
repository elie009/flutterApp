import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/pages/item/ItemDisplay.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyCard extends StatefulWidget {
  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<PropertyModel>>(context);
    return Column(
      children: <Widget>[
        for (PropertyModel i in items)
          if (i.status == 'APPROVE')
            Cards(
              props: PropertyModel.instance(i),
              prefs: null,
            )
      ],
    );
  }
}

class Cards extends StatelessWidget {
  PropertyModel props;
  final SharedPreferences prefs;
  Cards({Key key, @required this.props, this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context, ScaleRoute(page: ItemDetailsPage(props: props)));
        print('this is card item');
      },
      child: Container(
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
                padding:
                    EdgeInsets.only(left: 10, right: 5, top: 5, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Center(
                            child: Image.asset(
                          "assets/images/bestfood/ic_best_food_8.jpeg",
                        )),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: <Widget>[
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: new Text(
                            "P " + oCcy.format(props.saleFixPrice),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Flexible(
                          flex: 1,
                          fit: FlexFit.loose,
                          child: new Text(
                            "(SOLD)",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                        ),
                      ],
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: new Text(
                        "Introduction to Very very very long textxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(color: Colors.black, fontSize: 15),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Flexible(
                      flex: 1,
                      fit: FlexFit.loose,
                      child: new Text(
                        "Cebu City, Central Visayas",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        softWrap: false,
                        style: TextStyle(color: Colors.grey, fontSize: 15),
                      ),
                    ),
                  ],
                ))),
      ),
    );
  }
}
