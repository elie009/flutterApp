import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/model/ContactModel.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyLotModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/utils/Constant.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

  Future deleteItemData() async {
    return await menuCollection.doc(uid).delete();
  }

// collection reference
  final CollectionReference menuCollection =
      FirebaseFirestore.instance.collection('menu');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');


  final CollectionReference properyLottCollection =
      FirebaseFirestore.instance.collection('propertyLot');

  final CollectionReference bookingCollection =
      FirebaseFirestore.instance.collection('booking');

  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  final CollectionReference mobileCollection =
      FirebaseFirestore.instance.collection('mobiles');

  Future updateBookingData(BookingModel data) async {
    return await bookingCollection.doc(data.bookId).set({
      'fromYear': data.fromYear,
      'fromMonth': data.fromMonth,
      'fromDay': data.fromDay,
      'toYear': data.toYear,
      'toMonth': data.toMonth,
      'toDay': data.toDay,
      'propsId': data.propsId,
      'bookId': data.bookId,
      'userId': data.userId,
      'bookingStatus': data.bookingStatus,
      'bookDate': DateTime.now().toString(),
    });
  }

  Future updateMenuData(MenuModel menuitem) async {
    return await menuCollection.doc(uid).set({
      'menuid': menuitem.menuid,
      'name': menuitem.name,
      'description': menuitem.description,
      'imageAppName': menuitem.imageAppName,
      'imageWebName': menuitem.imageWebName,
      'dropdownid': menuitem.dropdownid,
    });
  }

  Future updateUserData(UserBaseModel usrobj) async {
    return await userCollection.doc(usrobj.uid).set({
      'uid': usrobj.uid,
      'email': usrobj.email,
      'status': 'PENDING',
      'phoneNumber': usrobj.phoneNumber,
      'firstName': usrobj.firstName,
      'lastName': usrobj.lastName,
      'image': usrobj.image,
    });
  }

  //get item list from snapshot
  List<UserBaseModel> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return UserBaseModel(
          doc.get('uid') ?? '',
          doc.get('email') ?? '',
          doc.get('firstName') ?? '',
          doc.get('lastName') ?? '',
          doc.get('phoneNumber') ?? '',
          doc.get('status') ?? '',
          doc.get('image') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  Future addChat(
      String uid, String ownerUid, String popsId, String chatId) async {
    return await chatCollection.doc(chatId).set({
      'chatId': chatId,
      'propId': popsId,
      'contact1': uid,
      'contact2': ownerUid,
    });
  }

  //get item list from snapshot
  List<MenuModel> _menuListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return MenuModel(
          menuid: doc.get('menuid') ?? '',
          name: doc.get('name') ?? '',
          description: doc.get('description') ?? '',
          imageAppName: doc.get('imageAppName') ?? '',
          imageWebName: doc.get('imageWebName') ?? '',
          dropdownid: doc.get('dropdownid') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all menu item on stream
  Stream<List<MenuModel>> get getStreamMenu {
    return menuCollection.snapshots().map(_menuListFromSnapshot);
  }

  //get item list from snapshot
  List<ContactModel> _contactsFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return ContactModel(
          contact1: doc.get('contact1') ?? '',
          contact2: doc.get('contact2') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

//get item list from snapshot
  List<PropertyModel> _propertyListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return PropertyModel.obj(
          doc.get('numComments') ?? 0,
          doc.get('numLikes') ?? 0,
          doc.get('numDisLikes') ?? 0,
          doc.get('propid') ?? '',
          doc.get('title') ?? '',
          doc.get('description') ?? '',
          doc.get('imageName') ?? '',
          doc.get('saleFixPrice') ?? 0,
          doc.get('rentFixPrice') ?? 0,
          doc.get('installmentFixPrice') ?? 0,
          doc.get('location') ?? '',
          doc.get('menuid') ?? '',
          doc.get('ownerUid') ?? '',
          doc.get('status') ?? '',
          doc.get('postdate') ?? '',
          doc.get('forSwap') ?? false,
          doc.get('conditionCode') ?? -1,
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  //get item booking from snapshot
  List<BookingModel> _bookingListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return BookingModel(
          doc.get('fromYear') ?? '',
          doc.get('fromMonth') ?? '',
          doc.get('fromDay') ?? '',
          doc.get('toYear') ?? '',
          doc.get('toMonth') ?? '',
          doc.get('toDay') ?? '',
          doc.get('propsId') ?? '',
          doc.get('bookId') ?? '',
          doc.get('userId') ?? '',
          doc.get('bookingStatus') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  //get item booking from snapshot
  List<ContactModel> _contactListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return ContactModel(
          contact1: doc.get('contact1') ?? '',
          contact2: doc.get('contact2') ?? '',
          date: doc.get('date') ?? '',
          propsId: doc.get('propsId') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  Future<Map<String, dynamic>> getChatData(
      String uid, String propOwnerUid) async {
    Map<String, dynamic> chatData;
    var result = await chatCollection
        .where('contact1', isEqualTo: uid)
        .where('contact2', isEqualTo: propOwnerUid)
        .get();

    result.docs.forEach((e) {
      chatData = e.data();
    });
    return chatData;
  }

  Future<Map<String, dynamic>> getUseContact(
      String uid, String ownerUid) async {
    Map<String, dynamic> chatData;
    var result = await userCollection
        .doc(uid)
        .collection('contacts')
        .where('contactUid', isEqualTo: ownerUid)
        .get();

    result.docs.forEach((e) {
      chatData = e.data();
    });
    return chatData;
  }

  Future<Map<String, dynamic>> getUseData(String uid) async {
    Map<String, dynamic> userData;
    var result = await userCollection.where('uid', isEqualTo: uid).get();

    result.docs.forEach((e) {
      userData = e.data();
    });
    return userData;
  }


// get all booking item on stream
  Stream<List<BookingModel>> booking(String propsid) {
    return bookingCollection
        .where('propsId', isEqualTo: propsid)
        .where('bookingStatus', whereIn: ['BREAK', 'APPROVE'])
        .snapshots()
        .map(_bookingListFromSnapshot);
  }

// get all booking item on stream
  Stream<List<ContactModel>> userContact(String userid) {
    return userCollection
        .doc(userid)
        .collection('contacts')
        .snapshots()
        .map(_contactListFromSnapshot);
  }

  Future deleteAllitem() async {
    try {
      var snapshots = await menuCollection.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
      return true;
    } catch (error) {
      print("Error: Delete all speciality item with error message " +
          error.toString());
      return false;
    }
  }

  
}

abstract class DatabaseServicePropsStructure<T> {
  getAll() {}
  getByPropId(String props) {}
  getByUid(String uid) {}
  getByMenu(String menuid) {}
  getByUserMenu(String uid, String menuid) {}

  add(dynamic propsLot) async {}
  delete(String propsLot) async {}
}
