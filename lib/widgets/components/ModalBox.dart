import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

class ModalBox extends StatelessWidget {
  final Widget body;
  final bool isCloseDisplay;
  final String textlabel;

  const ModalBox({this.isCloseDisplay, this.textlabel, this.body});

  @override
  Widget build(BuildContext context) {
    var checkCloseBtn = isCloseDisplay == null ? true : isCloseDisplay;
    return Container(
      height: 200,
      color: yellowamber,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (textlabel != null) new Text(textlabel),
            body == null ? Container() : body,
            if (checkCloseBtn)
              ElevatedButton(
                child: const Text('Close BottomSheet'),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
          ],
        ),
      ),
    );
  }
}
