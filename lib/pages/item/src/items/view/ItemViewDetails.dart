import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/ItemCommentModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/model/WishListModel.dart';
import 'package:flutter_app/pages/FoodDetailsPage.dart';
import 'package:flutter_app/pages/item/src/items/view/unitFeedback/ItemComment.dart';
import 'package:flutter_app/pages/item/src/items/view/unitSeller/SellerInfo.dart';
import 'package:flutter_app/pages/item/src/items/view/unitSimilarItem/SuggestItem.dart';
import 'package:flutter_app/pages/profile/ProfilePage.dart';
import 'package:flutter_app/pages/profile/ProfilePublicView.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/widgets/card/WishItemCardRow.dart';
import 'package:flutter_app/widgets/components/CarouselSlider.dart';
import 'package:flutter_app/widgets/components/ModalBox.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';

import 'unitMenu/ItemCardMenu.dart';
import 'unitDetails/ItemViewBodyContent.dart';

class ItemViewDetails extends StatefulWidget {
  ItemViewDetails({@required this.props, this.user});
  PropertyItemModel props;
  UserBaseModel user;
  bool userlikethispost = false;
  @override
  _ItemViewDetailsState createState() => _ItemViewDetailsState();
}

class _ItemViewDetailsState extends State<ItemViewDetails>
    with TickerProviderStateMixin {
  AnimationController _ColorAnimationController;
  AnimationController _TextAnimationController;
  Animation _colorTween, _iconColorTween;
  Animation<Offset> _transTween;
  UserBaseModel user;

  int offercounts = 0;
  Future<dynamic> get getWishApplication async {
    DatabaseServiceItems.propertyCollection
        .doc(widget.props.propid)
        .collection('wishapplication')
        .doc(widget.user.uid)
        .snapshots()
        .listen((event2) {
      var x = event2.data() == null ? null : event2.data()['propsid'];
      offercounts = x == null ? 0 : x.length;
    });
  }

  List<PropertyItemModel> similaritem = [];
  Future<dynamic> get getSimilarItem async {
    DatabaseServiceItems.propertyCollection
        .where("menuid", isEqualTo: widget.props.menuid)
        //.where('propid', isNotEqualTo: widget.props.propid)
        .limit(10)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        if (element.get('propid') != widget.props.propid)
          similaritem.add(PropertyItemModel.snapshot(element));
      });
    });
  }

  Future get getCurrentOwner async {
    await DatabaseService()
        .userCollection
        .doc(widget.props.ownerUid)
        .get()
        .then((value) {
      setState(() {
        user = new UserBaseModel(
          displayName: value.get('displayName').toString(),
          image: value.get('image').toString(),
          location: value.get('location').toString(),
          uid: value.get('uid').toString(),
          createdDate: value.get('createdDate').toString(),
          status: value.get('status').toString(),
          post: value.get('post'),
          ratings: value.get('ratings'),
          response: value.get('response'),
          followers: value.get('followers'),
          following: value.get('following'),
        );
      });
    });
  }

  List<ItemCommentModel> comment = [];
  Future get getItemComment async {
    await DatabaseServiceItems.propertyCollection
        .doc(widget.props.propid)
        .collection('comment')
        .get()
        .then((value) {
      setState(() {
        print(value.docs.length);
        value.docs.forEach((element) {
          element.data()['comment'];
        });
      });
    });
  }

  @override
  void initState() {
    updateView(widget.props.propid, widget.user.uid);
    checkUserLike;
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent, end: whiteColor)
        .animate(_ColorAnimationController);
    _iconColorTween = ColorTween(begin: Colors.grey, end: Colors.white)
        .animate(_ColorAnimationController);

    _TextAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _transTween = Tween(begin: Offset(-10, 60), end: Offset(-10, 0))
        .animate(_TextAnimationController);
    if (widget.props.forSwap) getWishApplication;
    getData(widget.props.propid);
    getCurrentOwner;
    getItemComment;
    getSimilarItem;
    getCategory(widget.props.menuid, widget.props.forRent, widget.props.forSale,
        widget.props.forInstallment, widget.props.forSwap);

    if (widget.props.forSwap) getWishlist(widget.props.propid);
    super.initState();
  }

  bool _scrollListener(ScrollNotification scrollInfo) {
    if (scrollInfo.metrics.axis == Axis.vertical) {
      _ColorAnimationController.animateTo(scrollInfo.metrics.pixels / 350);

      _TextAnimationController.animateTo(
          (scrollInfo.metrics.pixels - 350) / 50);
      return true;
    }
  }

  List<String> listimage = [];
  Future<dynamic> getData(String propsid) async {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('media')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          listimage.add(element.data()['urls']);
        });
      });
    });
  }

  Future<dynamic> updateView(String propsid, String uid) async {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('views')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) {
      if (value.docs.length == 0) {
        DatabaseServiceItems.propertyCollection
            .doc(propsid)
            .collection('views')
            .doc('views')
            .set({'dateview': getDateNow, 'uid': uid}).then((value) {
          widget.props.numViews = 1;
        });
      } else {
        int view = value.docs.length;
        DatabaseServiceItems.propertyCollection
            .doc(propsid)
            .update({'numViews': view}).then((value) {
          widget.props.numViews = view;
        });
      }
    });
  }

  Future<dynamic> get checkUserLike async {
    DatabaseServiceItems.propertyCollection
        .doc(widget.props.propid)
        .collection('likes')
        .where('uid', isEqualTo: widget.user.uid)
        .get()
        .then((value) {
      if (value.docs.length != 0) {
        widget.userlikethispost = true;
      }
    });
  }

  Future<dynamic> clickLikes(String propsid, String uid) async {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('likes')
        .where('uid', isEqualTo: uid)
        .get()
        .then((value) {
      int likes = value.docs.length;
      if (likes == 0) {
        DatabaseServiceItems.propertyCollection
            .doc(propsid)
            .collection('likes')
            .doc(uid)
            .set({'date': getDateNow, 'uid': uid}).then((value) {
          setState(() {
            widget.props.numLikes += 1;
            widget.userlikethispost = true;
          });
          DatabaseServiceItems.propertyCollection
              .doc(propsid)
              .update({'numLikes': widget.props.numLikes});
        });
      } else {
        DatabaseServiceItems.propertyCollection
            .doc(propsid)
            .collection('likes')
            .doc(uid)
            .delete()
            .then((value) {
          setState(() {
            widget.props.numLikes -= 1;
            widget.userlikethispost = false;
          });
          DatabaseServiceItems.propertyCollection
              .doc(propsid)
              .update({'numLikes': widget.props.numLikes});
        });
      }
    });
  }

  List<WishListModel> wishlist = [];
  Future<dynamic> getWishlist(String propsid) {
    DatabaseServiceItems.propertyCollection
        .doc(propsid)
        .collection('wishlist')
        .get()
        .then((value) {
      value.docs.forEach((element) {
        wishlist.add(WishListModel(
          title: element.data()['title'],
          message: element.data()['message'],
          categoryid: element.data()['categoryid'],
        ));
      });
    });
  }

  CategoryFormModel catmodel = new CategoryFormModel();
  Future<dynamic> getCategory(String menuid, bool forRent, bool forSale,
      bool forInstallment, bool forSwap) async {
    String action;

    if (forRent) {
      action = 'rent';
    } else if (forSale) {
      action = 'sale';
    } else if (forInstallment) {
      action = 'installment';
    } else if (forSwap) {
      action = 'swap';
    }
    DatabaseCategory.categoryCollectionGlobal
        .doc(menuid)
        .collection(action)
        .get()
        .then((value) {
      value.docs.forEach((element) {
        setState(() {
          catmodel = CategoryFormModel(
            categoryid: element.data()['categoryid'],
            popsid: element.data()['popsid'],
            title: element.data()['title'],
            condition_brandnew: element.data()['condition_brandnew'],
            condition_likebrandnew: element.data()['condition_likebrandnew'],
            condition_wellused: element.data()['condition_wellused'],
            condition_heavilyused: element.data()['condition_heavilyused'],
            condition_new: element.data()['condition_new'],
            condition_preselling: element.data()['condition_preselling'],
            condition_preowned: element.data()['condition_preowned'],
            condition_foreclosed: element.data()['condition_foreclosed'],
            condition_used: element.data()['condition_used'],
            priceinput_price: element.data()['priceinput_price'],
            description: element.data()['description'],
            ismoreandsameitem: element.data()['ismoreandsameitem'],
            deal_meetup: element.data()['deal_meetup'],
            deal_delivery: element.data()['deal_delivery'],
            brandCODE: element.data()['brandCODE'],
            location_cityproviceCODE:
                element.data()['location_cityproviceCODE'],
            location_streetaddress: element.data()['location_streetaddress'],
            unitdetails_lotarea: element.data()['unitdetails_lotarea'],
            unitdetails_termsCODE: element.data()['unitdetails_termsCODE'],
            unitdetails_bedroom: element.data()['unitdetails_bedroom'],
            unitdetails_bathroom: element.data()['unitdetails_bathroom'],
            unitdetails_floorarea: element.data()['unitdetails_floorarea'],
            unitdetails_parkingspace:
                element.data()['unitdetails_parkingspace'],
            unitdetails_furnish_unfurnish:
                element.data()['unitdetails_furnish_unfurnish'],
            unitdetails_furnish_semifurnish:
                element.data()['unitdetails_furnish_semifurnish'],
            unitdetails_furnish_fullyfurnish:
                element.data()['unitdetails_furnish_fullyfurnish'],
            unitdetails_room_private:
                element.data()['unitdetails_room_private'],
            unitdetails_room_shared: element.data()['unitdetails_room_shared'],
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext bcontext) {
    return Scaffold(
      backgroundColor: whiteColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: _scrollListener,
        child: Container(
          height: double.infinity,
          child: Stack(
            alignment: Alignment.topRight,
            children: <Widget>[
              SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    CarouselComponent(listimage: listimage),
                    Column(
                      children: [
                        SizedBox(height: 20),
                        TextLabelByLine(
                            text: widget.props.title,
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w500),
                            width: 0.9),
                        TextLabelByLine(
                            text: formatCurency(widget.props.price.toString()),
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 25,
                                fontWeight: FontWeight.bold),
                            width: 0.9),
                        SizedBox(height: 10),
                        TextLabelByLine(
                            text: widget.props.location_streetaddress,
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 20,
                                fontWeight: FontWeight.w200),
                            width: 0.9),
                        SizedBox(height: 5),
                        Container(
                          margin:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Row(
                            children: [
                              Align(
                                alignment: Alignment.topLeft,
                                child: Text('posted ',
                                    style: TextStyle(
                                        color: blackColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w200)),
                              ),
                              Text(' 3 days ago by ',
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w200)),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      ScaleRoute(
                                          page: ProfilePublicView(
                                        user: user,
                                      )));
                                },
                                child: TextLabelByLine(
                                    text: user == null ? '' : user.displayName,
                                    style: TextStyle(
                                        color: primaryColor,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700),
                                    width: 0.4),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          child: ItemCardMenu(
                              props: widget.props,
                              onClick: () {
                                if (widget.props.forSwap)
                                  setState(() {
                                    getWishApplication;
                                  });
                              }),
                        ),
                        SizedBox(height: 20),
                        Container(
                          margin:
                              const EdgeInsets.only(left: 20.0, right: 20.0),
                          child: Stack(
                            children: <Widget>[
                              TextLabelByLine(
                                  text: 'Details',
                                  style: TextStyle(
                                      color: blackColor,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                  width: 0.9),
                              Align(
                                alignment: Alignment.topRight,
                                child: Text(widget.props.numLikes.toString() +
                                    ' likes  |  ' +
                                    widget.props.numViews.toString() +
                                    " views"),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ItemViewBodyContent(
                            catmodel: catmodel, props: widget.props),
                        if (widget.props.forSwap)
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    'Wishlist',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryColor,
                                        fontSize: 17),
                                  ),
                                ),
                              ),
                              Container(
                                padding: EdgeInsets.only(left: 10),
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    '(you have ',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Container(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    offercounts.toString(),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: blackColor,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                              Container(
                                child: Align(
                                  alignment: Alignment.topLeft,
                                  child: Text(
                                    ' offer/s)',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: blackColor,
                                        fontSize: 15),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        for (WishListModel wishitem in wishlist)
                          WishItemCardRow(
                            onClickCard: null,
                            wishItem: wishitem,
                            onChangeCheckbox: null,
                          ),
                        SellerInfo(user: user),
                        ItemComment(comments: comment),
                        if (similaritem.isNotEmpty)
                          SuggetItem(similaritem: similaritem),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                height: 80,
                child: AnimatedBuilder(
                  animation: _ColorAnimationController,
                  builder: (context, child) => AppBar(
                    backgroundColor: _colorTween.value,
                    elevation: 0,
                    titleSpacing: 0.0,
                    title: Transform.translate(
                      offset: _transTween.value,
                      child: Center(
                        child: Text(
                          widget.props.forSwap
                              ? "Swappable Item"
                              : formatCurency(widget.props.price.toString()),
                          style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ),
                    ),
                    leading: MaterialButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      color: whiteColor,
                      textColor: primaryColor,
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                      ),
                      padding: EdgeInsets.all(16),
                      shape: CircleBorder(),
                    ),
                    iconTheme: IconThemeData(
                      color: _iconColorTween.value,
                    ),
                    actions: <Widget>[
                      Transform.translate(
                        offset: _transTween.value,
                        child: Center(
                          child: Container(
                            margin: EdgeInsets.all(5),
                            height: 50.0,
                            child: RaisedButton(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18.0),
                                  side: BorderSide(
                                      color: Color.fromRGBO(0, 160, 227, 1))),
                              onPressed: () {
                                setState(() {
                                  showModalBottomSheet<void>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return ModalBox(
                                          isCloseDisplay: false,
                                          body:
                                              MineMenu.modalContainer(context),
                                        );
                                      });
                                });
                              },
                              padding: EdgeInsets.all(10.0),
                              color: Colors.white,
                              textColor: Color.fromRGBO(0, 160, 227, 1),
                              child: Text("Mine Item",
                                  style: TextStyle(fontSize: 15)),
                            ),
                          ),
                        ),
                      ),
                      widget.userlikethispost
                          ? MaterialButton(
                              onPressed: () {
                                clickLikes(
                                    widget.props.propid, widget.user.uid);
                              },
                              color: whiteColor,
                              textColor: primaryColor,
                              child: Icon(
                                Icons.favorite,
                                size: 24,
                              ),
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                            )
                          : MaterialButton(
                              onPressed: () {
                                clickLikes(
                                    widget.props.propid, widget.user.uid);
                              },
                              color: whiteColor,
                              textColor: primaryColor,
                              child: Icon(
                                Icons.favorite_outline,
                                size: 24,
                              ),
                              padding: EdgeInsets.all(16),
                              shape: CircleBorder(),
                            ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
