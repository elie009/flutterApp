import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/object/ProperyObj.dart';
import 'package:flutter_app/service/specialityService.dart';

class PrepareData {
  void execute() {
    //clearAll();
    //addData();
    addLotData();
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
}
