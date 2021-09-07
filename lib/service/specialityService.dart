import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/pages/authentication/SignInPage.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class SpecialityService {
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
}
