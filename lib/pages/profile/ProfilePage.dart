import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/add/ProprtyItemPage.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/widgets/section/ImagePicker.dart';
import 'package:flutter_app/database/temp/DemoDataBase.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../FoodOrderPage.dart';

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
                                width: 150.0,
                                height: 150.0,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: new NetworkImage(
                                          profileSnapshot.get('image')),
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(80.0),
                                    border: Border.all(
                                        width: 3, color: whiteColor)),
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
                Container(
                  width: 350.0,
                  height: 60.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Text(
                            "45",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            "Follower",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      VerticalDivider(
                        width: 70.0,
                        color: whiteColor,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "20",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            "Following",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      VerticalDivider(
                        width: 70.0,
                        color: whiteColor,
                      ),
                      Column(
                        children: <Widget>[
                          Text(
                            "30",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 22.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(
                            height: 2.0,
                          ),
                          Text(
                            "Post",
                            style: TextStyle(
                              color: whiteColor,
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
              ], // list of tabs
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
                ), // class name
              ],
            ),
          ),
          Divider(
            height: 20.0,
            color: Colors.black,
          ),
          // Container(
          //   color: Colors.lightGreen,
          //   width: MediaQuery.of(context).size.width,
          //   height: 130.0,
          //   child: Card(
          //     // color: Colors.amber,
          //     margin: EdgeInsets.symmetric(horizontal: 10.0),
          //     elevation: 5.0,
          //     child: Padding(
          //       padding: const EdgeInsets.all(20.0),
          //       child: Column(
          //         crossAxisAlignment: CrossAxisAlignment.start,
          //         children: <Widget>[
          //           InkWell(
          //             onTap: () {
          //               _data.execute();
          //             },
          //             child: Text(
          //               "Abouts",
          //               style: TextStyle(
          //                 fontSize: 20.0,
          //                 fontWeight: FontWeight.bold,
          //                 color: Colors.lightBlue,
          //               ),
          //             ),
          //           ),
          //           SizedBox(
          //             height: 7.0,
          //           ),
          //           Text(
          //             "Any thing you want to write here about yourself you can write that will fetch frome the database ok done.",
          //             style: TextStyle(
          //               fontSize: 16.0,
          //               color: Colors.grey,
          //             ),
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // ),
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
            child: Positioned(
              width: MediaQuery.of(context).size.width,
              top: MediaQuery.of(context).size.height / 6.0,
              // left: 76.0,
              child: generateProfileTab(),
            ),
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
        Positioned(
          width: MediaQuery.of(context).size.width,
          top: MediaQuery.of(context).size.height / 6.0,
          // left: 76.0,
          child: Container(
            width: double.infinity,
            height: 85,
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFADAD).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ]),
            child: Card(
                color: whiteColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(5.0),
                  ),
                ),
                child: Container(
                  alignment: Alignment.center,
                  padding:
                      EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 20),
                            alignment: Alignment.centerRight,
                            child: InventoryOption(),
                          )
                        ],
                      )
                    ],
                  ),
                )),
          ),
        ),
      ],
    );
  }
}

class InventoryOption extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          TextButton.icon(
            icon: Icon(Icons.calendar_today_outlined, color: primaryColor),
            label: Text('Manage', style: TextStyle(color: primaryColor)),
            onPressed: () {},
          ),
          SizedBox(width: 50),
          TextButton.icon(
            icon: Icon(Icons.add, color: primaryColor),
            label: Text('Add', style: TextStyle(color: primaryColor)),
            onPressed: () {
              Navigator.push(context, ScaleRoute(page: PropertyItemPage()));
            },
          ),
          SizedBox(width: 50),
          TextButton.icon(
            icon: Icon(Icons.sort, color: primaryColor),
            label: Text('Filer', style: TextStyle(color: primaryColor)),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class Inventory extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Center(
      child: StreamProvider<List<PropertyModel>>.value(
        value: DatabaseService().properyByOwnerId(user.uid),
        initialData: [],
        child: Container(
          child: Column(
            children: <Widget>[
              CardProperty(),
            ],
          ),
        ),
      ),
    );
  }
}

class CardProperty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<PropertyModel>>(context);
    return Column(
      children: <Widget>[
        SizedBox(
          height: 7,
        ),
        Container(
          width: double.infinity,
          height: 85,
          decoration: BoxDecoration(boxShadow: [
            BoxShadow(
              color: Color(0xFFADAD).withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ]),
          child: Card(
            color: whiteColor,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(
                Radius.circular(5.0),
              ),
            ),
            child: Container(
              margin: EdgeInsets.only(left: 20),
              alignment: Alignment.centerRight,
              child: InventoryOption(),
            ),
          ),
        ),
        for (PropertyModel i in items)
          Container(
            decoration: BoxDecoration(boxShadow: [
              BoxShadow(
                color: Color(0xFFADAD).withOpacity(0.3),
                spreadRadius: 1,
                blurRadius: 1,
                offset: Offset(0, 1),
              ),
            ]),
            child: Card(
              child: Positioned(
                width: MediaQuery.of(context).size.width,
                top: MediaQuery.of(context).size.height / 6.0,
                // left: 76.0,
                child: CartItem(
                    productName: textlimiter(i.title),
                    productPrice: "\$96.00",
                    productImage: "ic_popular_food_1",
                    productCartQuantity: "2"),
              ),
            ),
          ),
      ],
    );
  }
}
