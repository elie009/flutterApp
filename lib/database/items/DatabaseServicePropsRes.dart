import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/Property1001Model.dart';

class DatabaseServicePropsLot implements DatabaseServicePropsStructure {
  static final CollectionReference propertyCollection =
      FirebaseFirestore.instance.collection('property');

  //get item list from snapshot
  // ignore: non_constant_identifier_names
  List<PropertyLotModel> _LotPropertyList(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return PropertyLotModel(
          lotSize: doc.get('lotSize') ?? 0,
          saleLotOption: doc.get('saleLotOption') ?? 0,
          saleLotFixPrice: doc.get('saleLotFixPrice') ?? 0,
          rentLotOption: doc.get('rentLotOption') ?? 0,
          rentLotFixPrice: doc.get('rentLotFixPrice') ?? 0,
          rentAgreement: doc.get('rentAgreement') ?? 0,
          rentTermsOfPaymentCd: doc.get('rentTermsOfPaymentCd') ?? 0,
          rentMinContactCd: doc.get('rentMinContactCd') ?? 0,
          rentMinContactNum: doc.get('rentMinContactNum') ?? 0,
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
          forSwap: doc.get('forSwap') ?? false,
          conditionCode: doc.get('conditionCode') ?? -1,
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  // get all property item on stream
  Stream<List<PropertyLotModel>> getProperyLot(String ownerId) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .snapshots()
        .map(_LotPropertyList);
  }

  @override
  Stream<List<PropertyLotModel>> getByPropId(String propid) {
    return propertyCollection
        .where('propid', isEqualTo: propid)
        .snapshots()
        .map(_LotPropertyList);
  }

  // get all property item on stream
  Stream<List<PropertyLotModel>> getAllProperyLot(
      String ownerId, String menuid) {
    return propertyCollection
        .where('ownerUid', isEqualTo: ownerId)
        .where('menuid', isEqualTo: menuid)
        .snapshots()
        .map(_LotPropertyList);
  }

  @override
  Future add(dynamic rawdata) {
    PropertyLotModel data = rawdata;
    return propertyCollection.doc(data.propid).set({
      'numComments': data.numComments == null ? 0 : data.numComments,
      'numLikes': data.numLikes == null ? 0 : data.numLikes,
      'numViews': data.numViews == null ? 0 : data.numViews,
      'propid': data.propid,
      'title': data.title,
      'description': data.description,
      'imageName': data.imageName,
      'saleFixPrice': data.saleFixPrice,
      'rentFixPrice': data.rentFixPrice,
      'installmentFixPrice': data.installmentFixPrice,
      'location': data.location,
      'menuid': data.menuid,
      'ownerUid': data.ownerUid,
      'status': data.status,
      'postdate': data.postdate,
      'forSwap': data.forSwap,
      'conditionCode': data.conditionCode,
      'lotSize': data.lotSize,
      'saleLotOption': data.saleLotOption,
      'rentLotOption': data.rentLotOption,
      'rentAgreement': data.rentAgreement,
      'rentTermsOfPaymentCd': data.rentTermsOfPaymentCd,
      'rentMinContactCd': data.rentMinContactCd,
      'rentMinContactNum': data.rentMinContactNum,
    });
  }

  @override
  delete(String propid) {
    // TODO: implement delete
    throw UnimplementedError();
  }

  @override
  getAll() {
    // TODO: implement getAll
    throw UnimplementedError();
  }

  @override
  getByMenu(String menuid) {
    // TODO: implement getByMenu
    throw UnimplementedError();
  }

  @override
  getByUid(String uid) {
    // TODO: implement getByUid
    throw UnimplementedError();
  }

  @override
  getByUserMenu(String uid, String menuid) {
    // TODO: implement getByUserMenu
    throw UnimplementedError();
  }
}
