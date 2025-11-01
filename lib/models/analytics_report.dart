class TrendDataPoint {
  final String? date;
  final String label;
  final double value;

  TrendDataPoint({
    this.date,
    required this.label,
    required this.value,
  });

  factory TrendDataPoint.fromJson(Map<String, dynamic> json) {
    return TrendDataPoint(
      date: json['date'] as String?,
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date,
      'label': label,
      'value': value,
    };
  }
}

class FinancialSummary {
  final double totalIncome;
  final double incomeChange;
  final double totalExpenses;
  final double expenseChange;
  final double disposableIncome;
  final double disposableIncomeChange;
  final double netWorth;
  final double netWorthChange;
  final double savingsProgress;
  final double savingsGoal;
  final double totalSavings;

  FinancialSummary({
    required this.totalIncome,
    required this.incomeChange,
    required this.totalExpenses,
    required this.expenseChange,
    required this.disposableIncome,
    required this.disposableIncomeChange,
    required this.netWorth,
    required this.netWorthChange,
    required this.savingsProgress,
    required this.savingsGoal,
    required this.totalSavings,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      incomeChange: (json['incomeChange'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      expenseChange: (json['expenseChange'] as num?)?.toDouble() ?? 0.0,
      disposableIncome: (json['disposableIncome'] as num?)?.toDouble() ?? 0.0,
      disposableIncomeChange:
          (json['disposableIncomeChange'] as num?)?.toDouble() ?? 0.0,
      netWorth: (json['netWorth'] as num?)?.toDouble() ?? 0.0,
      netWorthChange: (json['netWorthChange'] as num?)?.toDouble() ?? 0.0,
      savingsProgress: (json['savingsProgress'] as num?)?.toDouble() ?? 0.0,
      savingsGoal: (json['savingsGoal'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IncomeReport {
  final double totalIncome;
  final double monthlyAverage;
  final double growthRate;
  final Map<String, double> incomeBySource;
  final Map<String, double> incomeByCategory;
  final List<TrendDataPoint> incomeTrend;
  final String topIncomeSource;
  final double topIncomeAmount;

  IncomeReport({
    required this.totalIncome,
    required this.monthlyAverage,
    required this.growthRate,
    required this.incomeBySource,
    required this.incomeByCategory,
    required this.incomeTrend,
    required this.topIncomeSource,
    required this.topIncomeAmount,
  });

  factory IncomeReport.fromJson(Map<String, dynamic> json) {
    final incomeBySourceMap = <String, double>{};
    if (json['incomeBySource'] is Map) {
      (json['incomeBySource'] as Map).forEach((key, value) {
        incomeBySourceMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    final incomeByCategoryMap = <String, double>{};
    if (json['incomeByCategory'] is Map) {
      (json['incomeByCategory'] as Map).forEach((key, value) {
        incomeByCategoryMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    return IncomeReport(
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
      monthlyAverage: (json['monthlyAverage'] as num?)?.toDouble() ?? 0.0,
      growthRate: (json['growthRate'] as num?)?.toDouble() ?? 0.0,
      incomeBySource: incomeBySourceMap,
      incomeByCategory: incomeByCategoryMap,
      incomeTrend: (json['incomeTrend'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topIncomeSource: json['topIncomeSource'] as String? ?? '',
      topIncomeAmount: (json['topIncomeAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ExpenseComparison {
  final String category;
  final double currentAmount;
  final double previousAmount;
  final double change;
  final double changePercentage;

  ExpenseComparison({
    required this.category,
    required this.currentAmount,
    required this.previousAmount,
    required this.change,
    required this.changePercentage,
  });

  factory ExpenseComparison.fromJson(Map<String, dynamic> json) {
    return ExpenseComparison(
      category: json['category'] as String? ?? '',
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      previousAmount: (json['previousAmount'] as num?)?.toDouble() ?? 0.0,
      change: (json['change'] as num?)?.toDouble() ?? 0.0,
      changePercentage:
          (json['changePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ExpenseReport {
  final double totalExpenses;
  final double fixedExpenses;
  final double variableExpenses;
  final Map<String, double> expenseByCategory;
  final Map<String, double> expensePercentage;
  final List<TrendDataPoint> expenseTrend;
  final String highestExpenseCategory;
  final double highestExpenseAmount;
  final double highestExpensePercentage;
  final double averageMonthlyExpense;
  final List<ExpenseComparison> categoryComparison;

  ExpenseReport({
    required this.totalExpenses,
    required this.fixedExpenses,
    required this.variableExpenses,
    required this.expenseByCategory,
    required this.expensePercentage,
    required this.expenseTrend,
    required this.highestExpenseCategory,
    required this.highestExpenseAmount,
    required this.highestExpensePercentage,
    required this.averageMonthlyExpense,
    required this.categoryComparison,
  });

  factory ExpenseReport.fromJson(Map<String, dynamic> json) {
    final expenseByCategoryMap = <String, double>{};
    if (json['expenseByCategory'] is Map) {
      (json['expenseByCategory'] as Map).forEach((key, value) {
        expenseByCategoryMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    final expensePercentageMap = <String, double>{};
    if (json['expensePercentage'] is Map) {
      (json['expensePercentage'] as Map).forEach((key, value) {
        expensePercentageMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    return ExpenseReport(
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      fixedExpenses: (json['fixedExpenses'] as num?)?.toDouble() ?? 0.0,
      variableExpenses: (json['variableExpenses'] as num?)?.toDouble() ?? 0.0,
      expenseByCategory: expenseByCategoryMap,
      expensePercentage: expensePercentageMap,
      expenseTrend: (json['expenseTrend'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      highestExpenseCategory: json['highestExpenseCategory'] as String? ?? '',
      highestExpenseAmount:
          (json['highestExpenseAmount'] as num?)?.toDouble() ?? 0.0,
      highestExpensePercentage:
          (json['highestExpensePercentage'] as num?)?.toDouble() ?? 0.0,
      averageMonthlyExpense:
          (json['averageMonthlyExpense'] as num?)?.toDouble() ?? 0.0,
      categoryComparison: (json['categoryComparison'] as List<dynamic>?)
              ?.map((e) =>
                  ExpenseComparison.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class LoanDetail {
  final String loanId;
  final String purpose;
  final double principal;
  final double remainingBalance;
  final double monthlyPayment;
  final double interestRate;
  final double repaymentProgress;

  LoanDetail({
    required this.loanId,
    required this.purpose,
    required this.principal,
    required this.remainingBalance,
    required this.monthlyPayment,
    required this.interestRate,
    required this.repaymentProgress,
  });

  factory LoanDetail.fromJson(Map<String, dynamic> json) {
    return LoanDetail(
      loanId: json['loanId'] as String? ?? '',
      purpose: json['purpose'] as String? ?? '',
      principal: (json['principal'] as num?)?.toDouble() ?? 0.0,
      remainingBalance: (json['remainingBalance'] as num?)?.toDouble() ?? 0.0,
      monthlyPayment: (json['monthlyPayment'] as num?)?.toDouble() ?? 0.0,
      interestRate: (json['interestRate'] as num?)?.toDouble() ?? 0.0,
      repaymentProgress:
          (json['repaymentProgress'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LoanReport {
  final int activeLoansCount;
  final double totalPrincipal;
  final double totalRemainingBalance;
  final double totalMonthlyPayment;
  final double totalInterestPaid;
  final List<LoanDetail> activeLoans;
  final List<TrendDataPoint> repaymentTrend;
  final DateTime? projectedDebtFreeDate;
  final int monthsUntilDebtFree;

  LoanReport({
    required this.activeLoansCount,
    required this.totalPrincipal,
    required this.totalRemainingBalance,
    required this.totalMonthlyPayment,
    required this.totalInterestPaid,
    required this.activeLoans,
    required this.repaymentTrend,
    this.projectedDebtFreeDate,
    required this.monthsUntilDebtFree,
  });

  factory LoanReport.fromJson(Map<String, dynamic> json) {
    return LoanReport(
      activeLoansCount: (json['activeLoansCount'] as num?)?.toInt() ?? 0,
      totalPrincipal: (json['totalPrincipal'] as num?)?.toDouble() ?? 0.0,
      totalRemainingBalance:
          (json['totalRemainingBalance'] as num?)?.toDouble() ?? 0.0,
      totalMonthlyPayment:
          (json['totalMonthlyPayment'] as num?)?.toDouble() ?? 0.0,
      totalInterestPaid:
          (json['totalInterestPaid'] as num?)?.toDouble() ?? 0.0,
      activeLoans: (json['activeLoans'] as List<dynamic>?)
              ?.map((e) => LoanDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      repaymentTrend: (json['repaymentTrend'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      projectedDebtFreeDate: json['projectedDebtFreeDate'] != null
          ? DateTime.parse(json['projectedDebtFreeDate'] as String)
          : null,
      monthsUntilDebtFree: (json['monthsUntilDebtFree'] as num?)?.toInt() ?? 0,
    );
  }
}

class NetWorthReport {
  final double currentNetWorth;
  final double netWorthChange;
  final double netWorthChangePercentage;
  final double totalAssets;
  final double totalLiabilities;
  final Map<String, double> assetBreakdown;
  final Map<String, double> liabilityBreakdown;
  final List<TrendDataPoint> netWorthTrend;
  final String trendDescription;

  NetWorthReport({
    required this.currentNetWorth,
    required this.netWorthChange,
    required this.netWorthChangePercentage,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.assetBreakdown,
    required this.liabilityBreakdown,
    required this.netWorthTrend,
    required this.trendDescription,
  });

  factory NetWorthReport.fromJson(Map<String, dynamic> json) {
    final assetBreakdownMap = <String, double>{};
    if (json['assetBreakdown'] is Map) {
      (json['assetBreakdown'] as Map).forEach((key, value) {
        assetBreakdownMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    final liabilityBreakdownMap = <String, double>{};
    if (json['liabilityBreakdown'] is Map) {
      (json['liabilityBreakdown'] as Map).forEach((key, value) {
        liabilityBreakdownMap[key.toString()] =
            (value as num?)?.toDouble() ?? 0.0;
      });
    }

    return NetWorthReport(
      currentNetWorth: (json['currentNetWorth'] as num?)?.toDouble() ?? 0.0,
      netWorthChange: (json['netWorthChange'] as num?)?.toDouble() ?? 0.0,
      netWorthChangePercentage:
          (json['netWorthChangePercentage'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
      assetBreakdown: assetBreakdownMap,
      liabilityBreakdown: liabilityBreakdownMap,
      netWorthTrend: (json['netWorthTrend'] as List<dynamic>?)
              ?.map((e) => TrendDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      trendDescription: json['trendDescription'] as String? ?? '',
    );
  }
}

class FullFinancialReport {
  final String? reportDate;
  final String? period;
  final FinancialSummary summary;
  final IncomeReport incomeReport;
  final ExpenseReport expenseReport;
  final LoanReport? loanReport;
  final NetWorthReport? netWorthReport;

  FullFinancialReport({
    this.reportDate,
    this.period,
    required this.summary,
    required this.incomeReport,
    required this.expenseReport,
    this.loanReport,
    this.netWorthReport,
  });

  factory FullFinancialReport.fromJson(Map<String, dynamic> json) {
    return FullFinancialReport(
      reportDate: json['reportDate'] as String?,
      period: json['period'] as String?,
      summary: FinancialSummary.fromJson(
          json['summary'] as Map<String, dynamic>),
      incomeReport: IncomeReport.fromJson(
          json['incomeReport'] as Map<String, dynamic>),
      expenseReport: ExpenseReport.fromJson(
          json['expenseReport'] as Map<String, dynamic>),
      loanReport: json['loanReport'] != null
          ? LoanReport.fromJson(json['loanReport'] as Map<String, dynamic>)
          : null,
      netWorthReport: json['netWorthReport'] != null
          ? NetWorthReport.fromJson(
              json['netWorthReport'] as Map<String, dynamic>)
          : null,
    );
  }
}
