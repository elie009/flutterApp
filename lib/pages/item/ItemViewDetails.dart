import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseCommonProps.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/widgets/components/CarouselSlider.dart';
import 'package:flutter_app/widgets/components/text/TextLabelByLine.dart';
import 'package:provider/provider.dart';

import 'component/ItemCardMenu.dart';
import 'component/ItemViewBodyContent.dart';

class ItemViewDetails extends StatefulWidget {
  ItemViewDetails({Key key, @required this.props}) : super(key: key);
  PropertyItemModel props;
  @override
  _ItemViewDetailsState createState() => _ItemViewDetailsState();
}

class _ItemViewDetailsState extends State<ItemViewDetails>
    with TickerProviderStateMixin {
  AnimationController _ColorAnimationController;
  AnimationController _TextAnimationController;
  Animation _colorTween, _iconColorTween;
  Animation<Offset> _transTween;

  @override
  void initState() {
    _ColorAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));
    _colorTween = ColorTween(begin: Colors.transparent, end: whiteColor)
        .animate(_ColorAnimationController);
    _iconColorTween = ColorTween(begin: Colors.grey, end: Colors.white)
        .animate(_ColorAnimationController);

    _TextAnimationController =
        AnimationController(vsync: this, duration: Duration(seconds: 0));

    _transTween = Tween(begin: Offset(-10, 40), end: Offset(-10, 0))
        .animate(_TextAnimationController);

    getData(widget.props.propid);
    getCategory(widget.props.menuid, widget.props.forRent, widget.props.forSale,
        widget.props.forInstallment, widget.props.forSwap);
    ;
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
    DatabaseCommonProps.categoryCollectionGlobal
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
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);
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
                              TextLabelByLine(
                                  text: 'archie',
                                  style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700),
                                  width: 0.4),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        ItemCardMenu(props: widget.props),
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
                                    ' like  |  ' +
                                    widget.props.numViews.toString() +
                                    " views"),
                              )
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                        TextLabelByLine(
                            text: widget.props.description,
                            style: TextStyle(
                                color: blackColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                            width: 0.9),
                        SizedBox(height: 20),
                        ItemViewBodyContent(
                            catmodel: catmodel, props: widget.props),
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
                      child: Text(
                        "TEXT",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
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
                      MaterialButton(
                        onPressed: () {},
                        color: whiteColor,
                        textColor: primaryColor,
                        child: Icon(
                          Icons.favorite_outline,
                          size: 24,
                        ),
                        padding: EdgeInsets.all(16),
                        shape: CircleBorder(),
                      )
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
