import 'package:equatable/equatable.dart';
import 'bank_account.dart';
import 'transaction.dart';
import 'bill.dart';
import '../utils/json_parser.dart';

class DashboardSummary extends Equatable {
  final double totalBalance;
  final double monthlyIncome;
  final int pendingBillsCount;
  final double pendingBillsAmount;
  final List<Bill> upcomingPayments;
  final List<Transaction> recentTransactions;
  final double totalFixedExpenses;
  final double totalVariableExpenses;
  final double remainingPercentage;
  final double remainingDisposableAmount;
  final double totalSavings;

  const DashboardSummary({
    required this.totalBalance,
    required this.monthlyIncome,
    required this.pendingBillsCount,
    required this.pendingBillsAmount,
    required this.upcomingPayments,
    required this.recentTransactions,
    required this.totalFixedExpenses,
    required this.totalVariableExpenses,
    required this.remainingPercentage,
    required this.remainingDisposableAmount,
    required this.totalSavings,
  });

  // Computed property for total expense
  double get totalExpense => totalFixedExpenses + totalVariableExpenses;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalBalance: JsonParser.parseDouble(json['totalBalance']) ?? 0.0,
      monthlyIncome: JsonParser.parseDouble(json['monthlyIncome']) ?? 0.0,
      pendingBillsCount: JsonParser.parseInt(json['pendingBillsCount']) ?? 0,
      pendingBillsAmount: JsonParser.parseDouble(json['pendingBillsAmount']) ?? 0.0,
      upcomingPayments: (json['upcomingPayments'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      recentTransactions: (json['recentTransactions'] as List<dynamic>?)
              ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalFixedExpenses: JsonParser.parseDouble(json['totalFixedExpenses']) ?? 0.0,
      totalVariableExpenses: JsonParser.parseDouble(json['totalVariableExpenses']) ?? 0.0,
      remainingPercentage: JsonParser.parseDouble(json['remainingPercentage']) ?? 0.0,
      remainingDisposableAmount: JsonParser.parseDouble(json['remainingDisposableAmount']) ?? 0.0,
      totalSavings: JsonParser.parseDouble(json['totalSavings']) ?? 0.0,
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
        totalFixedExpenses,
        totalVariableExpenses,
        remainingPercentage,
        remainingDisposableAmount,
        totalSavings,
      ];
}

