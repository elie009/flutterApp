import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

class ModalBox extends StatelessWidget {
  final Widget body;
  final bool isCloseDisplay;
  final bool isOkDisplay;
  final String textlabel;
  final double height;
  final Color color;
  final Function onClickOk;

  const ModalBox(
      {this.color,
      this.isOkDisplay,
      this.onClickOk,
      this.height,
      this.isCloseDisplay,
      this.textlabel,
      this.body});

  @override
  Widget build(BuildContext context) {
    var checkCloseBtn = isCloseDisplay == null ? true : isCloseDisplay;
    var checkOkBtn = isOkDisplay == null ? false : isOkDisplay;
    return Container(
      height: height == null ? 200 : height,
      color: color == null ? yellowamber : color,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (textlabel != null) new Text(textlabel),
            body == null ? Container() : body,
            Row(
              children: <Widget>[
                if (checkOkBtn)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          onClickOk('test');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                if (checkCloseBtn)
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: ElevatedButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
