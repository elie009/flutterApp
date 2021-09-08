import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/object/BookingObj.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class SingleItemChecker {
  Future addTopMenu(
      String itemname, String itemdesc, int itemvariety, String image) async {
    await DatabaseService(uid: itemID())
        .updateItemData(itemname, itemdesc, itemvariety, image);
  }

  Future deleteTopMenu(String itemID) async {
    await DatabaseService(uid: itemID).deleteItemData();
  }

  Future deleteAllItem(String itemID) async {
    await DatabaseService(uid: itemID).deleteAllitem();
  }

  Future addBooking(Booking item) async {
    await DatabaseService(uid: bookingID()).updateBookingData(item);
  }

  Future updateBooking(Booking item) async {
    await DatabaseService(uid: item.bookId).updateBookingData(item);
  }
}
