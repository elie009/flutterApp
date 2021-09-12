import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/database/Database.dart';
import 'package:flutter_app/database/SingleItemChecker.dart';
import 'package:flutter_app/model/BookingModel.dart';
import 'package:flutter_app/object/BookingObj.dart';
import 'package:flutter_app/service/CheckBookingDate.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:flutter_app/utils/GenerateUid.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class BookedDates extends StatefulWidget {
  @override
  _BookedDatesState createState() => _BookedDatesState();
}

class _BookedDatesState extends State<BookedDates> {
  List<BookingModel> listitems;
  String _selectedDate = '';
  String _dateCount = '';
  String _range = '';
  String _rangeCount = '';
  Booking endbook = null;
  String isSelected = null;
  void _onSelectionChanged(DateRangePickerSelectionChangedArgs args) {
    setState(() {
      if (args.value is PickerDateRange) {
        _range =
            DateFormat('dd/MM/yyyy').format(args.value.startDate).toString() +
                ' - ' +
                DateFormat('dd/MM/yyyy')
                    .format(args.value.endDate ?? args.value.startDate)
                    .toString();

        print(_range);
      } else if (args.value is DateTime) {
        _selectedDate = args.value.toString();
      } else if (args.value is List<DateTime>) {
        _dateCount = args.value.length.toString();
      } else {
        _rangeCount = args.value.length.toString();
      }

      String year = DateFormat('y').format(args.value).toString();
      String month = DateFormat('MM').format(args.value).toString();
      String day = DateFormat('dd').format(args.value).toString();
      Booking book = new Booking(
          year,
          month,
          day,
          year,
          month,
          day,
          '9uJd3K6rT3cEPmRb6G7xN6NBPCV4',
          bookingID,
          '9uJd3K6rT3cEPmRb6G7xN6NBPCV2',
          'APPROVE');
      endbook = book;

      CheckiingBookDate activeDate = new CheckiingBookDate(listitems);
      isSelected =
          activeDate.isMyBooking(_selectedDate, '9uJd3K6rT3cEPmRb6G7xN6NBPCV2');
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = Provider.of<List<BookingModel>>(context);
    listitems = items;
    return Stack(
      children: <Widget>[
        Positioned(
          left: 0,
          top: 0,
          right: 0,
          bottom: 100,
          child: SfDateRangePicker(
            view: DateRangePickerView.month,
            monthViewSettings: DateRangePickerMonthViewSettings(blackoutDates: [
              for (var i in items)
                if (i.bookingStatus == 'BREAK')
                  DateTime(
                      toInt(i.fromYear), toInt(i.fromMonth), toInt(i.fromDay))
            ], weekendDays: [
              7,
              6
            ], specialDates: [
              for (var i in items)
                if (i.bookingStatus == 'APPROVE')
                  DateTime(
                      toInt(i.fromYear), toInt(i.fromMonth), toInt(i.fromDay))
            ], showTrailingAndLeadingDates: true),
            monthCellStyle: DateRangePickerMonthCellStyle(
              blackoutDatesDecoration: BoxDecoration(
                  color: Colors.red,
                  border: Border.all(color: const Color(0xFFF44436), width: 1),
                  shape: BoxShape.circle),
              weekendDatesDecoration: BoxDecoration(
                  color: const Color(0xFFDFDFDF),
                  border: Border.all(color: const Color(0xFFB6B6B6), width: 1),
                  shape: BoxShape.circle),
              specialDatesDecoration: BoxDecoration(
                  color: Colors.green,
                  border: Border.all(color: const Color(0xFF2B732F), width: 1),
                  shape: BoxShape.circle),
              blackoutDateTextStyle: TextStyle(
                  color: Colors.white, decoration: TextDecoration.lineThrough),
              specialDatesTextStyle: const TextStyle(color: Colors.white),
            ),
            onSelectionChanged: _onSelectionChanged,
            selectionMode: DateRangePickerSelectionMode.single,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (isSelected != null)
                InkWell(
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('AlertDialog Title'),
                      content: const Text('AlertDialog description'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (endbook != null) {
                              endbook.bookingStatus = 'CANCEL';
                              endbook.bookId = isSelected;
                              SingleItemChecker().updateBooking(endbook);
                            }

                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    width: 300.0,
                    height: 45.0,
                    decoration: new BoxDecoration(
                      color: Color(0xFFfd2c2c),
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'Cancel Appointment',
                        style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
              if (isSelected == null)
                InkWell(
                  onTap: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('AlertDialog Title'),
                      content: const Text('AlertDialog description'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () {
                            print(endbook);

                            if (endbook != null)
                              SingleItemChecker().addBooking(endbook);

                            Navigator.pop(context, 'OK');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: Container(
                    width: 300.0,
                    height: 45.0,
                    decoration: new BoxDecoration(
                      color: Color(0xFFfd2c2c),
                      border: Border.all(color: Colors.white, width: 2.0),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Center(
                      child: Text(
                        'Book and Appointment',
                        style: new TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w400),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
