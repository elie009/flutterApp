import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class BankAccount extends Equatable {
  final String id;
  final String accountName;
  final String accountNumber;
  final String accountType; // 'CHECKING', 'SAVINGS', etc.
  final double balance;
  final double initialBalance;
  final String currency;
  final bool isActive;
  final String? financialInstitution;

  const BankAccount({
    required this.id,
    required this.accountName,
    required this.accountNumber,
    required this.accountType,
    required this.balance,
    required this.initialBalance,
    required this.currency,
    required this.isActive,
    this.financialInstitution,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String,
      accountType: json['accountType'] as String,
      balance: JsonParser.parseDoubleRequired(json['balance']),
      initialBalance: JsonParser.parseDoubleRequired(json['initialBalance']),
      currency: json['currency'] as String? ?? 'PHP',
      isActive: json['isActive'] as bool? ?? true,
      financialInstitution: json['financialInstitution'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'accountType': accountType,
      'balance': balance,
      'initialBalance': initialBalance,
      'currency': currency,
      'isActive': isActive,
      'financialInstitution': financialInstitution,
    };
  }

  @override
  List<Object?> get props => [
        id,
        accountName,
        accountNumber,
        accountType,
        balance,
        initialBalance,
        currency,
        isActive,
        financialInstitution,
      ];
}

