import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/item/add/ProprtyItemPage.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/profile/inventory/InventoryPage.dart';
import 'package:flutter_app/utils/Utils.dart';

class InventoryOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.calendar_today_outlined, color: primaryColor),
            label: Text('Manage', style: TextStyle(color: primaryColor)),
            onPressed: () {},
          ),
          SizedBox(width: 50),
          TextButton.icon(
            icon: Icon(Icons.add, color: primaryColor),
            label: Text('Add', style: TextStyle(color: primaryColor)),
            onPressed: () {
              //Navigator.push(context, ScaleRoute(page: PropertyItemPage()));
              Navigator.push(context, ScaleRoute(page: ItemAddFormPage()));
            },
          ),
          SizedBox(width: 50),
          TextButton.icon(
            icon: Icon(Icons.sort, color: primaryColor),
            label: Text('Filer', style: TextStyle(color: primaryColor)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
