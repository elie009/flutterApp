import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/user_model.dart';
import 'package:flutter_app/pages/SignInPage.dart';
import 'package:flutter_app/service/database.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class ItemService {
  Future addTopMenu(
      String itemname, String itemdesc, int itemvariety, String image) async {
    await DatabaseService(uid: itemID())
        .updateItemData(itemname, itemdesc, itemvariety, image);
  }

  Future deleteTopMenu(String itemID) async {
    await DatabaseService(uid: itemID).deleteItemData();
  }
}
