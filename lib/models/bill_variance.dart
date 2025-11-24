import '../utils/json_parser.dart';

class BillVariance {
  final String billId;
  final double actualAmount;
  final double estimatedAmount;
  final double variance;
  final double variancePercentage;
  final String status; // 'over_budget', 'slightly_over', 'on_target', 'under_budget', 'no_data'
  final String message;
  final String recommendation;

  const BillVariance({
    required this.billId,
    required this.actualAmount,
    required this.estimatedAmount,
    required this.variance,
    required this.variancePercentage,
    required this.status,
    required this.message,
    required this.recommendation,
  });

  factory BillVariance.fromJson(Map<String, dynamic> json) {
    return BillVariance(
      billId: json['billId'] as String,
      actualAmount: JsonParser.parseDoubleRequired(json['actualAmount']),
      estimatedAmount: JsonParser.parseDoubleRequired(json['estimatedAmount']),
      variance: JsonParser.parseDoubleRequired(json['variance']),
      variancePercentage: JsonParser.parseDoubleRequired(json['variancePercentage']),
      status: JsonParser.parseString(json['status'] ?? 'no_data'),
      message: JsonParser.parseString(json['message'] ?? ''),
      recommendation: JsonParser.parseString(json['recommendation'] ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'actualAmount': actualAmount,
      'estimatedAmount': estimatedAmount,
      'variance': variance,
      'variancePercentage': variancePercentage,
      'status': status,
      'message': message,
      'recommendation': recommendation,
    };
  }

  String get statusDisplay {
    switch (status.toLowerCase()) {
      case 'over_budget':
        return 'Over Budget';
      case 'slightly_over':
        return 'Slightly Over';
      case 'on_target':
        return 'On Target';
      case 'under_budget':
        return 'Under Budget';
      case 'no_data':
        return 'No Data';
      default:
        return status;
    }
  }

  bool get isOverBudget => status == 'over_budget' || status == 'slightly_over';
  bool get isOnTarget => status == 'on_target';
  bool get isUnderBudget => status == 'under_budget';
  bool get hasNoData => status == 'no_data';
}

