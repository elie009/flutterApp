import 'package:equatable/equatable.dart';

class Transaction extends Equatable {
  final String id;
  final DateTime transactionDate;
  final String description;
  final double amount;
  final String transactionType; // 'credit', 'debit', 'transfer'
  final String? category;
  final double? balanceAfterTransaction;
  final String? merchant;
  final DateTime createdAt;

  const Transaction({
    required this.id,
    required this.transactionDate,
    required this.description,
    required this.amount,
    required this.transactionType,
    this.category,
    this.balanceAfterTransaction,
    this.merchant,
    required this.createdAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      transactionType: json['transactionType'] as String,
      category: json['category'] as String?,
      balanceAfterTransaction: json['balanceAfterTransaction'] != null
          ? (json['balanceAfterTransaction'] as num).toDouble()
          : null,
      merchant: json['merchant'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'transactionDate': transactionDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'transactionType': transactionType,
      'category': category,
      'balanceAfterTransaction': balanceAfterTransaction,
      'merchant': merchant,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  bool get isIncome => transactionType == 'credit';
  bool get isExpense => transactionType == 'debit';

  @override
  List<Object?> get props => [
        id,
        transactionDate,
        description,
        amount,
        transactionType,
        category,
        balanceAfterTransaction,
        merchant,
        createdAt,
      ];
}

