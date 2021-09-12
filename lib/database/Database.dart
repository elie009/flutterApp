import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_picker/contact_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/model/ContactModel.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/model/UserModel.dart';
import 'package:flutter_app/object/BookingObj.dart';
import 'package:flutter_app/object/ProperyObj.dart';
import 'package:flutter_app/object/UserObt.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});
  get fromPrice => null;

  Future deleteItemData() async {
    return await itemCollection.doc(uid).delete();
  }

// collection reference
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('item');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  final CollectionReference propertCollection =
      FirebaseFirestore.instance.collection('property');

  final CollectionReference bookingCollection =
      FirebaseFirestore.instance.collection('booking');

  final CollectionReference chatCollection =
      FirebaseFirestore.instance.collection('chats');

  final CollectionReference mobileCollection =
      FirebaseFirestore.instance.collection('mobiles');

  Future updateProperyData(Property data) async {
    return await propertCollection.doc(data.propid).set({
      'propid': data.propid,
      'title': data.title,
      'description': data.description,
      'imageName': data.imageName,
      'fromPrice': data.fromPrice,
      'toPrice': data.toPrice,
      'fixPrice': data.fixPrice,
      'location': data.location,
      'menuid': data.menuid,
      'ownerUid': data.ownerUid,
    });
  }

  Future updateBookingData(Booking data) async {
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

  Future updateItemData(
      String name, String description, int price, String image) async {
    return await itemCollection.doc(uid).set({
      'itemid': uid,
      'description': description,
      'name': name,
      'itemCount': price,
      'imageName': image,
    });
  }

  Future updateUserData(UserObj usrobj) async {
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
  List<UserModel> _userListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return UserModel(
          uid: doc.get('uid') ?? '',
          email: doc.get('email') ?? '',
          firstName: doc.get('firstName') ?? '',
          lastName: doc.get('lastName') ?? '',
          phoneNumber: doc.get('phoneNumber') ?? '',
          status: doc.get('status') ?? '',
          image: doc.get('image') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  Future addChat(String uid, String ownerUid, String popsId) async {
    // chatCollection
    //     .add({'contact1': uid, 'contact2': ownerUid, 'propId': popsId});
    String chatId = chatID;
    return await chatCollection.doc(chatId).set({
      'chatId': chatId,
      'propId': popsId,
      'contact1': uid,
      'contact2': ownerUid,
    });
  }

  //get item list from snapshot
  List<SpecialitiesModel> _itemListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return SpecialitiesModel(
          typeId: doc.get('itemid') ?? '',
          imageAppName: doc.get('imageName') ?? '0',
          imageWebName: doc.get('imageName') ?? '0',
          id: doc.get('itemid') ?? '',
          name: doc.get('name') ?? '',
          itemCount: doc.get('itemCount') ?? 0,
          description: doc.get('description') ?? '0',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all menu item on stream
  Stream<List<SpecialitiesModel>> get items {
    return itemCollection.snapshots().map(_itemListFromSnapshot);
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
        return PropertyModel(
          propid: doc.get('propid') ?? '',
          title: doc.get('title') ?? '',
          description: doc.get('description') ?? '',
          imageName: doc.get('imageName') ?? '',
          fromPrice: doc.get('fromPrice') ?? 0,
          toPrice: doc.get('toPrice') ?? 0,
          fixPrice: doc.get('fixPrice') ?? 0,
          location: doc.get('location') ?? '',
          menuid: doc.get('menuid') ?? '',
          ownerUid: doc.get('ownerUid') ?? '',
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
          fromYear: doc.get('fromYear') ?? '',
          fromMonth: doc.get('fromMonth') ?? '',
          fromDay: doc.get('fromDay') ?? '',
          toYear: doc.get('toYear') ?? '',
          toMonth: doc.get('toMonth') ?? '',
          toDay: doc.get('toDay') ?? '',
          propsId: doc.get('propsId') ?? '',
          bookId: doc.get('bookId') ?? '',
          userId: doc.get('userId') ?? '',
          bookingStatus: doc.get('bookingStatus') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

// get all property item on stream
  Stream<List<ContactModel>> chat(String uid, String propOwnerUid) {
    return chatCollection
        .where('contact1', isEqualTo: uid)
        .where('contact2', isEqualTo: propOwnerUid)
        .snapshots()
        .map(_contactsFromSnapshot);
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
        .where('uid', isEqualTo: ownerUid)
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

  // get all property item on stream
  Stream<List<PropertyModel>> propery(String menuId) {
    return propertCollection
        .where('menuid', isEqualTo: menuId)
        .snapshots()
        .map(_propertyListFromSnapshot);

    //return propertCollection.snapshots().map(_propertyListFromSnapshot);
  }

// get all booking item on stream
  Stream<List<BookingModel>> booking(String propsid) {
    return bookingCollection
        .where('propsId', isEqualTo: propsid)
        .where('bookingStatus', whereIn: ['BREAK', 'APPROVE'])
        .snapshots()
        .map(_bookingListFromSnapshot);
    //return bookingCollection.snapshots().map(_bookingListFromSnapshot);
  }

  Future m(String uid, String propOwnerUid) async {
    await chatCollection
        .where('contact1', isEqualTo: uid)
        .where('contact2', isEqualTo: propOwnerUid)
        .get();
  }

  Future deleteAllitem() async {
    try {
      var snapshots = await itemCollection.get();
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
