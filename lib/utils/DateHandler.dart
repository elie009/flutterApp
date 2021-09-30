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

List<DropdropValue> termsDateCode = [
  DropdropValue(key: 'A01001', value: 'Hours'),
  DropdropValue(key: 'A01002', value: 'Days'),
  DropdropValue(key: 'A01003', value: 'Weeks'),
  DropdropValue(key: 'A01004', value: 'Months'),
  DropdropValue(key: 'A01005', value: 'Years'),
  DropdropValue(key: 'A01006', value: 'Others'),
];

String convertTermsCodeToDate(String code) {
  String resultValue = '';
  termsDateCode.forEach((element) {
    if (element.key == code) resultValue = element.value;
  });
  return resultValue;
}

class DropdropValue {
  String key;
  String value;
  DropdropValue({this.key, this.value});
}
