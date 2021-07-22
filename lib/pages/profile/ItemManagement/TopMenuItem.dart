import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/item_model.dart';
import 'package:flutter_app/service/itemService.dart';
import 'package:flutter_app/widgets/BestFoodWidget.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:flutter_app/widgets/SearchWidget.dart';
import 'package:flutter_app/widgets/TopMenu/TopMenus.dart';
import 'package:provider/provider.dart';

class TopMenuItem extends StatefulWidget {
  String productName;
  String productPrice;
  String productImage;
  String productCartQuantity;

  TopMenuItem(this.productName, this.productPrice, this.productImage,
      this.productCartQuantity);

  @override
  State<StatefulWidget> createState() => _TopMenuItem(
      productName: this.productName,
      productPrice: this.productPrice,
      productImage: this.productImage,
      productCartQuantity: this.productCartQuantity);
}

class _TopMenuItem extends State<TopMenuItem> {
  String productName;
  String productPrice;
  String productImage;
  String productCartQuantity;

  _TopMenuItem({
    @required this.productName,
    @required this.productPrice,
    @required this.productImage,
    @required this.productCartQuantity,
  });

  @override
  Widget build(BuildContext context) {
    var items = Provider.of<List<ItemModel>>(context);
    items = items == null ? [] : items;
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(
              height: 10,
            ),
            for (var i in items)
              CartItem(
                  productUid: i.id,
                  productName: i.name,
                  productDesc: i.description,
                  productImage: i.imageName,
                  productCartQuantity: "2"),
          ],
        ),
      ),
    );
  }
}

Widget FlextText1(String title, String description) {
  return Flexible(
    child: new Container(
      padding: new EdgeInsets.only(right: 20.0, top: 20.0),
      child: Column(
        children: <Widget>[
          new Text(
            title, //'Text larget test sample for sample output only',
            overflow: TextOverflow.ellipsis,
            style: new TextStyle(
              fontSize: 18.0,
              color: new Color(0xFF212121),
              fontWeight: FontWeight.bold,
            ),
          ),
          new Text(
            description, //'This only for sample display purpose no other than that',
            overflow: TextOverflow.fade,
            style: new TextStyle(
              fontSize: 13.0,
              color: new Color(0xFF212121),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cryptoChange() {
  return Align(
    alignment: Alignment.topRight,
    child: RichText(
      text: TextSpan(
        text: "+3.67%",
        style: TextStyle(
            fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20),
        children: <TextSpan>[
          TextSpan(
              text: "\n+202.835",
              style: TextStyle(
                  color: Colors.green,
                  fontSize: 15,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

Widget cryptoAmount() {
  return Align(
    alignment: Alignment.centerLeft,
    child: Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Row(
        children: <Widget>[
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(
              text: "\n\$12.279",
              style: TextStyle(
                color: Colors.grey,
                fontSize: 35,
              ),
              children: <TextSpan>[
                TextSpan(
                    text: "\n0.1349",
                    style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

Widget cancelButton = FlatButton(
    onPressed: () {
      return false;
    },
    child: Text("Cancel"));
Widget okButton = FlatButton(
    onPressed: () {
      return true;
    },
    child: Text("OK"));
AlertDialog alert = AlertDialog(
  title: Text("AlertDialog"),
  content: Text("Would you like to delete this item?"),
  actions: [
    cancelButton,
    okButton,
  ],
);

class CartItem extends StatelessWidget {
  String productUid;
  String productName;
  String productDesc;
  String productImage;
  String productCartQuantity;
  final ItemService _item = ItemService();

  CartItem({
    Key key,
    @required this.productUid,
    @required this.productName,
    @required this.productDesc,
    @required this.productImage,
    @required this.productCartQuantity,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 130,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Color(0xFFfae3e2).withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 1,
          offset: Offset(0, 1),
        ),
      ]),
      child: Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(
              Radius.circular(5.0),
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: EdgeInsets.only(left: 5, right: 5, top: 10, bottom: 10),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                Container(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Center(
                        child: Image.asset(
                      "assets/images/popular_foods/ic_popular_food_1.png",
                      width: 110,
                      height: 100,
                    )),
                  ),
                ),
                FlextText1(this.productName, this.productDesc),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            InkWell(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Not in stock'),
                                      content: const Text(
                                          'This item is no longer available'),
                                      actions: [
                                        FlatButton(
                                          child: Text('Cancel'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        FlatButton(
                                          child: Text('Ok'),
                                          onPressed: () {
                                            print(productUid);
                                            _item.deleteTopMenu(productUid);
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: new Container(
                                alignment: Alignment.topRight,
                                padding: EdgeInsets.only(top: 25.0),
                                child: Image.asset(
                                  "assets/images/menus/ic_delete.png",
                                  width: 25,
                                  height: 25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class AddToCartMenu extends StatelessWidget {
  int productCounter;

  AddToCartMenu(this.productCounter);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.remove),
            color: Colors.black,
            iconSize: 18,
          ),
          InkWell(
            onTap: () => print('hello'),
            child: Container(
              width: 100.0,
              height: 35.0,
              decoration: BoxDecoration(
                color: Color(0xFFfd2c2c),
                border: Border.all(color: Colors.white, width: 2.0),
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Center(
                child: Text(
                  'Add To $productCounter',
                  style: new TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w300),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.add),
            color: Color(0xFFfd2c2c),
            iconSize: 18,
          ),
        ],
      ),
    );
  }
}
