import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/utils/Utils.dart';

class DropDownComponent extends StatelessWidget {
  const DropDownComponent({
    Key key,
    @required this.label,
    @required this.value,
    @required this.onChanged,
    @required this.snapshot,
  }) : super(key: key);

  final String label;
  final String value;
  final Function onChanged;
  final CollectionReference snapshot;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: snapshot.snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CupertinoActivityIndicator(),
            );

          return Container(
            padding: EdgeInsets.only(bottom: 16.0),
            child: Row(
              children: <Widget>[
                Expanded(
                    flex: 2,
                    child: Container(
                      padding: EdgeInsets.only(
                          left: 0, top: 10, right: 0, bottom: 10),
                      child: Text(
                        label,
                        style: TextStyle(
                            fontSize: 16,
                            color: primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    )),
                new Expanded(
                  flex: 4,
                  child: DropdownButton(
                    value: value,
                    isDense: true,
                    onChanged: (valueSelectedByUser) {
                      onChanged(valueSelectedByUser);

                      //_onShopDropItemSelected(valueSelectedByUser);
                    },
                    hint: Text('Choose shop'),
                    items: snapshot.data.docs.map((DocumentSnapshot document) {
                      return DropdownMenuItem<String>(
                        value: document.get('dropdownid'),
                        child: Text(document.get('name') +
                            ' ' +
                            document.get('description')),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
