import '../utils/json_parser.dart';

class BillForecast {
  final double estimatedAmount;
  final String calculationMethod; // "simple", "weighted", "seasonal"
  final String confidence; // "high", "medium", "low"
  final DateTime estimatedForMonth;
  final String recommendation;

  const BillForecast({
    required this.estimatedAmount,
    required this.calculationMethod,
    required this.confidence,
    required this.estimatedForMonth,
    required this.recommendation,
  });

  factory BillForecast.fromJson(Map<String, dynamic> json) {
    return BillForecast(
      estimatedAmount: JsonParser.parseDoubleRequired(json['estimatedAmount']),
      calculationMethod: JsonParser.parseString(json['calculationMethod'] ?? 'weighted'),
      confidence: JsonParser.parseString(json['confidence'] ?? 'medium'),
      estimatedForMonth: json['estimatedForMonth'] != null
          ? DateTime.parse(json['estimatedForMonth'] as String)
          : DateTime.now().add(const Duration(days: 30)),
      recommendation: JsonParser.parseString(json['recommendation'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'estimatedAmount': estimatedAmount,
      'calculationMethod': calculationMethod,
      'confidence': confidence,
      'estimatedForMonth': estimatedForMonth.toIso8601String(),
      'recommendation': recommendation,
    };
  }

  String get confidenceDisplay {
    switch (confidence.toLowerCase()) {
      case 'high':
        return 'High Confidence';
      case 'medium':
        return 'Medium Confidence';
      case 'low':
        return 'Low Confidence';
      default:
        return 'Unknown';
    }
  }

  String get methodDisplay {
    switch (calculationMethod.toLowerCase()) {
      case 'simple':
        return 'Simple Average';
      case 'weighted':
        return 'Weighted Average';
      case 'seasonal':
        return 'Seasonal Average';
      default:
        return calculationMethod;
    }
  }
}

