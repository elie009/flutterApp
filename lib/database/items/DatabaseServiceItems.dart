import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/PropertyItemModel.dart';

class DatabaseServiceItems implements DatabaseServicePropsStructure {
  final CollectionReference propertyCollectionGlobal =
      FirebaseFirestore.instance.collection('property');

  static final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');

  List<PropertyItemModel> _PropertyList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return PropertyItemModel(
          title: doc.get('title') ?? '',
          conditionCode: doc.get('conditionCode') ?? '',
          priceselectionCode: doc.get('priceselectionCode') ?? '',
          price: doc.get('price') ?? 0.00,
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
          termCode: doc.get('termCode') ?? '',
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
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all property item on stream
  Stream<List<PropertyItemModel>> getProperyLot(String ownerId) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Stream<List<PropertyItemModel>> getByPropId(String propid) {
    return propertyCollection
        .where('propid', isEqualTo: propid)
        .snapshots()
        .map(_PropertyList);
  }

  // get all property item on stream
  Stream<List<PropertyItemModel>> getAllProperyLot(
      String ownerId, String menuid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  Future add(dynamic rawdata) {
    PropertyItemModel data = rawdata;
    return propertyCollection.doc(data.propid).set({
      'title': data.title,
      'conditionCode': data.conditionCode,
      'priceselectionCode': data.priceselectionCode,
      'price': data.price,
      'description': data.description,
      'ismoreandsameitem': data.ismoreandsameitem,
      'dealmethodCode': data.dealmethodCode,
      'location_cityprovinceCode': data.location_cityprovinceCode,
      'location_streetaddress': data.location_streetaddress,
      'branchCode': data.branchCode,
      'featureCode': data.featureCode,
      'lotarea': data.lotarea,
      'bedroms': data.bedroms,
      'bathrooms': data.bathrooms,
      'floorarea': data.floorarea,
      'carspace': data.carspace,
      'furnishingCode': data.furnishingCode,
      'roomCode': data.roomCode,
      'termCode': data.termCode,
      'numComments': data.numComments == null ? 0 : data.numComments,
      'numLikes': data.numLikes == null ? 0 : data.numLikes,
      'numViews': data.numViews == null ? 0 : data.numViews,
      'propid': data.propid,
      'menuid': data.menuid,
      'ownerUid': data.ownerUid,
      'status': data.status,
      'imageId': data.imageId,
      'forSale': data.forSale,
      'forRent': data.forRent,
      'forInstallment': data.forInstallment,
      'forSwap': data.forSwap,
    });
  }

  @override
  delete(String propid) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  getAll() {
    return propertyCollection.snapshots().map(_PropertyList);
  }

  @override
  getByMenu(String menuid) {
    return propertyCollection
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  getByUid(String uid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: uid)
        .snapshots()
        .map(_PropertyList);
  }

  @override
  getByUserMenu(String uid, String menuid) {
    // TODO: implement getByUserMenu
    throw UnimplementedError();
  }
}
