import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/model/PropertyLotModel.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class SingleItemChecker {
  Future addTopMenu(MenuModel menuitem) async {
    await DatabaseService(uid: idMenu).updateMenuData(menuitem);
  }

  Future deleteTopMenu(String itemID) async {
    await DatabaseService(uid: itemID).deleteItemData();
  }

  Future deleteAllItem(String itemID) async {
    await DatabaseService(uid: itemID).deleteAllitem();
  }

  Future addBooking(BookingModel item) async {
    await DatabaseService(uid: idBooking).updateBookingData(item);
  }

  Future updateBooking(BookingModel item) async {
    await DatabaseService(uid: item.bookId).updateBookingData(item);
  }

  Future addPropertyLot(PropertyLotModel item) async {
    await DatabaseService().updatePropertyLot(item);
  }
}
