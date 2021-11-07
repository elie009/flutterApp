import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/home/BodyContent.dart';
import 'package:flutter_app/pages/home/topmenu/TopMenus.dart';
import 'package:flutter_app/service/Auth.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';
import 'package:flutter_app/widgets/section/SearchWidget.dart';
import 'package:flutter_app/widgets/section/CommonPageDisplay.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BodyContainer extends StatefulWidget {
  final UserBaseModel user;
  BodyContainer({Key key, this.user}) : super(key: key);
  @override
  State<StatefulWidget> createState() => _BodyContainer();
}

class _BodyContainer extends State<BodyContainer> {
  final AuthService _auth = AuthService();

  Future countUserInfo(String uid) {
    DatabaseServiceItems.propertyCollection
        .where('ownerUid', isEqualTo: uid)
        .get()
        .then((value) {
      print(value.docs.length);
      DatabaseService()
          .userCollection
          .doc(uid)
          .update({"post": value.docs.length.toString()});
    });
  }

  @override
  void initState() {
    countUserInfo(widget.user.uid);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 30),
      child: Column(children: [
        Wrap(
          alignment: WrapAlignment.start,
          direction: Axis.horizontal,
          children: [
            SearchWidget(
              widthFactor: 0.7,
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 5),
              child: IconButton(
                icon: Icon(Icons.sort),
                color: primaryColor,
                onPressed: () {
                  showModalBottomSheet<void>(
                      context: context,
                      builder: (BuildContext context) {
                        return ModalBox();
                      });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 8, bottom: 5),
              child: IconButton(
                icon: Icon(FontAwesomeIcons.bell),
                color: primaryColor,
                onPressed: () async {
                  await _auth.signOut();
                },
              ),
            ),
          ],
        ),
        TopMenus(),
        Expanded(
            child: Container(
          height: 400,
          width: double.infinity,
          child: Column(
            children: <Widget>[
              Expanded(child: CommonPageDisplay(body: BodyContent())),
            ],
          ),
        ))
      ]),
    );
  }
}
