import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_app/model/item_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

// collection reference
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('item');

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection('user');

  Future updateItemData(
      String name, String description, int strength, String image) async {
    return await itemCollection.doc(uid).set({
      'itemid': uid,
      'description': description,
      'name': name,
      'itemCount': strength,
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

  // item list from snapshot
  List<ItemModel> _itemListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ItemModel(
        id: doc.get('itemid') ?? '',
        name: doc.get('name') ?? '',
        itemCount: doc.get('itemCount') ?? 0,
        description: doc.get('description') ?? '0',
        imageName: doc.get('imageName') ?? '0',
      );
    }).toList();
  }

  // get all item stream
  Stream<List<ItemModel>> get items {
    return itemCollection.snapshots().map(_itemListFromSnapshot);
  }
}
