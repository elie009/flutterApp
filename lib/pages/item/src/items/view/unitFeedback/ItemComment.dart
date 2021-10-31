import 'package:flutter/cupertino.dart';
import 'package:flutter_app/model/ItemCommentModel.dart';

class ItemComment extends StatelessWidget {
  final List<ItemCommentModel> comments;
  ItemComment({this.comments});

  @override
  Widget build(BuildContext context) {
    return this.comments.isEmpty
        ? Align(
            alignment: Alignment.topLeft,
            child: Container(
                padding: EdgeInsets.all(10),
                child: Text(
                  'No comments yet',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                )),
          )
        : Container();
  }
}
