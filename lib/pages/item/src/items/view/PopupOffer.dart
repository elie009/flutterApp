import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/widgets/card/RowSmallCard.dart';

class PopupOffer extends StatefulWidget {
  final String uid;
  final String propsid;
  final Function onClick;
  PopupOffer({this.uid, this.propsid, this.onClick});
  @override
  PopupOfferState createState() => new PopupOfferState();
}

class PopupOfferState extends State<PopupOffer> {
  @override
  void initState() {
    getWishApplication.whenComplete(() {
      getData;
    });
    super.initState();
  }

  List<PopWishObj> listimage = [];
  List<String> listWishApplication = [];

  bool checkBoxiconDisp = true;

  get hasCheckInList {
    if (listimage.isEmpty || listimage == null) checkBoxiconDisp = false;
    for (var val in listimage) {
      if (val.checkval == true) {
        checkBoxiconDisp = false;
        return;
      }
    }

    checkBoxiconDisp = true;
    return;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Select item to swap"),
        actions: <Widget>[
          if (!checkBoxiconDisp)
            IconButton(
              icon: Icon(
                Icons.check_box_outline_blank,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  listimage.forEach((f) => f.checkval = false);
                  hasCheckInList;
                });
              },
            ),
          if (checkBoxiconDisp)
            IconButton(
              icon: Icon(
                Icons.check_box,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  listimage.forEach((f) => f.checkval = true);
                  hasCheckInList;
                });
              },
            ),
          IconButton(
            icon: Icon(
              Icons.control_point,
              color: Colors.white,
            ),
            onPressed: () {
              addData.then((value) {
                widget.onClick();
                Navigator.pop(context, 'OK');
              });
            },
          ),
        ],
      ),
      body: new Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                for (PopWishObj i in listimage)
                  RowSmallCard(
                    onCheckChange: (val) {
                      setState(() {
                        hasCheckInList;
                        i.checkval = val;
                      });
                    },
                    checkVal: i.checkval,
                    productName: i.props.title,
                    imageId: i.props.imageId,
                    description: i.props.description,
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<dynamic> get addData async {
    List<String> propsid = [];
    listimage.forEach((element) {
      if (element.checkval == true) {
        propsid.add(element.props.propid);
      }
    });

    return DatabaseServiceItems.propertyCollection
        .doc(widget.propsid)
        .collection('wishapplication')
        .doc(widget.uid)
        .set({
      "propsid": propsid,
      "ownerUid": widget.uid,
      "datepost": getDateNow,
      "status": 'APPROVE',
      "restriction": "public"
    });
  }

  Future<dynamic> get getWishApplication async {
    return DatabaseServiceItems.propertyCollection
        .doc(widget.propsid)
        .collection('wishapplication')
        .doc(widget.uid)
        .snapshots()
        .listen((event2) {
      var x = event2.data()['propsid'];
      if (x == null) return;
      if (x.isEmpty) return;

      x.forEach((element) {
        listWishApplication.add(element);
      });
    });
  }

  Future<dynamic> get getData async {
    DatabaseServiceItems.propertyCollection
        .where("forSwap", isEqualTo: true)
        .where("ownerUid", isEqualTo: widget.uid)
        .snapshots()
        .listen((event1) {
      event1.docs.forEach((element) {
        PropertyItemModel item = PropertyItemModel.snapshot(element);
        setState(() {
          listimage.add(PopWishObj(
              props: item,
              checkval: listWishApplication.indexOf(item.propid) != -1));
        });
      });
    });
  }
}

class PopWishObj {
  PropertyItemModel props;
  bool checkval;
  PopWishObj({this.props, this.checkval});
}
