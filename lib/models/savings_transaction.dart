import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class SavingsTransaction extends Equatable {
  final String id;
  final String savingsAccountId;
  final String sourceBankAccountId;
  final double amount;
  final String transactionType; // DEPOSIT, WITHDRAWAL, TRANSFER, INTEREST, BONUS
  final String description;
  final String? category;
  final String? notes;
  final DateTime transactionDate;
  final String currency;
  final bool isRecurring;
  final String? recurringFrequency;
  final DateTime createdAt;

  const SavingsTransaction({
    required this.id,
    required this.savingsAccountId,
    required this.sourceBankAccountId,
    required this.amount,
    required this.transactionType,
    required this.description,
    this.category,
    this.notes,
    required this.transactionDate,
    this.currency = 'USD',
    this.isRecurring = false,
    this.recurringFrequency,
    required this.createdAt,
  });

  factory SavingsTransaction.fromJson(Map<String, dynamic> json) {
    return SavingsTransaction(
      id: json['id'] as String,
      savingsAccountId: json['savingsAccountId'] as String,
      sourceBankAccountId: json['sourceBankAccountId'] as String,
      amount: JsonParser.parseDoubleRequired(json['amount']),
      transactionType: json['transactionType'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      notes: json['notes'] as String?,
      transactionDate: json['transactionDate'] != null
          ? DateTime.parse(json['transactionDate'] as String)
          : DateTime.now(),
      currency: json['currency'] as String? ?? 'USD',
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'savingsAccountId': savingsAccountId,
      'sourceBankAccountId': sourceBankAccountId,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'category': category,
      'notes': notes,
      'transactionDate': transactionDate.toIso8601String(),
      'currency': currency,
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isDeposit => transactionType.toUpperCase() == 'DEPOSIT';
  bool get isWithdrawal => transactionType.toUpperCase() == 'WITHDRAWAL';

  @override
  List<Object?> get props => [
        id,
        savingsAccountId,
        sourceBankAccountId,
        amount,
        transactionType,
        description,
        category,
        notes,
        transactionDate,
        currency,
        isRecurring,
        recurringFrequency,
        createdAt,
      ];
}








