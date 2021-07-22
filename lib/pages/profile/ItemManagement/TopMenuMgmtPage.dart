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
            ),
            body: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 5),
                      child: Text(
                        "Your Food Cart",
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(0xFF3a3a3b),
                            fontWeight: FontWeight.w600),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TopMenuItem(
                        "Grilled Salmon", "\$96.00", "ic_popular_food_1", "2"),
                    SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ),
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
}
