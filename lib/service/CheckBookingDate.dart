import 'package:flutter_app/model/BookingObj.dart';
import 'package:flutter_app/utils/Formatter.dart';
import 'package:intl/intl.dart';

class CheckiingBookDate {
  List<Booking> activeDates;
  CheckiingBookDate(List<Booking> activeDates) {
    this.activeDates = activeDates;
  }

  String isMyBooking(String inputDate, String userId) {
    for (var date in activeDates) {
      if (date.bookingStatus == 'APPROVE' && date.userId == userId) {
        String indexString = DateTime(toInt(date.fromYear),
                toInt(date.fromMonth), toInt(date.fromDay))
            .toString();
        if (indexString == inputDate) {
          return date.bookId;
        }
      }
    }
    return null;
  }

  bool isNotBlockDate(String inputDate) {
    activeDates.forEach((date) {
      if (date.bookingStatus == 'APPROVE') {
        String indexString = DateTime(toInt(date.fromYear),
                toInt(date.fromMonth), toInt(date.fromDay))
            .toString();

        if (inputDate == indexString) {
          //TO DO
        }
      }
      return false;
    });
  }
}
