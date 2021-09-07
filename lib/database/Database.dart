import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/object/ProperyObj.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

// collection reference
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('item');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  final CollectionReference propertCollection =
      FirebaseFirestore.instance.collection('property');

  get fromPrice => null;

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

  Future deleteItemData() async {
    return await itemCollection.doc(uid).delete();
  }

  Future updateUserData(User user, String firstname, String lastname) async {
    return await userCollection.doc(uid).set({
      'uid': user.uid,
      'email': user.email,
      'status': 'PENDING',
      'phoneNumber': user.phoneNumber,
      'firstName': firstname,
      'lastName': lastname,
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
          location: doc.get('location') ?? '0',
          menuid: doc.get('menuid') ?? '0',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all property item on stream
  Stream<List<PropertyModel>> get propery {
    return propertCollection.snapshots().map(_propertyListFromSnapshot);
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
