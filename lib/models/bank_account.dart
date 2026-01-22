import 'package:equatable/equatable.dart';

class BankAccount extends Equatable {
  final String id;
  final String accountName;
  final String? accountNumber; // Can be null
  final String accountType; // 'CHECKING', 'SAVINGS', etc.
  final double balance;
  final double initialBalance;
  final String currency;
  final bool isActive;
  final String? financialInstitution;
  final String? iban; // IBAN number for card display

  const BankAccount({
    required this.id,
    required this.accountName,
    this.accountNumber, // Now optional
    required this.accountType,
    required this.balance,
    required this.initialBalance,
    required this.currency,
    required this.isActive,
    this.financialInstitution,
    this.iban,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    // API returns 'currentBalance' but model uses 'balance'
    final balanceValue = json['currentBalance'] ?? json['balance'];
    final initialBalanceValue = json['initialBalance'];
    
    return BankAccount(
      id: json['id'] as String,
      accountName: json['accountName'] as String,
      accountNumber: json['accountNumber'] as String?, // Can be null
      accountType: json['accountType'] as String,
      balance: (balanceValue as num?)?.toDouble() ?? 0.0, // Handle null
      initialBalance: (initialBalanceValue as num?)?.toDouble() ?? 0.0, // Handle null
      currency: json['currency'] as String? ?? 'USD',
      isActive: json['isActive'] as bool? ?? true,
      financialInstitution: json['financialInstitution'] as String?,
      iban: json['iban'] as String?, // IBAN for card number display
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
      'iban': iban,
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
        iban,
      ];
}

