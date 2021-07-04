import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/model/item_model.dart';

class DatabaseService {
  final String uid;
  DatabaseService({this.uid});

// collection reference
  final CollectionReference itemCollection =
      FirebaseFirestore.instance.collection('item');

  Future updateUserData(String sugars, String name, int strength) async {
    return await itemCollection.doc(uid).set({
      'sugars': sugars,
      'name': name,
      'strength': strength,
    });
  }

  // item list from snapshot
  List<ItemModel> _itemListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      return ItemModel(
        name: doc.get('name') ?? '',
        strength: doc.get('strength') ?? 0,
        sugars: doc.get('sugars') ?? '0',
      );
    }).toList();
  }

  // get item stream
  Stream<List<ItemModel>> get items {
    return itemCollection.snapshots().map(_itemListFromSnapshot);
  }
}
