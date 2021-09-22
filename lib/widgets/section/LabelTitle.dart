import 'package:flutter/cupertino.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';
import 'package:flutter_app/widgets/components/text/TextLabelFade.dart';

class LabelTitle extends StatelessWidget {
  LabelTitle({Key key, @required this.title, this.style}) : super(key: key);
  final String title;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 10, right: 10, top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          TextLabelByLine(
            text: title,
            style: style == null
                ? TextStyle(
                    color: Color(0xFF3a3a3b),
                    fontSize: 20,
                    fontWeight: FontWeight.w300)
                : style,
            width: 0.9,
          ),
        ],
      ),
    );
  }
}
