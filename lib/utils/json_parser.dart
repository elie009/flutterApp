/// Utility class for safely parsing JSON values that might be strings or numbers
class JsonParser {
  static double? parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    if (value is num) return value.toDouble();
    return null;
  }

  static double parseDoubleRequired(dynamic value, {double defaultValue = 0.0}) {
    return parseDouble(value) ?? defaultValue;
  }

  static int? parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) return value.toInt();
    return null;
  }

  static int parseIntRequired(dynamic value, {int defaultValue = 0}) {
    return parseInt(value) ?? defaultValue;
  }

  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    if (value is String) return value;
    return value.toString();
  }
}

