import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextLabel extends StatelessWidget {
  const TextLabel({
    Key key,
    @required this.text,
    @required this.style,
  }) : super(key: key);

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130.0,
      child: Text(text,
          maxLines: 1,
          overflow: TextOverflow.fade,
          softWrap: false,
          style: style),
    );
  }
}
