import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String get getDateNow {
  return new DateTime.now().toString();
}

DateTime toDateTime(String datetime) {
  return new DateFormat("yyyy-MM-dd hh:mm:ss").parse(datetime);
}

String toDateTimeStr(String datetime) {
  DateTime dt = new DateFormat("yyyy-MM-dd hh:mm:ss").parse(datetime);
  return formatTimeStamp(dt);
}

String get getDateNowMilliSecondStr {
  return new DateTime.now().millisecondsSinceEpoch.toString();
}

int get getDateNowMilliSecond {
  return new DateTime.now().millisecondsSinceEpoch;
}

String formatTimeStamp(DateTime datetime) {
  DateFormat format = new DateFormat("dd MMM yyyy");
  final now = DateTime.now();

  if (DateTime(now.year, now.month, now.day) ==
      DateTime(datetime.year, datetime.month, datetime.day))
    format = new DateFormat("dd MMM yyyy h:mm a");
  return format.format(datetime).toString();
}
