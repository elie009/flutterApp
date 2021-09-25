import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/MenuModel.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/model/PropertyLotModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:flutter_app/utils/DateHandler.dart';
import 'package:flutter_app/utils/GenerateUid.dart';

class PrepareData {
  void execute() {
    //clearAll();
    //addMenuData();
    addProperyData();
    //addBookingData();
    print('your in the demo database');
  }

  Future clearAll() async {
    await DatabaseService(uid: '9uJd3K6rT3cEPmRb6G7xN6NBPCV2').deleteAllitem();
  }

  String menuid = idMenu;

  Future addMenuData() async {
    await DatabaseService(uid: menuid).updateMenuData(MenuModel(
        menuid: menuid,
        name: 'Residential',
        description: 'simple description',
        imageAppName: '',
        imageWebName: 'NA',
        dropdownid: ''));
  }

  Future addProperyData() async {
    final list = [
      "Lot for sale",
      "Yuta data-data",
      "Farm lot for rent",
      "Condo for Sale",
      "House and lot for sale",
      "House for sale casamira",
      "Townhouse for sale",
      "For assume House and lot",
      "Lot data2x",
      "200m lot"
    ];
    for (String i in list) {
      String id = idPropertyLot;
      PropertyLotModel props = PropertyLotModel(
          0,
          0,
          0,
          id,
          i,
          'simple description',
          "assets/images/bestfood/ic_best_food_8.jpeg",
          500000,
          'Cebu City, Cebu',
          '1001',
          'nwpxhS8cqDgYw8QtcKKYuQogMf92',
          0.00,
          0.00,
          '',
          '',
          '',
          '',
          '',
          '',
          'APPROVE',getDateNowMilliSecondStr);

      await DatabaseService(uid: id).updatePropertyLot(props);
    }
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
      await DatabaseService(uid: e['bookId'].toString())
          .updateBookingData(props);
    });
  }
}
