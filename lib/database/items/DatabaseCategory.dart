import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/CategoryModel.dart';

class DatabaseCategory {
  final CollectionReference categoryCollection =
      FirebaseFirestore.instance.collection('category');

  static final CollectionReference categoryCollectionGlobal =
      FirebaseFirestore.instance.collection('category');

  Future setCategoryForm(CategoryFormModel form, String action) async {
    return await categoryCollection
        .doc(form.categoryid)
        .collection(action)
        .doc(action)
        .set({
      "categoryid": form.categoryid,
      "popsid": form.popsid,
      "title": form.title,
      "condition_brandnew": form.condition_brandnew,
      "condition_likebrandnew": form.condition_likebrandnew,
      "condition_wellused": form.condition_wellused,
      "condition_heavilyused": form.condition_heavilyused,
      "condition_new": form.condition_new,
      "condition_preselling": form.condition_preselling,
      "condition_preowned": form.condition_preowned,
      "condition_foreclosed": form.condition_foreclosed,
      "condition_used": form.condition_used,
      "priceinput_price": form.priceinput_price,
      "description": form.description,
      "ismoreandsameitem": form.ismoreandsameitem,
      "deal_meetup": form.deal_meetup,
      "deal_delivery": form.deal_delivery,
      "brandCODE": form.brandCODE,
      "location_cityproviceCODE": form.location_cityproviceCODE,
      "location_streetaddress": form.location_streetaddress,
      "unitdetails_lotarea": form.unitdetails_lotarea,
      "unitdetails_termsCODE": form.unitdetails_termsCODE,
      "unitdetails_bedroom": form.unitdetails_bedroom,
      "unitdetails_bathroom": form.unitdetails_bathroom,
      "unitdetails_floorarea": form.unitdetails_floorarea,
      "unitdetails_parkingspace": form.unitdetails_parkingspace,
      "unitdetails_furnish_unfurnish": form.unitdetails_furnish_unfurnish,
      "unitdetails_furnish_semifurnish": form.unitdetails_furnish_semifurnish,
      "unitdetails_furnish_fullyfurnish": form.unitdetails_furnish_fullyfurnish,
      "unitdetails_room_private": form.unitdetails_room_private,
      "unitdetails_room_shared": form.unitdetails_room_shared,
    });
  }

  //get item list from snapshot
  List<CategoryFormModel> _categoryFormListFromSnapshot(
      QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return CategoryFormModel(
          categoryid: doc.get('isinstallment') ?? false,
          popsid: doc.get('isinstallment') ?? false,
          title: doc.get('isinstallment') ?? false,
          condition_brandnew: doc.get('isinstallment') ?? false,
          condition_likebrandnew: doc.get('isinstallment') ?? false,
          condition_wellused: doc.get('isinstallment') ?? false,
          condition_heavilyused: doc.get('isinstallment') ?? false,
          condition_new: doc.get('isinstallment') ?? false,
          condition_preselling: doc.get('isinstallment') ?? false,
          condition_preowned: doc.get('isinstallment') ?? false,
          condition_foreclosed: doc.get('isinstallment') ?? false,
          condition_used: doc.get('isinstallment') ?? false,
          priceinput_price: doc.get('isinstallment') ?? false,
          description: doc.get('isinstallment') ?? false,
          ismoreandsameitem: doc.get('isinstallment') ?? false,
          deal_meetup: doc.get('isinstallment') ?? false,
          deal_delivery: doc.get('isinstallment') ?? false,
          brandCODE: doc.get('isinstallment') ?? false,
          location_cityproviceCODE: doc.get('isinstallment') ?? false,
          location_streetaddress: doc.get('isinstallment') ?? false,
          unitdetails_lotarea: doc.get('isinstallment') ?? false,
          unitdetails_termsCODE: doc.get('isinstallment') ?? false,
          unitdetails_bedroom: doc.get('isinstallment') ?? false,
          unitdetails_bathroom: doc.get('isinstallment') ?? false,
          unitdetails_floorarea: doc.get('isinstallment') ?? false,
          unitdetails_parkingspace: doc.get('isinstallment') ?? false,
          unitdetails_furnish_unfurnish: doc.get('isinstallment') ?? false,
          unitdetails_furnish_semifurnish: doc.get('isinstallment') ?? false,
          unitdetails_furnish_fullyfurnish: doc.get('isinstallment') ?? false,
          unitdetails_room_private: doc.get('isinstallment') ?? false,
          unitdetails_room_shared: doc.get('isinstallment') ?? false,
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  Stream<List<CategoryFormModel>> getCategoryForm(
      String catcode, String action) {
    return categoryCollection
        .doc(catcode)
        .collection(action)
        .snapshots()
        .map(_categoryFormListFromSnapshot);
  }

  Future updateCategory(CategoryModel categoryitem) async {
    return await categoryCollection.doc(categoryitem.catid).set({
      'catid': categoryitem.catid,
      'title': categoryitem.title,
      'status': categoryitem.status,
      'issale': categoryitem.issale,
      'isrent': categoryitem.isrent,
      'isswap': categoryitem.isswap,
      'isinstallment': categoryitem.isinstallment,
      'dateadded': categoryitem.dateadded,
      'iconapp': categoryitem.iconapp,
      'iconweb': categoryitem.iconweb,
      'headcategory': categoryitem.headcategory
    });
  }

  Future deleteCategory() async {
    try {
      var snapshots = await categoryCollection.get();
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

  //get item list from snapshot
  List<CategoryModel> _categoryListFromSnapshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      try {
        return CategoryModel(
          catid: doc.get('catid') ?? '',
          title: doc.get('title') ?? '',
          status: doc.get('status') ?? '',
          issale: doc.get('issale') ?? false,
          isrent: doc.get('isrent') ?? false,
          isinstallment: doc.get('isinstallment') ?? false,
          isswap: doc.get('isswap') ?? false,
          dateadded: doc.get('dateadded') ?? '',
          iconapp: doc.get('iconapp') ?? '',
          iconweb: doc.get('iconweb') ?? '',
          headcategory: doc.get('headcategory') ?? '',
        );
      } catch (e) {
        print(e.toString());
        return null;
      }
    }).toList();
  }

  //get all menu item on stream
  Stream<List<CategoryModel>> get getAllCategory {
    return categoryCollection.snapshots().map(_categoryListFromSnapshot);
  }
}
