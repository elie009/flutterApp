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

// Balance Sheet Models
class BalanceSheetItem {
  final String accountName;
  final String accountType;
  final double amount;
  final String? description;
  final String? referenceId;

  BalanceSheetItem({
    required this.accountName,
    required this.accountType,
    required this.amount,
    this.description,
    this.referenceId,
  });

  factory BalanceSheetItem.fromJson(Map<String, dynamic> json) {
    return BalanceSheetItem(
      accountName: json['accountName'] as String? ?? '',
      accountType: json['accountType'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
    );
  }
}

class AssetsSection {
  final List<BalanceSheetItem> currentAssets;
  final double totalCurrentAssets;
  final List<BalanceSheetItem> fixedAssets;
  final double totalFixedAssets;
  final List<BalanceSheetItem> otherAssets;
  final double totalOtherAssets;
  final double totalAssets;

  AssetsSection({
    required this.currentAssets,
    required this.totalCurrentAssets,
    required this.fixedAssets,
    required this.totalFixedAssets,
    required this.otherAssets,
    required this.totalOtherAssets,
    required this.totalAssets,
  });

  factory AssetsSection.fromJson(Map<String, dynamic> json) {
    return AssetsSection(
      currentAssets: (json['currentAssets'] as List<dynamic>?)
              ?.map((e) => BalanceSheetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCurrentAssets: (json['totalCurrentAssets'] as num?)?.toDouble() ?? 0.0,
      fixedAssets: (json['fixedAssets'] as List<dynamic>?)
              ?.map((e) => BalanceSheetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalFixedAssets: (json['totalFixedAssets'] as num?)?.toDouble() ?? 0.0,
      otherAssets: (json['otherAssets'] as List<dynamic>?)
              ?.map((e) => BalanceSheetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalOtherAssets: (json['totalOtherAssets'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LiabilitiesSection {
  final List<BalanceSheetItem> currentLiabilities;
  final double totalCurrentLiabilities;
  final List<BalanceSheetItem> longTermLiabilities;
  final double totalLongTermLiabilities;
  final double totalLiabilities;

  LiabilitiesSection({
    required this.currentLiabilities,
    required this.totalCurrentLiabilities,
    required this.longTermLiabilities,
    required this.totalLongTermLiabilities,
    required this.totalLiabilities,
  });

  factory LiabilitiesSection.fromJson(Map<String, dynamic> json) {
    return LiabilitiesSection(
      currentLiabilities: (json['currentLiabilities'] as List<dynamic>?)
              ?.map((e) => BalanceSheetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCurrentLiabilities: (json['totalCurrentLiabilities'] as num?)?.toDouble() ?? 0.0,
      longTermLiabilities: (json['longTermLiabilities'] as List<dynamic>?)
              ?.map((e) => BalanceSheetItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalLongTermLiabilities: (json['totalLongTermLiabilities'] as num?)?.toDouble() ?? 0.0,
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EquitySection {
  final double ownersCapital;
  final double retainedEarnings;
  final double totalEquity;

  EquitySection({
    required this.ownersCapital,
    required this.retainedEarnings,
    required this.totalEquity,
  });

  factory EquitySection.fromJson(Map<String, dynamic> json) {
    return EquitySection(
      ownersCapital: (json['ownersCapital'] as num?)?.toDouble() ?? 0.0,
      retainedEarnings: (json['retainedEarnings'] as num?)?.toDouble() ?? 0.0,
      totalEquity: (json['totalEquity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class BalanceSheet {
  final String asOfDate;
  final AssetsSection assets;
  final LiabilitiesSection liabilities;
  final EquitySection equity;
  final double totalAssets;
  final double totalLiabilitiesAndEquity;
  final bool isBalanced;

  BalanceSheet({
    required this.asOfDate,
    required this.assets,
    required this.liabilities,
    required this.equity,
    required this.totalAssets,
    required this.totalLiabilitiesAndEquity,
    required this.isBalanced,
  });

  factory BalanceSheet.fromJson(Map<String, dynamic> json) {
    return BalanceSheet(
      asOfDate: json['asOfDate'] as String? ?? '',
      assets: AssetsSection.fromJson(json['assets'] as Map<String, dynamic>),
      liabilities: LiabilitiesSection.fromJson(json['liabilities'] as Map<String, dynamic>),
      equity: EquitySection.fromJson(json['equity'] as Map<String, dynamic>),
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalLiabilitiesAndEquity: (json['totalLiabilitiesAndEquity'] as num?)?.toDouble() ?? 0.0,
      isBalanced: json['isBalanced'] as bool? ?? false,
    );
  }
}

// Cash Flow Statement Models
class CashFlowItem {
  final String description;
  final String category;
  final double amount;
  final String transactionDate;
  final String? referenceId;
  final String? referenceType;

  CashFlowItem({
    required this.description,
    required this.category,
    required this.amount,
    required this.transactionDate,
    this.referenceId,
    this.referenceType,
  });

  factory CashFlowItem.fromJson(Map<String, dynamic> json) {
    return CashFlowItem(
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      transactionDate: json['transactionDate'] as String? ?? '',
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
    );
  }
}

class OperatingActivities {
  final double incomeReceived;
  final double otherOperatingInflows;
  final double totalOperatingInflows;
  final double expensesPaid;
  final double billsPaid;
  final double interestPaid;
  final double otherOperatingOutflows;
  final double totalOperatingOutflows;
  final double netCashFromOperations;
  final List<CashFlowItem> inflowItems;
  final List<CashFlowItem> outflowItems;

  OperatingActivities({
    required this.incomeReceived,
    required this.otherOperatingInflows,
    required this.totalOperatingInflows,
    required this.expensesPaid,
    required this.billsPaid,
    required this.interestPaid,
    required this.otherOperatingOutflows,
    required this.totalOperatingOutflows,
    required this.netCashFromOperations,
    required this.inflowItems,
    required this.outflowItems,
  });

  factory OperatingActivities.fromJson(Map<String, dynamic> json) {
    return OperatingActivities(
      incomeReceived: (json['incomeReceived'] as num?)?.toDouble() ?? 0.0,
      otherOperatingInflows: (json['otherOperatingInflows'] as num?)?.toDouble() ?? 0.0,
      totalOperatingInflows: (json['totalOperatingInflows'] as num?)?.toDouble() ?? 0.0,
      expensesPaid: (json['expensesPaid'] as num?)?.toDouble() ?? 0.0,
      billsPaid: (json['billsPaid'] as num?)?.toDouble() ?? 0.0,
      interestPaid: (json['interestPaid'] as num?)?.toDouble() ?? 0.0,
      otherOperatingOutflows: (json['otherOperatingOutflows'] as num?)?.toDouble() ?? 0.0,
      totalOperatingOutflows: (json['totalOperatingOutflows'] as num?)?.toDouble() ?? 0.0,
      netCashFromOperations: (json['netCashFromOperations'] as num?)?.toDouble() ?? 0.0,
      inflowItems: (json['inflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      outflowItems: (json['outflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class InvestingActivities {
  final double savingsWithdrawals;
  final double investmentReturns;
  final double otherInvestingInflows;
  final double totalInvestingInflows;
  final double savingsDeposits;
  final double investmentsMade;
  final double otherInvestingOutflows;
  final double totalInvestingOutflows;
  final double netCashFromInvesting;
  final List<CashFlowItem> inflowItems;
  final List<CashFlowItem> outflowItems;

  InvestingActivities({
    required this.savingsWithdrawals,
    required this.investmentReturns,
    required this.otherInvestingInflows,
    required this.totalInvestingInflows,
    required this.savingsDeposits,
    required this.investmentsMade,
    required this.otherInvestingOutflows,
    required this.totalInvestingOutflows,
    required this.netCashFromInvesting,
    required this.inflowItems,
    required this.outflowItems,
  });

  factory InvestingActivities.fromJson(Map<String, dynamic> json) {
    return InvestingActivities(
      savingsWithdrawals: (json['savingsWithdrawals'] as num?)?.toDouble() ?? 0.0,
      investmentReturns: (json['investmentReturns'] as num?)?.toDouble() ?? 0.0,
      otherInvestingInflows: (json['otherInvestingInflows'] as num?)?.toDouble() ?? 0.0,
      totalInvestingInflows: (json['totalInvestingInflows'] as num?)?.toDouble() ?? 0.0,
      savingsDeposits: (json['savingsDeposits'] as num?)?.toDouble() ?? 0.0,
      investmentsMade: (json['investmentsMade'] as num?)?.toDouble() ?? 0.0,
      otherInvestingOutflows: (json['otherInvestingOutflows'] as num?)?.toDouble() ?? 0.0,
      totalInvestingOutflows: (json['totalInvestingOutflows'] as num?)?.toDouble() ?? 0.0,
      netCashFromInvesting: (json['netCashFromInvesting'] as num?)?.toDouble() ?? 0.0,
      inflowItems: (json['inflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      outflowItems: (json['outflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class FinancingActivities {
  final double loanDisbursements;
  final double otherFinancingInflows;
  final double totalFinancingInflows;
  final double loanPayments;
  final double principalPayments;
  final double otherFinancingOutflows;
  final double totalFinancingOutflows;
  final double netCashFromFinancing;
  final List<CashFlowItem> inflowItems;
  final List<CashFlowItem> outflowItems;

  FinancingActivities({
    required this.loanDisbursements,
    required this.otherFinancingInflows,
    required this.totalFinancingInflows,
    required this.loanPayments,
    required this.principalPayments,
    required this.otherFinancingOutflows,
    required this.totalFinancingOutflows,
    required this.netCashFromFinancing,
    required this.inflowItems,
    required this.outflowItems,
  });

  factory FinancingActivities.fromJson(Map<String, dynamic> json) {
    return FinancingActivities(
      loanDisbursements: (json['loanDisbursements'] as num?)?.toDouble() ?? 0.0,
      otherFinancingInflows: (json['otherFinancingInflows'] as num?)?.toDouble() ?? 0.0,
      totalFinancingInflows: (json['totalFinancingInflows'] as num?)?.toDouble() ?? 0.0,
      loanPayments: (json['loanPayments'] as num?)?.toDouble() ?? 0.0,
      principalPayments: (json['principalPayments'] as num?)?.toDouble() ?? 0.0,
      otherFinancingOutflows: (json['otherFinancingOutflows'] as num?)?.toDouble() ?? 0.0,
      totalFinancingOutflows: (json['totalFinancingOutflows'] as num?)?.toDouble() ?? 0.0,
      netCashFromFinancing: (json['netCashFromFinancing'] as num?)?.toDouble() ?? 0.0,
      inflowItems: (json['inflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      outflowItems: (json['outflowItems'] as List?)
          ?.map((e) => CashFlowItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class CashFlowStatement {
  final String periodStart;
  final String periodEnd;
  final String period;
  final OperatingActivities operatingActivities;
  final InvestingActivities investingActivities;
  final FinancingActivities financingActivities;
  final double netCashFlow;
  final double beginningCash;
  final double endingCash;
  final bool isBalanced;

  CashFlowStatement({
    required this.periodStart,
    required this.periodEnd,
    required this.period,
    required this.operatingActivities,
    required this.investingActivities,
    required this.financingActivities,
    required this.netCashFlow,
    required this.beginningCash,
    required this.endingCash,
    required this.isBalanced,
  });

  factory CashFlowStatement.fromJson(Map<String, dynamic> json) {
    return CashFlowStatement(
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      period: json['period'] as String? ?? 'MONTHLY',
      operatingActivities: OperatingActivities.fromJson(
        json['operatingActivities'] as Map<String, dynamic>,
      ),
      investingActivities: InvestingActivities.fromJson(
        json['investingActivities'] as Map<String, dynamic>,
      ),
      financingActivities: FinancingActivities.fromJson(
        json['financingActivities'] as Map<String, dynamic>,
      ),
      netCashFlow: (json['netCashFlow'] as num?)?.toDouble() ?? 0.0,
      beginningCash: (json['beginningCash'] as num?)?.toDouble() ?? 0.0,
      endingCash: (json['endingCash'] as num?)?.toDouble() ?? 0.0,
      isBalanced: json['isBalanced'] as bool? ?? false,
    );
  }
}

// Income Statement Models
class IncomeStatementItem {
  final String accountName;
  final String category;
  final double amount;
  final String? description;
  final String? referenceId;
  final String? referenceType;

  IncomeStatementItem({
    required this.accountName,
    required this.category,
    required this.amount,
    this.description,
    this.referenceId,
    this.referenceType,
  });

  factory IncomeStatementItem.fromJson(Map<String, dynamic> json) {
    return IncomeStatementItem(
      accountName: json['accountName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] as String?,
      referenceId: json['referenceId'] as String?,
      referenceType: json['referenceType'] as String?,
    );
  }
}

class RevenueSection {
  final double salaryIncome;
  final double businessIncome;
  final double freelanceIncome;
  final double otherOperatingRevenue;
  final double totalOperatingRevenue;
  final double investmentIncome;
  final double interestIncome;
  final double rentalIncome;
  final double dividendIncome;
  final double otherIncome;
  final double totalOtherRevenue;
  final double totalRevenue;
  final List<IncomeStatementItem> revenueItems;

  RevenueSection({
    required this.salaryIncome,
    required this.businessIncome,
    required this.freelanceIncome,
    required this.otherOperatingRevenue,
    required this.totalOperatingRevenue,
    required this.investmentIncome,
    required this.interestIncome,
    required this.rentalIncome,
    required this.dividendIncome,
    required this.otherIncome,
    required this.totalOtherRevenue,
    required this.totalRevenue,
    required this.revenueItems,
  });

  factory RevenueSection.fromJson(Map<String, dynamic> json) {
    return RevenueSection(
      salaryIncome: (json['salaryIncome'] as num?)?.toDouble() ?? 0.0,
      businessIncome: (json['businessIncome'] as num?)?.toDouble() ?? 0.0,
      freelanceIncome: (json['freelanceIncome'] as num?)?.toDouble() ?? 0.0,
      otherOperatingRevenue: (json['otherOperatingRevenue'] as num?)?.toDouble() ?? 0.0,
      totalOperatingRevenue: (json['totalOperatingRevenue'] as num?)?.toDouble() ?? 0.0,
      investmentIncome: (json['investmentIncome'] as num?)?.toDouble() ?? 0.0,
      interestIncome: (json['interestIncome'] as num?)?.toDouble() ?? 0.0,
      rentalIncome: (json['rentalIncome'] as num?)?.toDouble() ?? 0.0,
      dividendIncome: (json['dividendIncome'] as num?)?.toDouble() ?? 0.0,
      otherIncome: (json['otherIncome'] as num?)?.toDouble() ?? 0.0,
      totalOtherRevenue: (json['totalOtherRevenue'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      revenueItems: (json['revenueItems'] as List?)
          ?.map((e) => IncomeStatementItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class ExpensesSection {
  final double utilitiesExpense;
  final double rentExpense;
  final double insuranceExpense;
  final double subscriptionExpense;
  final double foodExpense;
  final double transportationExpense;
  final double healthcareExpense;
  final double educationExpense;
  final double entertainmentExpense;
  final double otherOperatingExpenses;
  final double totalOperatingExpenses;
  final double interestExpense;
  final double loanFeesExpense;
  final double totalFinancialExpenses;
  final double totalExpenses;
  final List<IncomeStatementItem> expenseItems;

  ExpensesSection({
    required this.utilitiesExpense,
    required this.rentExpense,
    required this.insuranceExpense,
    required this.subscriptionExpense,
    required this.foodExpense,
    required this.transportationExpense,
    required this.healthcareExpense,
    required this.educationExpense,
    required this.entertainmentExpense,
    required this.otherOperatingExpenses,
    required this.totalOperatingExpenses,
    required this.interestExpense,
    required this.loanFeesExpense,
    required this.totalFinancialExpenses,
    required this.totalExpenses,
    required this.expenseItems,
  });

  factory ExpensesSection.fromJson(Map<String, dynamic> json) {
    return ExpensesSection(
      utilitiesExpense: (json['utilitiesExpense'] as num?)?.toDouble() ?? 0.0,
      rentExpense: (json['rentExpense'] as num?)?.toDouble() ?? 0.0,
      insuranceExpense: (json['insuranceExpense'] as num?)?.toDouble() ?? 0.0,
      subscriptionExpense: (json['subscriptionExpense'] as num?)?.toDouble() ?? 0.0,
      foodExpense: (json['foodExpense'] as num?)?.toDouble() ?? 0.0,
      transportationExpense: (json['transportationExpense'] as num?)?.toDouble() ?? 0.0,
      healthcareExpense: (json['healthcareExpense'] as num?)?.toDouble() ?? 0.0,
      educationExpense: (json['educationExpense'] as num?)?.toDouble() ?? 0.0,
      entertainmentExpense: (json['entertainmentExpense'] as num?)?.toDouble() ?? 0.0,
      otherOperatingExpenses: (json['otherOperatingExpenses'] as num?)?.toDouble() ?? 0.0,
      totalOperatingExpenses: (json['totalOperatingExpenses'] as num?)?.toDouble() ?? 0.0,
      interestExpense: (json['interestExpense'] as num?)?.toDouble() ?? 0.0,
      loanFeesExpense: (json['loanFeesExpense'] as num?)?.toDouble() ?? 0.0,
      totalFinancialExpenses: (json['totalFinancialExpenses'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      expenseItems: (json['expenseItems'] as List?)
          ?.map((e) => IncomeStatementItem.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class IncomeStatementComparison {
  final double previousRevenue;
  final double previousExpenses;
  final double previousNetIncome;
  final double revenueChange;
  final double revenueChangePercentage;
  final double expensesChange;
  final double expensesChangePercentage;
  final double netIncomeChange;
  final double netIncomeChangePercentage;

  IncomeStatementComparison({
    required this.previousRevenue,
    required this.previousExpenses,
    required this.previousNetIncome,
    required this.revenueChange,
    required this.revenueChangePercentage,
    required this.expensesChange,
    required this.expensesChangePercentage,
    required this.netIncomeChange,
    required this.netIncomeChangePercentage,
  });

  factory IncomeStatementComparison.fromJson(Map<String, dynamic> json) {
    return IncomeStatementComparison(
      previousRevenue: (json['previousRevenue'] as num?)?.toDouble() ?? 0.0,
      previousExpenses: (json['previousExpenses'] as num?)?.toDouble() ?? 0.0,
      previousNetIncome: (json['previousNetIncome'] as num?)?.toDouble() ?? 0.0,
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0.0,
      revenueChangePercentage: (json['revenueChangePercentage'] as num?)?.toDouble() ?? 0.0,
      expensesChange: (json['expensesChange'] as num?)?.toDouble() ?? 0.0,
      expensesChangePercentage: (json['expensesChangePercentage'] as num?)?.toDouble() ?? 0.0,
      netIncomeChange: (json['netIncomeChange'] as num?)?.toDouble() ?? 0.0,
      netIncomeChangePercentage: (json['netIncomeChangePercentage'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class IncomeStatement {
  final String periodStart;
  final String periodEnd;
  final String period;
  final RevenueSection revenue;
  final ExpensesSection expenses;
  final double netIncome;
  final IncomeStatementComparison? comparison;

  IncomeStatement({
    required this.periodStart,
    required this.periodEnd,
    required this.period,
    required this.revenue,
    required this.expenses,
    required this.netIncome,
    this.comparison,
  });

  factory IncomeStatement.fromJson(Map<String, dynamic> json) {
    return IncomeStatement(
      periodStart: json['periodStart'] as String? ?? '',
      periodEnd: json['periodEnd'] as String? ?? '',
      period: json['period'] as String? ?? 'MONTHLY',
      revenue: RevenueSection.fromJson(json['revenue'] as Map<String, dynamic>),
      expenses: ExpensesSection.fromJson(json['expenses'] as Map<String, dynamic>),
      netIncome: (json['netIncome'] as num?)?.toDouble() ?? 0.0,
      comparison: json['comparison'] != null
          ? IncomeStatementComparison.fromJson(json['comparison'] as Map<String, dynamic>)
          : null,
    );
  }
}

// Financial Ratios Models
class LiquidityRatios {
  final double currentRatio;
  final String currentRatioInterpretation;
  final double quickRatio;
  final String quickRatioInterpretation;
  final double cashRatio;
  final String cashRatioInterpretation;
  final double currentAssets;
  final double currentLiabilities;
  final double cashAndEquivalents;

  LiquidityRatios({
    required this.currentRatio,
    required this.currentRatioInterpretation,
    required this.quickRatio,
    required this.quickRatioInterpretation,
    required this.cashRatio,
    required this.cashRatioInterpretation,
    required this.currentAssets,
    required this.currentLiabilities,
    required this.cashAndEquivalents,
  });

  factory LiquidityRatios.fromJson(Map<String, dynamic> json) {
    return LiquidityRatios(
      currentRatio: (json['currentRatio'] as num?)?.toDouble() ?? 0.0,
      currentRatioInterpretation: json['currentRatioInterpretation'] as String? ?? '',
      quickRatio: (json['quickRatio'] as num?)?.toDouble() ?? 0.0,
      quickRatioInterpretation: json['quickRatioInterpretation'] as String? ?? '',
      cashRatio: (json['cashRatio'] as num?)?.toDouble() ?? 0.0,
      cashRatioInterpretation: json['cashRatioInterpretation'] as String? ?? '',
      currentAssets: (json['currentAssets'] as num?)?.toDouble() ?? 0.0,
      currentLiabilities: (json['currentLiabilities'] as num?)?.toDouble() ?? 0.0,
      cashAndEquivalents: (json['cashAndEquivalents'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class DebtRatios {
  final double debtToEquityRatio;
  final String debtToEquityInterpretation;
  final double debtToAssetsRatio;
  final String debtToAssetsInterpretation;
  final double debtServiceCoverageRatio;
  final String debtServiceCoverageInterpretation;
  final double totalLiabilities;
  final double totalAssets;
  final double totalEquity;
  final double netIncome;
  final double totalDebtPayments;

  DebtRatios({
    required this.debtToEquityRatio,
    required this.debtToEquityInterpretation,
    required this.debtToAssetsRatio,
    required this.debtToAssetsInterpretation,
    required this.debtServiceCoverageRatio,
    required this.debtServiceCoverageInterpretation,
    required this.totalLiabilities,
    required this.totalAssets,
    required this.totalEquity,
    required this.netIncome,
    required this.totalDebtPayments,
  });

  factory DebtRatios.fromJson(Map<String, dynamic> json) {
    return DebtRatios(
      debtToEquityRatio: (json['debtToEquityRatio'] as num?)?.toDouble() ?? 0.0,
      debtToEquityInterpretation: json['debtToEquityInterpretation'] as String? ?? '',
      debtToAssetsRatio: (json['debtToAssetsRatio'] as num?)?.toDouble() ?? 0.0,
      debtToAssetsInterpretation: json['debtToAssetsInterpretation'] as String? ?? '',
      debtServiceCoverageRatio: (json['debtServiceCoverageRatio'] as num?)?.toDouble() ?? 0.0,
      debtServiceCoverageInterpretation: json['debtServiceCoverageInterpretation'] as String? ?? '',
      totalLiabilities: (json['totalLiabilities'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalEquity: (json['totalEquity'] as num?)?.toDouble() ?? 0.0,
      netIncome: (json['netIncome'] as num?)?.toDouble() ?? 0.0,
      totalDebtPayments: (json['totalDebtPayments'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ProfitabilityRatios {
  final double netProfitMargin;
  final String netProfitMarginInterpretation;
  final double returnOnAssets;
  final String returnOnAssetsInterpretation;
  final double returnOnEquity;
  final String returnOnEquityInterpretation;
  final double netIncome;
  final double totalRevenue;
  final double totalAssets;
  final double totalEquity;

  ProfitabilityRatios({
    required this.netProfitMargin,
    required this.netProfitMarginInterpretation,
    required this.returnOnAssets,
    required this.returnOnAssetsInterpretation,
    required this.returnOnEquity,
    required this.returnOnEquityInterpretation,
    required this.netIncome,
    required this.totalRevenue,
    required this.totalAssets,
    required this.totalEquity,
  });

  factory ProfitabilityRatios.fromJson(Map<String, dynamic> json) {
    return ProfitabilityRatios(
      netProfitMargin: (json['netProfitMargin'] as num?)?.toDouble() ?? 0.0,
      netProfitMarginInterpretation: json['netProfitMarginInterpretation'] as String? ?? '',
      returnOnAssets: (json['returnOnAssets'] as num?)?.toDouble() ?? 0.0,
      returnOnAssetsInterpretation: json['returnOnAssetsInterpretation'] as String? ?? '',
      returnOnEquity: (json['returnOnEquity'] as num?)?.toDouble() ?? 0.0,
      returnOnEquityInterpretation: json['returnOnEquityInterpretation'] as String? ?? '',
      netIncome: (json['netIncome'] as num?)?.toDouble() ?? 0.0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalEquity: (json['totalEquity'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class EfficiencyRatios {
  final double assetTurnover;
  final String assetTurnoverInterpretation;
  final double expenseRatio;
  final String expenseRatioInterpretation;
  final double savingsRate;
  final String savingsRateInterpretation;
  final double totalRevenue;
  final double totalAssets;
  final double totalExpenses;
  final double totalSavings;
  final double totalIncome;

  EfficiencyRatios({
    required this.assetTurnover,
    required this.assetTurnoverInterpretation,
    required this.expenseRatio,
    required this.expenseRatioInterpretation,
    required this.savingsRate,
    required this.savingsRateInterpretation,
    required this.totalRevenue,
    required this.totalAssets,
    required this.totalExpenses,
    required this.totalSavings,
    required this.totalIncome,
  });

  factory EfficiencyRatios.fromJson(Map<String, dynamic> json) {
    return EfficiencyRatios(
      assetTurnover: (json['assetTurnover'] as num?)?.toDouble() ?? 0.0,
      assetTurnoverInterpretation: json['assetTurnoverInterpretation'] as String? ?? '',
      expenseRatio: (json['expenseRatio'] as num?)?.toDouble() ?? 0.0,
      expenseRatioInterpretation: json['expenseRatioInterpretation'] as String? ?? '',
      savingsRate: (json['savingsRate'] as num?)?.toDouble() ?? 0.0,
      savingsRateInterpretation: json['savingsRateInterpretation'] as String? ?? '',
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      totalAssets: (json['totalAssets'] as num?)?.toDouble() ?? 0.0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0.0,
      totalSavings: (json['totalSavings'] as num?)?.toDouble() ?? 0.0,
      totalIncome: (json['totalIncome'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class RatioInsight {
  final String ratioName;
  final double ratioValue;
  final String category;
  final String interpretation;
  final String recommendation;
  final String severity;

  RatioInsight({
    required this.ratioName,
    required this.ratioValue,
    required this.category,
    required this.interpretation,
    required this.recommendation,
    required this.severity,
  });

  factory RatioInsight.fromJson(Map<String, dynamic> json) {
    return RatioInsight(
      ratioName: json['ratioName'] as String? ?? '',
      ratioValue: (json['ratioValue'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? '',
      interpretation: json['interpretation'] as String? ?? '',
      recommendation: json['recommendation'] as String? ?? '',
      severity: json['severity'] as String? ?? 'INFO',
    );
  }
}

class FinancialRatios {
  final String asOfDate;
  final LiquidityRatios liquidity;
  final DebtRatios debt;
  final ProfitabilityRatios profitability;
  final EfficiencyRatios efficiency;
  final List<RatioInsight> insights;

  FinancialRatios({
    required this.asOfDate,
    required this.liquidity,
    required this.debt,
    required this.profitability,
    required this.efficiency,
    required this.insights,
  });

  factory FinancialRatios.fromJson(Map<String, dynamic> json) {
    return FinancialRatios(
      asOfDate: json['asOfDate'] as String? ?? '',
      liquidity: LiquidityRatios.fromJson(json['liquidity'] as Map<String, dynamic>),
      debt: DebtRatios.fromJson(json['debt'] as Map<String, dynamic>),
      profitability: ProfitabilityRatios.fromJson(json['profitability'] as Map<String, dynamic>),
      efficiency: EfficiencyRatios.fromJson(json['efficiency'] as Map<String, dynamic>),
      insights: (json['insights'] as List?)
          ?.map((e) => RatioInsight.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
