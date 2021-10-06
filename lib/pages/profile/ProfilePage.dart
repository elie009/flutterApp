import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/database/items/DatabaseServiceProps.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/widgets/section/ImagePicker.dart';
import 'package:flutter_app/database/temp/DemoDataBase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ProfileStats.dart';
import 'inventory/InventoryPage.dart';

class ProfilePage extends StatefulWidget {
  final SharedPreferences prefs;
  ProfilePage({this.prefs});
  @override
  _ProfilePageState createState() {
    return new _ProfilePageState();
  }
}

class _ProfilePageState extends State<ProfilePage> {
  final PrepareData _data = PrepareData();

  List<Widget> _children = [Container(), Container()];
  DocumentReference profileReference;
  DocumentSnapshot profileSnapshot;
  final _yourNameController = TextEditingController();

  @override
  void initState() {
    super.initState();

    profileReference =
        DatabaseService().userCollection.doc(widget.prefs.getString('uid'));
    profileReference.snapshots().listen((querySnapshot) {
      profileSnapshot = querySnapshot;
      widget.prefs.setString('name', profileSnapshot.get("firstName"));
      widget.prefs.setString('profile_photo', profileSnapshot.get("uid"));

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
                                                profileSnapshot.get('uid'),
                                                profileSnapshot
                                                    .get('firstName'),
                                                profileSnapshot.get('image'),
                                                profileSnapshot.get('lastName'),
                                                profileSnapshot
                                                    .get('phoneNumber'),
                                                profileSnapshot.get('status'),
                                                profileSnapshot.get('email'),
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
                      "Robert Downey, Jr.",
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
                SizedBox(
                  height: 10.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 50.0,
                    ),
                    Text(
                      "Actor and Producer",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                          color: whiteColor),
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
                      onTap: () {},
                    ),
                  ],
                ),
                Divider(
                  height: 30.0,
                  color: whiteColor,
                ),
                ProfileStats(),
              ],
            ),
          ),
          Divider(
            height: 20.0,
            color: whiteColor,
          ),
          PreferredSize(
            preferredSize: Size.fromHeight(50.0),
            child: TabBar(
              labelColor: primaryColor,
              indicatorColor: primaryColor,
              unselectedLabelColor: grayColor,
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: TextStyle(
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(
                  text: 'Carry',
                ),
                Tab(
                  text: 'Inventory',
                ),
              ],
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height,
            child: TabBarView(
              children: [
                Container(
                  color: whiteColor,
                  child: Carry(),
                ),
                Container(
                  color: whiteColor,
                  child: Inventory(),
                ),
              ],
            ),
          ),
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
    return DefaultTabController(
      length: 2,
      child: Stack(
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

class GetClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0.0, size.height / 2.2);
    path.lineTo(size.width + 125.0, 0.0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class Carry extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 7.0,
        ),
      ],
    );
  }
}

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Center(
      child: StreamProvider<List<PropertyItemModel>>.value(
        value: DatabaseServiceItems().getByUid(user.uid),
        initialData: [],
        child: Container(
          child: Column(
            children: <Widget>[
              InventoryPage(),
            ],
          ),
        ),
      ),
    );
  }
}
