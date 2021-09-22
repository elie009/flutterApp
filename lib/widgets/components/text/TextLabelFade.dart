import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextLabelFade extends StatelessWidget {
  const TextLabelFade({
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
    return SizedBox(
      width: width == null ? 130.0 : width,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: style),
    );
  }
}
