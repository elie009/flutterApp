import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/utils/Constant.dart';

class DatabaseServiceProps implements DatabaseServicePropsStructure {
  final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');

  //get item list from snapshot
  List<PropertyModel> _PropertyList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return PropertyModel(
          numComments: doc.get('numComments') ?? 0,
          numLikes: doc.get('numLikes') ?? 0,
          numViews: doc.get('numViews') ?? 0,
          propid: doc.get('propid') ?? '',
          title: doc.get('title') ?? '',
          description: doc.get('description') ?? '',
          imageName: doc.get('imageName') ?? '',
          saleFixPrice: doc.get('saleFixPrice') ?? 0,
          rentFixPrice: doc.get('rentFixPrice') ?? 0,
          installmentFixPrice: doc.get('installmentFixPrice') ?? 0,
          location: doc.get('location') ?? '',
          menuid: doc.get('menuid') ?? '',
          ownerUid: doc.get('ownerUid') ?? '',
          status: doc.get('status') ?? '',
          postdate: doc.get('postdate') ?? '',
          conditionCode: doc.get('conditionCode') ?? -1,
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all property item on stream
  Stream<List<PropertyModel>> getPropery(String ownerId) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .snapshots()
        .map(_PropertyList);
  }

  // get all property item on stream
  Stream<List<PropertyModel>> getAllPropery(String ownerId, String menuid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List<PropertyModel>> getAll() {
    return propertyCollection.snapshots().map(_PropertyList);
  }

  @override
  Stream<List<PropertyModel>> getByUid(String uid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List<PropertyModel>> getByMenu(String menuid) {
    return propertyCollection
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  add(dynamic rawdata) async {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Future delete(String propid) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  Stream<List<PropertyModel>> getByPropId(String propid) {
    return propertyCollection
        .where('propid', isEqualTo: propid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List> getByUserMenu(String uid, String menuid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: uid)
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }
}
