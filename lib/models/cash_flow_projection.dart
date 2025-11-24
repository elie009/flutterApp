import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class MonthlyCashFlow extends Equatable {
  final DateTime month;
  final double startingBalance;
  final double income;
  final double expenses;
  final double bills;
  final double loanPayments;
  final double savings;
  final double endingBalance;
  final double netFlow;

  const MonthlyCashFlow({
    required this.month,
    required this.startingBalance,
    required this.income,
    required this.expenses,
    required this.bills,
    required this.loanPayments,
    required this.savings,
    required this.endingBalance,
    required this.netFlow,
  });

  factory MonthlyCashFlow.fromJson(Map<String, dynamic> json) {
    return MonthlyCashFlow(
      month: DateTime.parse(json['month'] as String),
      startingBalance: JsonParser.parseDoubleRequired(json['startingBalance']),
      income: JsonParser.parseDoubleRequired(json['income']),
      expenses: JsonParser.parseDoubleRequired(json['expenses']),
      bills: JsonParser.parseDoubleRequired(json['bills']),
      loanPayments: JsonParser.parseDoubleRequired(json['loanPayments']),
      savings: JsonParser.parseDoubleRequired(json['savings']),
      endingBalance: JsonParser.parseDoubleRequired(json['endingBalance']),
      netFlow: JsonParser.parseDoubleRequired(json['netFlow']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month.toIso8601String(),
      'startingBalance': startingBalance,
      'income': income,
      'expenses': expenses,
      'bills': bills,
      'loanPayments': loanPayments,
      'savings': savings,
      'endingBalance': endingBalance,
      'netFlow': netFlow,
    };
  }

  @override
  List<Object?> get props => [
        month,
        startingBalance,
        income,
        expenses,
        bills,
        loanPayments,
        savings,
        endingBalance,
        netFlow,
      ];
}

class CashFlowProjection extends Equatable {
  final DateTime projectionDate;
  final int monthsAhead;
  final double startingBalance;
  final double projectedIncome;
  final double projectedExpenses;
  final double projectedBills;
  final double projectedLoanPayments;
  final double projectedSavings;
  final double projectedEndingBalance;
  final double netCashFlow;
  final List<MonthlyCashFlow> monthlyBreakdown;

  const CashFlowProjection({
    required this.projectionDate,
    required this.monthsAhead,
    required this.startingBalance,
    required this.projectedIncome,
    required this.projectedExpenses,
    required this.projectedBills,
    required this.projectedLoanPayments,
    required this.projectedSavings,
    required this.projectedEndingBalance,
    required this.netCashFlow,
    required this.monthlyBreakdown,
  });

  factory CashFlowProjection.fromJson(Map<String, dynamic> json) {
    return CashFlowProjection(
      projectionDate: DateTime.parse(json['projectionDate'] as String),
      monthsAhead: JsonParser.parseIntRequired(json['monthsAhead']),
      startingBalance: JsonParser.parseDoubleRequired(json['startingBalance']),
      projectedIncome: JsonParser.parseDoubleRequired(json['projectedIncome']),
      projectedExpenses: JsonParser.parseDoubleRequired(json['projectedExpenses']),
      projectedBills: JsonParser.parseDoubleRequired(json['projectedBills']),
      projectedLoanPayments: JsonParser.parseDoubleRequired(json['projectedLoanPayments']),
      projectedSavings: JsonParser.parseDoubleRequired(json['projectedSavings']),
      projectedEndingBalance: JsonParser.parseDoubleRequired(json['projectedEndingBalance']),
      netCashFlow: JsonParser.parseDoubleRequired(json['netCashFlow']),
      monthlyBreakdown: (json['monthlyBreakdown'] as List<dynamic>?)
              ?.map((e) => MonthlyCashFlow.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projectionDate': projectionDate.toIso8601String(),
      'monthsAhead': monthsAhead,
      'startingBalance': startingBalance,
      'projectedIncome': projectedIncome,
      'projectedExpenses': projectedExpenses,
      'projectedBills': projectedBills,
      'projectedLoanPayments': projectedLoanPayments,
      'projectedSavings': projectedSavings,
      'projectedEndingBalance': projectedEndingBalance,
      'netCashFlow': netCashFlow,
      'monthlyBreakdown': monthlyBreakdown.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
        projectionDate,
        monthsAhead,
        startingBalance,
        projectedIncome,
        projectedExpenses,
        projectedBills,
        projectedLoanPayments,
        projectedSavings,
        projectedEndingBalance,
        netCashFlow,
        monthlyBreakdown,
      ];
}

