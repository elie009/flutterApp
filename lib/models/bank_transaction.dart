import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class BankTransaction extends Equatable {
  final String id;
  final String bankAccountId;
  final String userId;
  final double amount;
  final String transactionType; // 'CREDIT' or 'DEBIT'
  final String description;
  final String? category;
  final String? referenceNumber;
  final String? externalTransactionId;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? notes;
  final String? merchant;
  final String? location;
  final bool isRecurring;
  final String? recurringFrequency;
  final String currency;
  final double balanceAfterTransaction;

  const BankTransaction({
    required this.id,
    required this.bankAccountId,
    required this.userId,
    required this.amount,
    required this.transactionType,
    required this.description,
    this.category,
    this.referenceNumber,
    this.externalTransactionId,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
    this.notes,
    this.merchant,
    this.location,
    this.isRecurring = false,
    this.recurringFrequency,
    this.currency = 'USD',
    required this.balanceAfterTransaction,
  });

  factory BankTransaction.fromJson(Map<String, dynamic> json) {
    return BankTransaction(
      id: json['id'] as String,
      bankAccountId: json['bankAccountId'] as String,
      userId: json['userId'] as String? ?? '',
      amount: JsonParser.parseDoubleRequired(json['amount']),
      transactionType: json['transactionType'] as String,
      description: json['description'] as String,
      category: json['category'] as String?,
      referenceNumber: json['referenceNumber'] as String?,
      externalTransactionId: json['externalTransactionId'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      notes: json['notes'] as String?,
      merchant: json['merchant'] as String?,
      location: json['location'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      currency: json['currency'] as String? ?? 'USD',
      balanceAfterTransaction: JsonParser.parseDoubleRequired(
        json['balanceAfterTransaction'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankAccountId': bankAccountId,
      'userId': userId,
      'amount': amount,
      'transactionType': transactionType,
      'description': description,
      'category': category,
      'referenceNumber': referenceNumber,
      'externalTransactionId': externalTransactionId,
      'transactionDate': transactionDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'notes': notes,
      'merchant': merchant,
      'location': location,
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'currency': currency,
      'balanceAfterTransaction': balanceAfterTransaction,
    };
  }

  bool get isIncome => transactionType.toUpperCase() == 'CREDIT';
  bool get isExpense => transactionType.toUpperCase() == 'DEBIT';

  @override
  List<Object?> get props => [
        id,
        bankAccountId,
        userId,
        amount,
        transactionType,
        description,
        category,
        referenceNumber,
        externalTransactionId,
        transactionDate,
        createdAt,
        updatedAt,
        notes,
        merchant,
        location,
        isRecurring,
        recurringFrequency,
        currency,
        balanceAfterTransaction,
      ];
}

