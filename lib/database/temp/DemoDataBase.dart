import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/items/DatabaseCategory.dart';
import 'package:flutter_app/database/items/DatabaseServiceItems.dart';
import 'package:flutter_app/model/CategoryFormModel.dart';
import 'package:flutter_app/model/CategoryModel.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class PrepareData {
  void execute() {
    //clearAll();
    //addCategoryData();
    //addCategoryCollection();
    //updateProps();
    //updateCategoryCollection();
    updateUser();
    //addBookingData();
    print('your in the demo database');
  }

  // Future clearAll() async {
  //   await DatabaseService(uid: '9uJd3K6rT3cEPmRb6G7xN6NBPCV2').deleteAllitem();
  // }

  String menuid = idMenu;

  Future addCategoryData() async {
    var lot = CategoryModel(
        catid: '1001',
        title: 'Lot',
        status: 'APPROVE',
        issale: true,
        isrent: true,
        isinstallment: true,
        isswap: true,
        dateadded: getDateNow,
        iconapp: '',
        iconweb: '',
        headcategory: 'NONE');

    await DatabaseCategory().updateCategory(lot);

    var hal = CategoryModel(
        catid: '1002',
        title: 'House & Lot',
        status: 'APPROVE',
        issale: true,
        isrent: true,
        isinstallment: true,
        isswap: true,
        dateadded: getDateNow,
        iconapp: '',
        iconweb: '',
        headcategory: 'NONE');

    await DatabaseCategory().updateCategory(hal);
  }

  Future updateProps() async {
    CollectionReference ref = DatabaseServiceItems.propertyCollection;
    ref.snapshots().forEach((element) {
      element.docs.forEach((data) {
        DatabaseServiceItems.propertyCollection.doc(data.get("propid")).update({
          "installment_downpayment": 0.00,
          "installment_equity": 0.00,
          "installment_amort": 0.00,
          "installment_monthstopay": 0.00,
        });
      });
    });
  }

  Future updateUser() async {
    CollectionReference ref = DatabaseService().userCollection;
    ref.snapshots().forEach((element) {
      element.docs.forEach((data) {
        DatabaseService().userCollection.doc(data.get("uid")).update({
          "post": "0",
          "ratings": "0",
          "response": "0",
          "followers": "0",
          "following": "0",
        });
      });
    });
  }

  Future updateCategoryCollection() async {
    DatabaseCategory.categoryCollectionGlobal
        .doc('1002')
        .collection('swap')
        .doc('swap')
        .update({
      "priceinput_equity": null,
      "priceinput_downpayment": null,
      "priceinput_amortization": null,
      "payments_count": null,
    });
  }

  Future addCategoryCollection() async {
    // var datarent = CategoryFormModel(
    //   categoryid: '1001',
    //   title: true,
    //   description: true,
    //   priceinput_price: true,
    //   location_cityproviceCODE: true,
    //   location_streetaddress: true,
    //   unitdetails_lotarea: true,
    //   unitdetails_termsCODE: true,
    // );
    // var datarent = CategoryFormModel(
    //   categoryid: '1002',
    //   title: true,
    //   description: true,
    //   priceinput_price: true,
    //   ismoreandsameitem: true,
    //   location_cityproviceCODE: true,
    //   location_streetaddress: true,
    //   unitdetails_lotarea: true,
    //   unitdetails_bedroom: true,
    //   unitdetails_bathroom: true,
    //   unitdetails_floorarea: true,
    //   unitdetails_parkingspace: true,
    //   unitdetails_furnish_fullyfurnish: true,
    //   unitdetails_furnish_semifurnish: true,
    //   unitdetails_furnish_unfurnish: true,
    //   unitdetails_termsCODE: true,
    // );
    // await DatabaseCategory().setCategoryForm(datarent, 'rent');

    var datasalelot = CategoryFormModel(
      categoryid: '1001',
      title: true,
      description: true,
      location_cityproviceCODE: true,
      location_streetaddress: true,
      unitdetails_lotarea: true,
      condition_new: true,
      condition_preselling: true,
      condition_preowned: true,
      condition_foreclosed: true,
      priceinput_price: true,
      priceinput_downpayment: true,
      payments_count: true,
      priceinput_amortization: true,
      priceinput_equity: true,
    );
    await DatabaseCategory().setCategoryForm(datasalelot, 'installment');
    var datasalehal = CategoryFormModel(
      categoryid: '1002',
      title: true,
      description: true,
      ismoreandsameitem: true,
      priceinput_price: true,
      priceinput_downpayment: true,
      payments_count: true,
      location_cityproviceCODE: true,
      location_streetaddress: true,
      unitdetails_lotarea: true,
      unitdetails_bedroom: true,
      unitdetails_bathroom: true,
      unitdetails_floorarea: true,
      unitdetails_parkingspace: true,
      unitdetails_furnish_fullyfurnish: true,
      unitdetails_furnish_semifurnish: true,
      unitdetails_furnish_unfurnish: true,
      condition_new: true,
      condition_preselling: true,
      condition_preowned: true,
      condition_foreclosed: true,
      priceinput_amortization: true,
      priceinput_equity: true,
    );
    await DatabaseCategory().setCategoryForm(datasalehal, 'installment');
  }

  Future addBookingData() async {
    List<Map<String, String>> list = [
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '02',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '02',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1001',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'APPROVE'
      },
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '12',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '12',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1002',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'APPROVE'
      },
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '15',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '15',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1003',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'APPROVE'
      },
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '20',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '20',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1004',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'BREAK'
      },
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '21',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '21',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1005',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'APPROVE'
      },
      {
        'fromYear': '2021',
        'fromMonth': '09',
        'fromDay': '30',
        'toYear': '2021',
        'toMonth': '09',
        'toDay': '30',
        'propsId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
        'bookId': '1006',
        'userId': '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
        'bookingStatus': 'BREAK'
      },
    ];
    list.forEach((e) async {
      BookingModel props = BookingModel(
        e['fromYear'].toString(),
        e['fromMonth'].toString(),
        e['fromDay'].toString(),
        e['toYear'].toString(),
        e['toMonth'].toString(),
        e['toDay'].toString(),
        e['propsId'].toString(),
        e['bookId'].toString(),
        e['userId'].toString(),
        e['bookingStatus'].toString(),
      );
      await DatabaseService(uid: e['bookId'].toString()).updateBooking(props);
    });
  }
}
