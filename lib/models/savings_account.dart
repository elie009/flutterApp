import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class SavingsAccount extends Equatable {
  final String id;
  final String userId;
  final String accountName;
  final String savingsType; // EMERGENCY, VACATION, INVESTMENT, etc.
  final String? accountType; // REGULAR, HIGH_YIELD, CD, MONEY_MARKET
  final double? interestRate; // Annual interest rate (e.g., 0.045 for 4.5%)
  final String? interestCompoundingFrequency; // DAILY, MONTHLY, QUARTERLY, ANNUALLY
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
  
  // Calculated fields
  final double progressPercentage;
  final double remainingAmount;
  final int daysRemaining;
  final double monthlyTarget;

  const SavingsAccount({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.savingsType,
    this.accountType,
    this.interestRate,
    this.interestCompoundingFrequency,
    this.lastInterestCalculationDate,
    this.nextInterestCalculationDate,
    required this.targetAmount,
    required this.currentBalance,
    this.currency = 'USD',
    this.description,
    this.goal,
    required this.targetDate,
    this.startDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    this.progressPercentage = 0.0,
    this.remainingAmount = 0.0,
    this.daysRemaining = 0,
    this.monthlyTarget = 0.0,
  });

  factory SavingsAccount.fromJson(Map<String, dynamic> json) {
    final targetAmount = JsonParser.parseDoubleRequired(json['targetAmount']);
    final currentBalance = JsonParser.parseDoubleRequired(
      json['currentBalance'] ?? json['balance'] ?? 0.0,
    );
    final targetDate = json['targetDate'] != null
        ? DateTime.parse(json['targetDate'] as String)
        : DateTime.now().add(const Duration(days: 365));
    final now = DateTime.now();
    
    // Calculate progress
    final progressPercentage = targetAmount > 0
        ? (currentBalance / targetAmount * 100).clamp(0.0, 100.0)
        : 0.0;
    final remainingAmount = (targetAmount - currentBalance).clamp(0.0, double.infinity);
    final daysRemaining = targetDate.isAfter(now)
        ? targetDate.difference(now).inDays
        : 0;
    final monthlyTarget = daysRemaining > 0
        ? remainingAmount / (daysRemaining / 30.0)
        : 0.0;

    return SavingsAccount(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      accountName: json['accountName'] as String,
      savingsType: json['savingsType'] as String,
      accountType: json['accountType'] as String?,
      interestRate: json['interestRate'] != null ? (json['interestRate'] as num).toDouble() : null,
      interestCompoundingFrequency: json['interestCompoundingFrequency'] as String?,
      lastInterestCalculationDate: json['lastInterestCalculationDate'] != null
          ? DateTime.parse(json['lastInterestCalculationDate'] as String)
          : null,
      nextInterestCalculationDate: json['nextInterestCalculationDate'] != null
          ? DateTime.parse(json['nextInterestCalculationDate'] as String)
          : null,
      targetAmount: targetAmount,
      currentBalance: currentBalance,
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String?,
      goal: json['goal'] as String?,
      targetDate: targetDate,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      progressPercentage: JsonParser.parseDoubleRequired(
        json['progressPercentage'],
        defaultValue: progressPercentage,
      ),
      remainingAmount: JsonParser.parseDoubleRequired(
        json['remainingAmount'],
        defaultValue: remainingAmount,
      ),
      daysRemaining: JsonParser.parseIntRequired(
        json['daysRemaining'],
        defaultValue: daysRemaining,
      ),
      monthlyTarget: JsonParser.parseDoubleRequired(
        json['monthlyTarget'],
        defaultValue: monthlyTarget,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountName': accountName,
      'savingsType': savingsType,
      'accountType': accountType,
      'interestRate': interestRate,
      'interestCompoundingFrequency': interestCompoundingFrequency,
      'lastInterestCalculationDate': lastInterestCalculationDate?.toIso8601String(),
      'nextInterestCalculationDate': nextInterestCalculationDate?.toIso8601String(),
      'targetAmount': targetAmount,
      'currentBalance': currentBalance,
      'currency': currency,
      'description': description,
      'goal': goal,
      'targetDate': targetDate.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'progressPercentage': progressPercentage,
      'remainingAmount': remainingAmount,
      'daysRemaining': daysRemaining,
      'monthlyTarget': monthlyTarget,
    };
  }

  bool get isGoalCompleted => currentBalance >= targetAmount;

  @override
  List<Object?> get props => [
        id,
        userId,
        accountName,
        savingsType,
        accountType,
        interestRate,
        interestCompoundingFrequency,
        lastInterestCalculationDate,
        nextInterestCalculationDate,
        targetAmount,
        currentBalance,
        currency,
        description,
        goal,
        targetDate,
        startDate,
        isActive,
        createdAt,
        updatedAt,
        progressPercentage,
        remainingAmount,
        daysRemaining,
        monthlyTarget,
      ];
}








