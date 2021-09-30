import 'package:flutter_app/utils/StaticString.dart';
import 'package:intl/intl.dart';

final oCcy = new NumberFormat("#,##0.00", "en_US");

String formatCurency(dynamic numbers) {
  return currency + oCcy.format('50000');
}

double toDouble(dynamic number) {
  return double.parse(number);
}

int toInt(String number) {
  return int.parse(number);
}

String textlimiter(String text) {
  if (text.length > 13) {
    return text.substring(0, 13) + '...';
  }
  return text;
}
