import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/WishListModel.dart';
import 'package:flutter_app/pages/item/src/items/common/DropdownCategory.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextArea.dart';
import 'package:flutter_app/pages/item/src/items/common/InputTextForm.dart';

class WishItemModal extends StatefulWidget {
  final TextEditingController dropdownWishlistitem;
  final TextEditingController title;
  final TextEditingController message;
  final String itemid;
  final Function onClickOk;
  WishItemModal(
      {this.itemid,
      this.dropdownWishlistitem,
      this.title,
      this.message,
      this.onClickOk});

  @override
  WishItemModalState createState() => new WishItemModalState();
}

class WishItemModalState extends State<WishItemModal> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Add your whist item here"),
        ),
        body: new Padding(
          child: new ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(10),
                child: DropdownCategory(
                  onChanged: (value) {
                    print(value);
                    widget.dropdownWishlistitem.text = value;
                  },
                  value: widget.dropdownWishlistitem.text,
                  paceholder: "Select Category",
                  width: double.infinity,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: InputTextForm(
                  isReadOnly: false,
                  placeholder: "Wish item",
                  isText: true,
                  width: double.infinity,
                  value: widget.title,
                ),
              ),
              Container(
                padding: EdgeInsets.all(10),
                child: InputTextArea(
                  placeholder: "Special message",
                  width: double.infinity,
                  value: widget.message,
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: ElevatedButton(
                        child: const Text('OK'),
                        onPressed: () {
                          widget.onClickOk(WishListModel(
                            title: widget.title.text,
                            message: widget.message.text,
                            categoryid: widget.dropdownWishlistitem.text,
                            isSelect: false,
                            wishid: widget.itemid,
                          ));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: ElevatedButton(
                        child: const Text('Close'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ));
  }
}
