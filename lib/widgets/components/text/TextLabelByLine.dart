import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Constant.dart';

class TextLabelByLine extends StatelessWidget {
  const TextLabelByLine({
    Key key,
    @required this.text,
    @required this.style,
    this.width,
  }) : super(key: key);

  final String text;
  final TextStyle style;
  final double width;

  @override
  Widget build(BuildContext context) {
    double screenwidth = widthScreen(context) * (width == null ? 0.9 : width);
    return new Container(
      width: screenwidth,
      child: new Text(text, textAlign: TextAlign.left, style: style),
    );
  }
}
