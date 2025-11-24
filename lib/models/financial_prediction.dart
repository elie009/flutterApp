import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class FinancialPrediction extends Equatable {
  final String type; // INCOME, EXPENSE, SAVINGS, BILL, NETWORTH
  final String description;
  final double predictedAmount;
  final DateTime predictionDate;
  final double confidence; // 0-100

  const FinancialPrediction({
    required this.type,
    required this.description,
    required this.predictedAmount,
    required this.predictionDate,
    required this.confidence,
  });

  factory FinancialPrediction.fromJson(Map<String, dynamic> json) {
    return FinancialPrediction(
      type: JsonParser.parseString(json['type']),
      description: JsonParser.parseString(json['description']),
      predictedAmount: JsonParser.parseDoubleRequired(json['predictedAmount']),
      predictionDate: DateTime.parse(json['predictionDate'] as String),
      confidence: JsonParser.parseDoubleRequired(json['confidence']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
      'predictedAmount': predictedAmount,
      'predictionDate': predictionDate.toIso8601String(),
      'confidence': confidence,
    };
  }

  @override
  List<Object?> get props => [
        type,
        description,
        predictedAmount,
        predictionDate,
        confidence,
      ];
}

