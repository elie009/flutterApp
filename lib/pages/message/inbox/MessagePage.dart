import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/message/inspector/MessageInspecter.dart';
import 'package:provider/provider.dart';

class MessagePage extends StatefulWidget {
  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    setState(() {
      messageInspector(user, context);
    });
    return Container();
  }
}
