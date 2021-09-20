import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/SingleItemChecker.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyLotModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/item/add/InputPage.dart';
import 'package:flutter_app/widgets/components/AlertBox.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:flutter_app/utils/Utils.dart';
import 'package:flutter_app/widgets/PopularFoodsWidget.dart';
import 'package:provider/provider.dart';

import '../../../widgets/components/CheckBox.dart';
import '../../../widgets/components/Dropdown.dart';
import '../../../widgets/components/RadioBtn.dart';

class PropertyItemPage extends StatefulWidget {
  PropertyModel props;
  PropertyItemPage({this.props});
  @override
  _PropertyItemPageState createState() => _PropertyItemPageState();
}

class _PropertyItemPageState extends State<PropertyItemPage> {
  String _selectedLocation;
  bool _rental = false, _sale = false, _exchange = false;
  TextEditingController title;
  var propItem = new PropertyLotModel(
      0,
      0,
      0,
      '',
      '',
      '',
      'assets/images/bestfood/ic_best_food_8.jpeg',
      0.00,
      '',
      '',
      '',
      0.00,
      0.00,
      '',
      '',
      '',
      '',
      '',
      '',
      '');
  var inputText = TextEditingController();
  var color = ColorField();

  String billValue;
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserBaseModel>(context);

    return Container(
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
                        Card(
                          semanticContainer: true,
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          child: Image.asset(
                            'assets/images/bestfood/' +
                                'ic_best_food_8' +
                                ".jpeg",
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(3.0),
                          ),
                          elevation: 1,
                          margin: EdgeInsets.all(5),
                        ),
                        Row(
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  color = ColorField();
                                  for (String field
                                      in propItem.checkPropertyLotSubmit(
                                          _rental, _exchange)) {
                                    switch (field) {
                                      case 'MD001PLT001001':
                                        color.lotSize = primaryColor;
                                        break;
                                      case 'MD001PLT001006':
                                        color.restriction = primaryColor;
                                        break;
                                      case 'MD001PLT001008':
                                        color.trade = primaryColor;
                                        break;
                                      case 'MD001PLT001009':
                                        color.title = primaryColor;
                                        break;
                                      case 'MD001PLT001013':
                                        color.fixPrice = primaryColor;
                                        break;
                                    }
                                  }

                                  if (propItem
                                          .checkPropertyLotSubmit(
                                              _rental, _exchange)
                                          .length !=
                                      0) {
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertBox(
                                            title: 'Warning',
                                            message:
                                                'Please input required fields'));
                                  } else {
                                    propItem.status =
                                        _rental || _sale || _exchange
                                            ? 'APPROVE'
                                            : 'PRIVATE';
                                    propItem.menuid = _selectedLocation;
                                    propItem.propid = idPropertyLot;
                                    propItem.ownerUid = user.uid;

                                    SingleItemChecker()
                                        .addPropertyLot(propItem);
                                  }
                                });
                              },
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.height * 0.232,
                                height: 45.0,
                                decoration: new BoxDecoration(
                                  color: primaryColor,
                                  border: Border.all(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Submit',
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  color = ColorField();
                                  for (String field
                                      in propItem.checkPropertySave()) {
                                    switch (field) {
                                      case 'MD001PLT001009':
                                        color.title = primaryColor;
                                        break;
                                    }
                                  }

                                  if (propItem.checkPropertySave().length !=
                                      0) {
                                    showDialog<String>(
                                        context: context,
                                        builder: (BuildContext context) => AlertBox(
                                            title: 'Warning',
                                            message:
                                                'Please input required fields'));
                                  } else {
                                    propItem.status = 'SAVE';
                                    propItem.propid = idPropertyLot;
                                    propItem.menuid = _selectedLocation;
                                    propItem.ownerUid = user.uid;

                                    SingleItemChecker()
                                        .addPropertyLot(propItem);
                                  }
                                });
                              },
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.height * 0.232,
                                height: 45.0,
                                decoration: new BoxDecoration(
                                  color: primaryColor,
                                  border: Border.all(
                                      color: Colors.white, width: 2.0),
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                child: Center(
                                  child: Text(
                                    'Save',
                                    style: new TextStyle(
                                        fontSize: 18.0,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        dropdownMenu(),
                        (_selectedLocation != null
                            ? Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        left: 10, top: 5, right: 10, bottom: 5),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                            child: Text(
                                          'Details',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold),
                                        )),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      rentalFormDisplay(
                                        'Title',
                                        propItem.title,
                                        'F004',
                                        (String newValue) {
                                          setState(() {
                                            propItem.title = newValue;
                                            inputText.clear();
                                          });
                                        },
                                        color.title,
                                      ),
                                      rentalFormDisplay(
                                        'Price Per sqm',
                                        propItem.perSqm.toString(),
                                        'F005',
                                        (String newValue) {
                                          setState(() {
                                            propItem.perSqm =
                                                double.parse(newValue);
                                            inputText.clear();
                                          });
                                        },
                                        color.perSqm,
                                      ),
                                      rentalFormDisplay(
                                        'Total price',
                                        propItem.fixPrice.toString(),
                                        'F005',
                                        (String newValue) {
                                          setState(() {
                                            propItem.fixPrice =
                                                double.parse(newValue);
                                            inputText.clear();
                                          });
                                        },
                                        color.fixPrice,
                                      ),
                                      rentalFormDisplay(
                                        'Location',
                                        propItem.location,
                                        'F004',
                                        (String newValue) {
                                          setState(() {
                                            propItem.fixPrice =
                                                double.parse(newValue);
                                            inputText.clear();
                                          });
                                        },
                                        color.location,
                                      ),
                                      rentalFormDisplay(
                                        'Lot size',
                                        propItem.lotSize.toString(),
                                        'F005',
                                        (String newValue) {
                                          setState(() {
                                            propItem.lotSize =
                                                double.parse(newValue);
                                            inputText.clear();
                                          });
                                        },
                                        color.lotSize,
                                      ),
                                    ],
                                  ),
                                  LabeledCheckbox(
                                    label: 'Rentals',
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    value: _rental,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        _rental = newValue;
                                      });
                                    },
                                  ),
                                  (_rental
                                      ? Column(
                                          children: [
                                            rentalFormDisplay(
                                              'Restrictions',
                                              propItem.rentRestrictions,
                                              'F002',
                                              (String newValue) {
                                                setState(() {
                                                  propItem.rentRestrictions =
                                                      newValue;
                                                });
                                              },
                                              color.restriction,
                                            ),
                                            Container(
                                                decoration: BoxDecoration(
                                                  border: Border(
                                                    bottom: BorderSide(
                                                        width: 1.0,
                                                        color: grayColor),
                                                  ),
                                                ),
                                                child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 15,
                                                        top: 5,
                                                        right: 15,
                                                        bottom: 5),
                                                    child: Column(children: [
                                                      Row(children: <Widget>[
                                                        Expanded(
                                                            child: Text(
                                                          'Billable Type',
                                                          style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        )),
                                                        DropdownButton<String>(
                                                          hint: Text(
                                                            "Select Item Type",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .grey),
                                                          ),
                                                          items: <PairObj>[
                                                            PairObj(
                                                                key: 'A01001',
                                                                value:
                                                                    'Hourly'),
                                                            PairObj(
                                                                key: 'A01002',
                                                                value: 'Daily'),
                                                            PairObj(
                                                                key: 'A01003',
                                                                value:
                                                                    'Weekly'),
                                                            PairObj(
                                                                key: 'A01004',
                                                                value:
                                                                    'Monthly'),
                                                            PairObj(
                                                                key: 'A01005',
                                                                value:
                                                                    'Yearly'),
                                                            PairObj(
                                                                key: 'A01006',
                                                                value: 'Other'),
                                                          ].map(
                                                              (PairObj value) {
                                                            return DropdownMenuItem<
                                                                String>(
                                                              value: value.key,
                                                              child: Text(
                                                                  value.value),
                                                            );
                                                          }).toList(),
                                                          value: billValue,
                                                          onChanged:
                                                              (String dpvalue) {
                                                            setState(() {
                                                              billValue =
                                                                  dpvalue;
                                                            });
                                                          },
                                                        )
                                                      ])
                                                    ]))),
                                          ],
                                        )
                                      : Container()),
                                  LabeledCheckbox(
                                    label: 'Sale',
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    value: _sale,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        _sale = newValue;
                                      });
                                    },
                                  ),
                                  (_sale
                                      ? Column(
                                          children: [
                                            rentalFormDisplay(
                                              'Hold documents',
                                              propItem.saleContainPaper,
                                              'F002',
                                              (String newValue) {
                                                setState(() {
                                                  propItem.saleContainPaper =
                                                      newValue;
                                                });
                                              },
                                              color.docs,
                                            ),
                                          ],
                                        )
                                      : Container()),
                                  LabeledCheckbox(
                                    label: 'Exchange',
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    value: _exchange,
                                    onChanged: (bool newValue) {
                                      setState(() {
                                        _exchange = newValue;
                                      });
                                    },
                                  ),
                                  (_exchange
                                      ? Column(
                                          children: [
                                            rentalFormDisplay(
                                              'Tradable items',
                                              propItem.tradableItems,
                                              'F002',
                                              (String newValue) {
                                                setState(() {
                                                  propItem.tradableItems =
                                                      newValue;
                                                });
                                              },
                                              color.trade,
                                            ),
                                          ],
                                        )
                                      : Container()),
                                ],
                              )
                            : Container()),
                      ])))),
    );
  }

  dropdownMenu() {
    return Padding(
        padding: EdgeInsets.only(left: 0, top: 10, right: 0, bottom: 10),
        child: DropDownComponent(
            label: 'Property Type',
            value: _selectedLocation,
            onChanged: (String newValue) {
              setState(() {
                _selectedLocation = newValue;
              });
            },
            snapshot: DatabaseService().menuCollection));
  }

  /*
  *
  Dropdown    F001
  List input  F002
  String      F004
  Doubles     F005

  *
  */

  rentalFormDisplay(String label, String value, String fieldTypeCode,
      final Function onChanged, Color colorField) {
    return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(width: 1.0, color: grayColor),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 15, top: 5, right: 15, bottom: 5),
          child: Column(children: [
            Row(
              children: <Widget>[
                Expanded(
                    child: Text(
                  label,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                )),
                Expanded(
                    child: Text(
                  value.isNotEmpty && value != '0.0' ? value : 'Set',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colorField),
                )),
                SizedBox(
                  width: 10,
                ),
                IconButton(
                  onPressed: () {
                    //inputText.text = value.isEmpty ? value : inputText.text;
                    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
                      inputText.text = value.isNotEmpty
                          ? value != '0.0'
                              ? value
                              : inputText.text
                          : inputText.text;
                      showDialog<String>(
                        context: context,
                        builder: (BuildContext context) => AlertDialog(
                          title: Container(
                              child: Center(
                            child: Text(label),
                          )),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(20.0))),
                          content: Container(
                              width: 300.0,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    height: 5.0,
                                  ),
                                  Divider(
                                    color: grayColor,
                                    height: 4.0,
                                  ),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 0.0, right: 0.0),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        (fieldTypeCode == 'F004' ||
                                                fieldTypeCode == 'F005'
                                            ? TextField(
                                                keyboardType:
                                                    fieldTypeCode == 'F005'
                                                        ? TextInputType.number
                                                        : TextInputType.text,
                                                controller: inputText,
                                                decoration: InputDecoration(
                                                    border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  5.0)),
                                                      borderSide: BorderSide(
                                                        width: 0,
                                                        color: primaryColor,
                                                        style: BorderStyle.none,
                                                      ),
                                                    ),
                                                    filled: true,
                                                    fillColor: whiteColor,
                                                    hintStyle: new TextStyle(
                                                        color: grayColor,
                                                        fontSize: 18),
                                                    hintText: "Enter here"),
                                              )
                                            : Container()),
                                        (fieldTypeCode == 'F002'
                                            ? Card(
                                                child: TextField(
                                                  maxLines: 8,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  controller: inputText,
                                                  decoration:
                                                      InputDecoration.collapsed(
                                                          border:
                                                              OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(
                                                                        10.0)),
                                                            borderSide:
                                                                BorderSide(
                                                              width: 0,
                                                              color:
                                                                  primaryColor,
                                                              style: BorderStyle
                                                                  .none,
                                                            ),
                                                          ),
                                                          filled: true,
                                                          fillColor: whiteColor,
                                                          hintStyle:
                                                              new TextStyle(
                                                                  color:
                                                                      grayColor,
                                                                  fontSize: 18),
                                                          hintText:
                                                              "Enter here"),
                                                ),
                                              )
                                            : Container()),
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                inputText.clear();
                                Navigator.pop(context, 'Cancel');
                              },
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                onChanged(inputText.text);
                                inputText.clear();
                                Navigator.pop(context, 'OK');
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        ),
                      );
                    });
                  },
                  icon: Icon(
                    Icons.edit,
                    color: primaryColor,
                    size: 25,
                  ),
                )
              ],
            )
          ]),
        ));
  }
}

class PairObj {
  String key;
  String value;
  PairObj({this.key, this.value});
}

class ColorField {
  var title = blackColor,
      perSqm = blackColor,
      fixPrice = blackColor,
      location = blackColor,
      lotSize = blackColor,
      restriction = blackColor,
      billType = blackColor,
      docs = blackColor,
      trade = blackColor;

  ColorField() {
    title = blackColor;
    perSqm = blackColor;
    fixPrice = blackColor;
    location = blackColor;
    lotSize = blackColor;
    restriction = blackColor;
    billType = blackColor;
    docs = blackColor;
    trade = blackColor;
  }
}
