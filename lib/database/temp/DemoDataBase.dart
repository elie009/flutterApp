import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/object/BookingObj.dart';
import 'package:flutter_app/object/ProperyObj.dart';

class PrepareData {
  void execute() {
    //clearAll();
    //addData();
    //addLotData();
    addBookingData();
    print('your in the demo database');
  }

  Future clearAll() async {
    await DatabaseService(uid: '9uJd3K6rT3cEPmRb6G7xN6NBPCV2').deleteAllitem();
  }

  Future addData() async {
    await DatabaseService(uid: '9uJd3K6rT3cEPmRb6G7xN6NBPCV1')
        .updateItemData("Farm Log", "simple description", 2000, "");
  }

  Future addLotData() async {
    final list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
    for (int i in list) {
      String id = '9uJd3K6rT3cEPmRb6G7xN6NBPCV' + i.toString();
      Property props = Property(
          id,
          "Lot for sale",
          "simple description",
          "assets/images/bestfood/ic_best_food_8.jpeg",
          0,
          0,
          500000,
          "Cebu City, Central Visayas",
          "001");

      await DatabaseService(uid: id).updateProperyData(props);
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
      Booking props = Booking(
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
