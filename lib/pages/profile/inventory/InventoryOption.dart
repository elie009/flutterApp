import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/pages/item/itemform/ItemAddFormPage.dart';
import 'package:flutter_app/pages/profile/inventory/InventoryPage.dart';
import 'package:flutter_app/utils/Constant.dart';

class InventoryOption extends StatefulWidget {
  @override
  _InventoryOptionState createState() => _InventoryOptionState();
}

class _InventoryOptionState extends State<InventoryOption> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          _buildButtonColumn(Icons.calendar_today_outlined, 'Manage', () {
            setState(() {});
          }),
          _buildButtonColumn(Icons.add, 'Add', () {
            setState(() {
              Navigator.push(context, ScaleRoute(page: ItemAddFormPage()));
            });
          }),
          _buildButtonColumn(Icons.sort, 'Filer', () {
            setState(() {});
          }),
        ],
      ),
    );
  }

  Column _buildButtonColumn(IconData icon, String label, Function onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton.icon(
          icon: Icon(icon, color: primaryColor),
          label: Text(label, style: TextStyle(color: primaryColor)),
          onPressed: () {
            onChanged();
          },
        ),
      ],
    );
  }
}
