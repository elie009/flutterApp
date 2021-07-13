import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_app/model/item_model.dart';
import 'package:flutter_app/pages/profile/ItemManagement/TopMenuItem.dart';
import 'package:flutter_app/service/auth.dart';
import 'package:flutter_app/service/database.dart';
import 'package:flutter_app/service/itemService.dart';
import 'package:provider/provider.dart';

class TopMenuMgmtPage extends StatefulWidget {
  @override
  _TopMenuMgmtPage createState() => _TopMenuMgmtPage();
}

class _TopMenuMgmtPage extends State<TopMenuMgmtPage> {
  TextEditingController _textFieldController = TextEditingController();
  final _formItem = GlobalKey<FormState>();
  final ItemService _item = ItemService();

  Future<void> _displayTextInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return Form(
            key: _formItem,
            child: Column(
              children: [
                AlertDialog(
                  title: Text('TextField in Dialog'),
                  content: TextFormField(
                    validator: (val) => val.isEmpty ? 'Enter item name' : null,
                    showCursor: true,
                    onChanged: (value) {
                      setState(() {
                        valueText = value;
                      });
                    },
                    controller: _textFieldController,
                    decoration:
                        InputDecoration(hintText: "Text Field in Dialog"),
                  ),
                  actions: <Widget>[
                    FlatButton(
                      color: Colors.red,
                      textColor: Colors.white,
                      child: Text('CANCEL'),
                      onPressed: () {
                        setState(() {
                          Navigator.pop(context);
                        });
                      },
                    ),
                    FlatButton(
                      color: Colors.green,
                      textColor: Colors.white,
                      child: Text('OK'),
                      onPressed: () {
                        setState(() async {
                          dynamic result = await _item.addTopMenu(
                              valueText, 'testtest', 0, 'ic_popular_food_1');

                          codeDialog = valueText;
                          Navigator.pop(context);
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        });
  }

  String codeDialog;
  String valueText;
  int counter = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamProvider<List<ItemModel>>.value(
          value: DatabaseService().items,
          initialData: null,
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Color(0xFFFAFAFA),
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Color(0xFF3a3737),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Center(
                child: Text(
                  "Item Carts",
                  style: TextStyle(
                      color: Color(0xFF3a3737),
                      fontWeight: FontWeight.w600,
                      fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              brightness: Brightness.light,
              actions: <Widget>[
                CartIconWithBadge(),
              ],
            ),
            body: TopMenuItem(),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          color: Colors.red,
          notchMargin: 4,
          child: BottomNavigationBar(
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.hide_source), title: Text('Hide')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.add), title: Text('Add')),
              BottomNavigationBarItem(
                  icon: Icon(Icons.delete), title: Text('Delete')),
            ],
            onTap: (int index) {
              _displayTextInputDialog(context);
            },
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }
}

class CartItem extends StatelessWidget {
  String productName;
  String productPrice;
  String productImage;
  String productCartQuantity;

  CartItem({
    Key key,
    @required this.productName,
    @required this.productPrice,
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
                      "assets/images/popular_foods/$productImage.png",
                      width: 110,
                      height: 100,
                    )),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                "$productName",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF3a3a3b),
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Container(
                              child: Text(
                                "$productPrice",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF3a3a3b),
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          width: 40,
                        ),
                        Container(
                          alignment: Alignment.centerRight,
                          child: Image.asset(
                            "assets/images/menus/ic_delete.png",
                            width: 25,
                            height: 25,
                          ),
                        )
                      ],
                    ),
                    Container(
                      margin: EdgeInsets.only(left: 20),
                      alignment: Alignment.centerRight,
                      child: AddToCartMenu(5),
                    )
                  ],
                )
              ],
            ),
          )),
    );
  }
}

class CartIconWithBadge extends StatelessWidget {
  int counter = 3;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        IconButton(
            icon: Icon(
              Icons.business_center,
              color: Color(0xFF3a3737),
            ),
            onPressed: () {}),
        counter != 0
            ? Positioned(
                right: 11,
                top: 11,
                child: Container(
                  padding: EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: Text(
                    '$counter',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 8,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            : Container()
      ],
    );
  }
}
