import 'package:flutter/material.dart';
import 'package:flutter_app/animation/ScaleRoute.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/model/PropertyModel.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import '../FoodOrderPage.dart';
import 'BookedDates.dart';

class BookingPage extends StatefulWidget {
  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color(0xFFFAFAFA),
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF3a3737),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          brightness: Brightness.light,
          actions: <Widget>[],
        ),
        body: StreamProvider<List<BookingModel>>.value(
          value: DatabaseService().booking('9uJd3K6rT3cEPmRb6G7xN6NBPCV4'),
          initialData: [],
          child: Container(
            child: Scaffold(
                body: SfDateRangePickerTheme(
              data: SfDateRangePickerThemeData(
                brightness: Brightness.light,
                backgroundColor: Colors.white,
              ),
              child: BookedDates(), //Stack(
            )),
          ),
        ),
      ),
    );
  }
}
