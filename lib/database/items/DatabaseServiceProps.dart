import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';

class DatabaseServiceProps implements DatabaseServicePropsStructure {
  final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');

  //get item list from snapshot
  List<PropertyItemModel> _PropertyList(QuerySnapshot snapshot) {
    print('ppppp');
    print(snapshot == null);

    return snapshot.docs.map((doc) {
      print('mmmmmmm');
      print(doc.exists);
      try {
        return PropertyItemModel(
          title: doc.get('title') ?? '',
          conditionCode: doc.get('conditionCode') ?? '',
          priceselectionCode: doc.get('priceselectionCode') ?? '',
          price: doc.get('price') ?? 0.0,
          description: doc.get('description') ?? '',
          ismoreandsameitem: doc.get('ismoreandsameitem') ?? false,
          dealmethodCode: doc.get('dealmethodCode') ?? '',
          location_cityprovinceCode: doc.get('location_cityprovinceCode') ?? '',
          location_streetaddress: doc.get('location_streetaddress') ?? '',
          branchCode: doc.get('branchCode') ?? '',
          featureCode: doc.get('featureCode') ?? '',
          lotarea: doc.get('lotarea') ?? 0.0,
          bedroms: doc.get('bedroms') ?? 0,
          bathrooms: doc.get('bathrooms') ?? 0,
          floorarea: doc.get('floorarea') ?? 0.0,
          carspace: doc.get('carspace') ?? 0,
          furnishingCode: doc.get('furnishingCode') ?? '',
          roomCode: doc.get('roomCode') ?? '',
          numComments: doc.get('numComments') ?? 0,
          numLikes: doc.get('numLikes') ?? 0,
          numViews: doc.get('numViews') ?? 0,
          propid: doc.get('propid') ?? '',
          menuid: doc.get('menuid') ?? '',
          ownerUid: doc.get('ownerUid') ?? '',
          status: doc.get('status') ?? '',
          imageId: doc.get('imageId') ?? '',
          forSale: doc.get('forSale') ?? false,
          forRent: doc.get('forRent') ?? false,
          forInstallment: doc.get('forInstallment') ?? false,
          forSwap: doc.get('forSwap') ?? false,
          termCode: doc.get('termCode') ?? '',
        );
      } catch (e) {
        print('wwwwwwww');
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all property item on stream
  Stream<List<PropertyItemModel>> getPropery(String ownerId) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .snapshots()
        .map(_PropertyList);
  }

  // get all property item on stream
  Stream<List<PropertyItemModel>> getAllPropery(String ownerId, String menuid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List<PropertyItemModel>> getAll() {
    print('oooooo');
    return propertyCollection.snapshots().map(_PropertyList);
  }

  @override
  Stream<List<PropertyItemModel>> getByUid(String uid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List<PropertyItemModel>> getByMenu(String menuid) {
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
  Stream<List<PropertyItemModel>> getByPropId(String propid) {
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
