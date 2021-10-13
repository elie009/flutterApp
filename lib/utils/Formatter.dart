import 'package:flutter_app/utils/StaticString.dart';
import 'package:intl/intl.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

final $searchForValue = ',';
String formatCurency(dynamic numbers) {
  numbers = numbers is String ? toDouble(numbers) : numbers;
  return currency + oCcy.format(numbers);
}

double toDouble(String number) {
  if (number == null || number.isEmpty) return null;
  if (number.contains($searchForValue)) {
    number = number.replaceAll(",", "");
  }

  return double.parse(number);
}

int toInt(String number) {
  if (number == null || number.isEmpty) return null;
  return int.parse(number);
}

String textlimiter(String text) {
  if (text.length > 13) {
    return text.substring(0, 13) + '...';
  }
  return text;
}
