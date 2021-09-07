import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/FoodOrderPage.dart';
import 'package:flutter_app/pages/item/DataTableOffer.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';

class PopupOffer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      IconButton(
        onPressed: () => showDialog<String>(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('AlertDialog Tilte'),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            content: Builder(
              builder: (context) {
                // Get available height and width of the build area of this widget. Make a choice depending on the size.
                var height = MediaQuery.of(context).size.height;
                var width = MediaQuery.of(context).size.width;

                return Container(
                  height: height - 300,
                  width: width - 10,
                  child: Column(
                    children: <Widget>[
                      DataTableOffer(),
                      SizedBox(
                        height: 20,
                      ),
                      BottomMenu(),
                    ],
                  ),
                );
              },
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'Cancel'),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: const Text('OK'),
              ),
            ],

            // title: const Text('AlertDialog Tilte'),
            // content: const Text('AlertDialog description'),
            // actions: <Widget>[
            //   TextButton(
            //     onPressed: () => Navigator.pop(context, 'Cancel'),
            //     child: const Text('Cancel'),
            //   ),
            //   TextButton(
            //     onPressed: () => Navigator.pop(context, 'OK'),
            //     child: const Text('OK'),
            //   ),
            // ],
          ),
        ),
        icon: Icon(Icons.local_offer_outlined),
        color: Color(0xFFfd2c2c),
        iconSize: 30,
      ),
      Text(
        "Send Offer",
        style: TextStyle(
            fontSize: 14, color: Colors.black, fontWeight: FontWeight.w300),
      )
    ]);
  }
}

class PopupCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}

class BottomMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 10, top: 5, right: 10, bottom: 5),
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
              hintStyle: new TextStyle(color: Color(0xFFd0cece), fontSize: 18),
              hintText: "Please input bid amount",
            ),
          ),
        ),
        SizedBox(
          height: 15,
        ),
        InkWell(
          onTap: () {
            Navigator.push(context, ScaleRoute(page: FoodOrderPage()));
          },
          child: Container(
            width: 200.0,
            height: 45.0,
            decoration: new BoxDecoration(
              color: Color(0xFFfd2c2c),
              border: Border.all(color: Colors.white, width: 2.0),
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: Center(
              child: Text(
                'Offer a Bid',
                style: new TextStyle(
                    fontSize: 18.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
