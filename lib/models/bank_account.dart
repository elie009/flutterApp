import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class BankAccount extends Equatable {
  final String id;
  final String userId;
  final String accountName;
  final String accountType; // 'bank', 'wallet', 'credit', 'cash', 'investment'
  final double initialBalance;
  final double currentBalance;
  final String currency;
  final String? description;
  final String? financialInstitution;
  final String? accountNumber; // Masked account number
  final String? routingNumber;
  final String syncFrequency; // 'MANUAL', 'DAILY', 'WEEKLY', 'MONTHLY'
  final bool isConnected;
  final String? connectionId;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;
  final String? iban;
  final String? swiftCode;
  final int transactionCount;
  final double totalIncoming;
  final double totalOutgoing;

  const BankAccount({
    required this.id,
    required this.userId,
    required this.accountName,
    required this.accountType,
    required this.initialBalance,
    required this.currentBalance,
    required this.currency,
    this.description,
    this.financialInstitution,
    this.accountNumber,
    this.routingNumber,
    this.syncFrequency = 'MANUAL',
    this.isConnected = false,
    this.connectionId,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.iban,
    this.swiftCode,
    this.transactionCount = 0,
    this.totalIncoming = 0.0,
    this.totalOutgoing = 0.0,
  });

  factory BankAccount.fromJson(Map<String, dynamic> json) {
    return BankAccount(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? '',
      accountName: json['accountName'] as String,
      accountType: json['accountType'] as String,
      initialBalance: JsonParser.parseDoubleRequired(
        json['initialBalance'] ?? json['balance'],
      ),
      currentBalance: JsonParser.parseDoubleRequired(
        json['currentBalance'] ?? json['balance'],
      ),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String?,
      financialInstitution: json['financialInstitution'] as String?,
      accountNumber: json['accountNumber'] as String?,
      routingNumber: json['routingNumber'] as String?,
      syncFrequency: json['syncFrequency'] as String? ?? 'MANUAL',
      isConnected: json['isConnected'] as bool? ?? false,
      connectionId: json['connectionId'] as String?,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isActive: json['isActive'] as bool? ?? true,
      iban: json['iban'] as String?,
      swiftCode: json['swiftCode'] as String?,
      transactionCount: JsonParser.parseIntRequired(json['transactionCount']),
      totalIncoming: JsonParser.parseDoubleRequired(json['totalIncoming']),
      totalOutgoing: JsonParser.parseDoubleRequired(json['totalOutgoing']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'accountName': accountName,
      'accountType': accountType,
      'initialBalance': initialBalance,
      'currentBalance': currentBalance,
      'currency': currency,
      'description': description,
      'financialInstitution': financialInstitution,
      'accountNumber': accountNumber,
      'routingNumber': routingNumber,
      'syncFrequency': syncFrequency,
      'isConnected': isConnected,
      'connectionId': connectionId,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isActive': isActive,
      'iban': iban,
      'swiftCode': swiftCode,
      'transactionCount': transactionCount,
      'totalIncoming': totalIncoming,
      'totalOutgoing': totalOutgoing,
    };
  }

  // Helper getter for backward compatibility
  double get balance => currentBalance;

  @override
  List<Object?> get props => [
        id,
        userId,
        accountName,
        accountType,
        initialBalance,
        currentBalance,
        currency,
        description,
        financialInstitution,
        accountNumber,
        routingNumber,
        syncFrequency,
        isConnected,
        connectionId,
        lastSyncedAt,
        createdAt,
        updatedAt,
        isActive,
        iban,
        swiftCode,
        transactionCount,
        totalIncoming,
        totalOutgoing,
      ];
}

