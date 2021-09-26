import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PropsResidence extends StatefulWidget {
  @override
  _PropsResidenceState createState() => _PropsResidenceState();
}

class _PropsResidenceState extends State<PropsResidence> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          title: Text(
            "Property Residence form",
            style: TextStyle(
                color: Color(0xFF3a3737),
                fontSize: 16,
                fontWeight: FontWeight.w500),
          ),
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          actions: <Widget>[
            IconButton(
                icon: Icon(
                  Icons.notifications_none,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () {})
          ],
        ),
        body: Container());
  }
}
