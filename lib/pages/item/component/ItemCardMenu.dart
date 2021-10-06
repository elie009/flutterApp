import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/booking/BookingPage.dart';
import 'package:flutter_app/pages/message/inspector/ChatInspector.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:provider/provider.dart';

import '../PopupOffer.dart';

class ItemCardMenu extends StatefulWidget {
  ItemCardMenu({@required this.props});
  final PropertyItemModel props;

  @override
  _ItemCardMenuState createState() => _ItemCardMenuState();
}

class _ItemCardMenuState extends State<ItemCardMenu> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(primaryColor, Icons.access_time, 'Book', () {
            setState(() {
              Navigator.push(context, ScaleRoute(page: BookingPage()));
            });
          }),
          _buildButtonColumn(
              primaryColor, Icons.local_offer_outlined, 'Send Offer', () {
            setState(() {});
          }),
          _buildButtonColumn(primaryColor, Icons.message_outlined, 'Message',
              () {
            setState(() {
              chatInspector(user, widget.props, context);
            });
          }),
          _buildButtonColumn(primaryColor, Icons.save_alt, 'Save', () {
            setState(() {});
          }),
        ],
      ),
    );
  }

  Column _buildButtonColumn(
      Color color, IconData icon, String label, Function onChanged) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            onChanged();
          },
          icon: Icon(icon),
          color: primaryColor,
          iconSize: 30,
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 14, color: color, fontWeight: FontWeight.w400),
        ),
      ],
    );
  }
}
