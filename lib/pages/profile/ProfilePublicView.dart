import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/temp/DemoDataBase.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:flutter_app/pages/profile/ProfileStats.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/section/ImagePicker.dart';

class ProfilePublicView extends StatefulWidget {
  final UserBaseModel user;
  ProfilePublicView({this.user});
  @override
  _ProfilePublicViewState createState() {
    return new _ProfilePublicViewState();
  }
}

class _ProfilePublicViewState extends State<ProfilePublicView> {
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;
  final _yourNameController = TextEditingController();
  List<Widget> _children = [Container(), Container()];
  final PrepareData _data = PrepareData();

  @override
  void initState() {
    super.initState();

    profileReference = DatabaseService().userCollection.doc(widget.user.uid);
    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
      setState(() {
        _yourNameController.text = profileSnapshot.get("firstName");
      });
    });
  }

  generateProfileTab() {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: primaryColor,
            child: Column(
              children: [
                Stack(
                  children: <Widget>[
                    SizedBox(
                      height: 100,
                    ),
                    (profileSnapshot != null
                        ? (profileSnapshot.get('image') != null
                            ? Container(
                                margin: const EdgeInsets.only(top: 50.0),
                                width: 100.0,
                                height: 100.0,
                                decoration: new BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: yellowamber,
                                        width: 3.0,
                                        style: BorderStyle.solid),
                                    image: new DecorationImage(
                                        fit: BoxFit.cover,
                                        image: AssetImage(
                                            'assets/images/bestfood/ic_best_food_8.jpeg'))),
                              )
                            : Container())
                        : Container()),
                    (profileSnapshot != null
                        ? (profileSnapshot.get('uid') != null
                            ? Positioned(
                                bottom: 20.0,
                                right: 20.0,
                                child: InkWell(
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 28.0,
                                  ),
                                  onTap: () {
                                    showModalBottomSheet(
                                        context: context,
                                        builder: ((builder) =>
                                            ImagePickerWidget(
                                              usrobj: UserBaseModel(
                                                uid: profileSnapshot.get('uid'),
                                                firstName: profileSnapshot
                                                    .get('firstName'),
                                                image: profileSnapshot
                                                    .get('image'),
                                                lastName: profileSnapshot
                                                    .get('lastName'),
                                                phoneNumber: profileSnapshot
                                                    .get('phoneNumber'),
                                                status: profileSnapshot
                                                    .get('status'),
                                                email: profileSnapshot
                                                    .get('email'),
                                              ),
                                            )));
                                  },
                                ),
                              )
                            : Container())
                        : Container()),
                  ],
                ),
                SizedBox(
                  height: 18.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 50.0,
                    ),
                    Text(
                      profileSnapshot == null
                          ? ''
                          : profileSnapshot.get('displayName'),
                      style: TextStyle(
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold,
                        color: whiteColor,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    InkWell(
                      child: Icon(
                        Icons.create,
                        size: 18.0,
                        color: whiteColor,
                      ),
                      onTap: () {
                        _data.execute();
                      },
                    ),
                  ],
                ),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: <Widget>[
                //     SizedBox(
                //       width: 50.0,
                //     ),
                //     Text(
                //       profileSnapshot == null
                //           ? ''
                //           : profileSnapshot.get('firstName') +
                //               " " +
                //               profileSnapshot.get('lastName'),
                //       style: TextStyle(
                //           fontSize: 16.0,
                //           fontWeight: FontWeight.bold,
                //           color: whiteColor),
                //     ),
                //     SizedBox(
                //       width: 10.0,
                //     ),
                //     InkWell(
                //       child: Icon(
                //         Icons.create,
                //         size: 18.0,
                //         color: whiteColor,
                //       ),
                //       onTap: () {},
                //     ),
                //   ],
                // ),
                Divider(
                  height: 30.0,
                  color: whiteColor,
                ),
                ProfileStats(
                  follower: 0,
                  following: 0,
                  post: 0,
                ),
              ],
            ),
          ),
          Divider(
            height: 20.0,
            color: whiteColor,
          ),
          Inventory(),
          Divider(
            height: 20.0,
            color: Colors.black,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _children = [
      generateProfileTab(),
    ];
    return Scaffold(
      body: Stack(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          SingleChildScrollView(
            child: generateProfileTab(),
          ),
        ],
      ),
    );
  }
}
