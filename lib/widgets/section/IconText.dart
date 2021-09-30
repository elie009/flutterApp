import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';

class IconText extends StatelessWidget {
  IconText({
    Key key,
    @required this.text,
    @required this.value,
    @required this.icon,
  }) : super(key: key);
  final String text;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          TextLabelByLine(
              text: text,
              style: TextStyle(
                  color: blackColor, fontSize: 17, fontWeight: FontWeight.w300),
              width: 0.9),
          Align(
            alignment: Alignment.center,
            child: Text(
              value,
              style: TextStyle(
                  color: blackColor, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );

    // Row(
    //   crossAxisAlignment: CrossAxisAlignment.start,
    //   children: [
    //     SizedBox(
    //       width: 10,
    //     ),
    //     Container(
    //       width: 200,
    //       color: Colors.orange,
    //       child: Text(
    //         "Hello",
    //         textAlign: TextAlign.end, // has impact
    //       ),
    //     ),
    //     Align(
    //       alignment: Alignment.topLeft,
    //       child: Text(
    //         value,
    //         style: TextStyle(
    //             color: blackColor, fontSize: 15, fontWeight: FontWeight.w500),
    //       ),
    //     )
    //   ],
    // );

    // RichText(
    //   text: TextSpan(
    //     children: [
    //       WidgetSpan(
    //         child: Padding(
    //           padding: const EdgeInsets.only(right: 10),
    //           child: Icon(icon, size: 20),
    //         ),
    //       ),
    //       TextSpan(
    //         style: TextStyle(
    //             color: blackColor, fontSize: 18, fontWeight: FontWeight.w100),
    //         text: text,
    //       ),
    //     ],
    //   ),
    // );
  }
}
