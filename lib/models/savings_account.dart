import 'package:equatable/equatable.dart';

class SavingsAccount extends Equatable {
  final String id;
  final String accountName;
  final String savingsType;
  final String? accountType;
  final double? interestRate;
  final String? interestCompoundingFrequency;
  final DateTime? lastInterestCalculationDate;
  final DateTime? nextInterestCalculationDate;
  final double targetAmount;
  final double currentBalance;
  final String currency;
  final String? description;
  final String? goal;
  final DateTime targetDate;
  final DateTime? startDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double progressPercentage;
  final double remainingAmount;
  final int daysRemaining;
  final double monthlyTarget;

  const SavingsAccount({
    required this.id,
    required this.accountName,
    required this.savingsType,
    this.accountType,
    this.interestRate,
    this.interestCompoundingFrequency,
    this.lastInterestCalculationDate,
    this.nextInterestCalculationDate,
    required this.targetAmount,
    required this.currentBalance,
    required this.currency,
    this.description,
    this.goal,
    required this.targetDate,
    this.startDate,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.progressPercentage,
    required this.remainingAmount,
    required this.daysRemaining,
    required this.monthlyTarget,
  });

  factory SavingsAccount.fromJson(Map<String, dynamic> json) {
    return SavingsAccount(
      id: json['id'] as String,
      accountName: json['accountName'] as String? ?? '',
      savingsType: json['savingsType'] as String? ?? 'GENERAL',
      accountType: json['accountType'] as String?,
      interestRate: json['interestRate'] != null ? (json['interestRate'] as num).toDouble() : null,
      interestCompoundingFrequency: json['interestCompoundingFrequency'] as String?,
      lastInterestCalculationDate: json['lastInterestCalculationDate'] != null
          ? DateTime.parse(json['lastInterestCalculationDate'] as String)
          : null,
      nextInterestCalculationDate: json['nextInterestCalculationDate'] != null
          ? DateTime.parse(json['nextInterestCalculationDate'] as String)
          : null,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String?,
      goal: json['goal'] as String?,
      targetDate: DateTime.parse(json['targetDate'] as String),
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      progressPercentage: (json['progressPercentage'] as num?)?.toDouble() ?? 0,
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble() ?? 0,
      daysRemaining: json['daysRemaining'] as int? ?? 0,
      monthlyTarget: (json['monthlyTarget'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
      'savingsType': savingsType,
      'accountType': accountType,
      'interestRate': interestRate,
      'interestCompoundingFrequency': interestCompoundingFrequency,
      'targetAmount': targetAmount,
      'currentBalance': currentBalance,
      'currency': currency,
      'description': description,
      'goal': goal,
      'targetDate': targetDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'isActive': isActive,
      'progressPercentage': progressPercentage,
      'remainingAmount': remainingAmount,
      'daysRemaining': daysRemaining,
      'monthlyTarget': monthlyTarget,
    };
  }

  @override
  List<Object?> get props => [id];
}
