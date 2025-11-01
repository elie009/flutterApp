import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class IncomeSource extends Equatable {
  final String id;
  final String name;
  final double amount;
  final String frequency; // 'MONTHLY', 'WEEKLY', 'DAILY', etc.
  final String? category; // 'PRIMARY', 'SECONDARY', etc.
  final String currency;
  final double monthlyAmount;
  final bool isActive;
  final String? company;
  final String? description;

  const IncomeSource({
    required this.id,
    required this.name,
    required this.amount,
    required this.frequency,
    this.category,
    required this.currency,
    required this.monthlyAmount,
    required this.isActive,
    this.company,
    this.description,
  });

  factory IncomeSource.fromJson(Map<String, dynamic> json) {
    return IncomeSource(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: JsonParser.parseDoubleRequired(json['amount']),
      frequency: JsonParser.parseString(json['frequency']),
      category: json['category'] as String?,
      currency: json['currency'] as String? ?? 'PHP',
      monthlyAmount: JsonParser.parseDoubleRequired(json['monthlyAmount']),
      isActive: json['isActive'] as bool? ?? true,
      company: json['company'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'frequency': frequency,
      'category': category,
      'currency': currency,
      'monthlyAmount': monthlyAmount,
      'isActive': isActive,
      'company': company,
      'description': description,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        amount,
        frequency,
        category,
        currency,
        monthlyAmount,
        isActive,
        company,
        description,
      ];
}

