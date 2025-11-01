import 'package:equatable/equatable.dart';
import 'bank_account.dart';
import 'transaction.dart';
import 'bill.dart';

class DashboardSummary extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final int pendingBillsCount;
  final double pendingBillsAmount;
  final List<Bill> upcomingPayments;
  final List<Transaction> recentTransactions;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.pendingBillsCount,
    required this.pendingBillsAmount,
    required this.upcomingPayments,
    required this.recentTransactions,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBalance: (json['totalBalance'] as num?)?.toDouble() ?? 0.0,
      monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
      pendingBillsCount: json['pendingBillsCount'] as int? ?? 0,
      pendingBillsAmount: (json['pendingBillsAmount'] as num?)?.toDouble() ?? 0.0,
      upcomingPayments: (json['upcomingPayments'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [
        totalBalance,
        monthlyIncome,
        pendingBillsCount,
        pendingBillsAmount,
        upcomingPayments,
        recentTransactions,
      ];
}

