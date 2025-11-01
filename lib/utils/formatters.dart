import 'package:intl/intl.dart';

class Formatters {
  static final DateFormat dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat displayDateFormat = DateFormat('MMM dd, yyyy');
  static final DateFormat dateTimeFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
  static final DateFormat displayDateTimeFormat = DateFormat('MMM dd, yyyy HH:mm');

  static String formatCurrency(double amount, {String symbol = '₱'}) {
    final isNegative = amount < 0;
    final absAmount = amount.abs();
    final formatted = absAmount.toStringAsFixed(2).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return isNegative ? '-$symbol$formatted' : '$symbol$formatted';
  }

  static String formatDate(DateTime date) {
    return displayDateFormat.format(date);
  }

  static String formatDateTime(DateTime dateTime) {
    return displayDateTimeFormat.format(dateTime);
  }

  static String formatDateString(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return displayDateFormat.format(date);
    } catch (e) {
      return dateString;
    }
  }

  static String formatDateTimeString(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      return displayDateTimeFormat.format(dateTime);
    } catch (e) {
      return dateTimeString;
    }
  }

  static String formatPhoneNumber(String phone) {
    if (phone.isEmpty) return phone;
    // Remove all non-digits
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    // Format: +XX XXX XXX XXXX
    if (digits.length >= 10) {
      return '+${digits.substring(0, digits.length - 10)} ${digits.substring(digits.length - 10, digits.length - 7)} ${digits.substring(digits.length - 7, digits.length - 4)} ${digits.substring(digits.length - 4)}';
    }
    return phone;
  }
}

