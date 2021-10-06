import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class SingleItemChecker {
  Future addTopMenu(CategoryModel menuitem) async {
    await DatabaseService(uid: idMenu).updateCategoryData(menuitem);
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

 
}
