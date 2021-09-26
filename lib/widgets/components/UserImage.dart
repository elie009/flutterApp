import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Utils.dart';

class UserImage extends StatelessWidget {
  const UserImage({
    Key key,
    @required this.image,
  }) : super(key: key);

  final String image;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.0),
      child: new Container(
        child: new CircleAvatar(
          child: Image.asset(defaultProfileImg),
        ),
      ),
    );
  }
}
