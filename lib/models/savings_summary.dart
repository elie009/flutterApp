import 'savings_account.dart';

class SavingsSummary {
  final int totalSavingsAccounts;
  final double totalSavingsBalance;
  final double totalTargetAmount;
  final double overallProgressPercentage;
  final int activeGoals;
  final int completedGoals;
  final double monthlySavingsTarget;
  final double thisMonthSaved;
  final List<SavingsAccount> recentAccounts;

  const SavingsSummary({
    required this.totalSavingsAccounts,
    required this.totalSavingsBalance,
    required this.totalTargetAmount,
    required this.overallProgressPercentage,
    required this.activeGoals,
    required this.completedGoals,
    required this.monthlySavingsTarget,
    required this.thisMonthSaved,
    this.recentAccounts = const [],
  });

  factory SavingsSummary.fromJson(Map<String, dynamic> json) {
    final recent = json['recentAccounts'] as List<dynamic>? ?? [];
    return SavingsSummary(
      totalSavingsAccounts: json['totalSavingsAccounts'] as int? ?? 0,
      totalSavingsBalance: (json['totalSavingsBalance'] as num?)?.toDouble() ?? 0,
      totalTargetAmount: (json['totalTargetAmount'] as num?)?.toDouble() ?? 0,
      overallProgressPercentage: (json['overallProgressPercentage'] as num?)?.toDouble() ?? 0,
      activeGoals: json['activeGoals'] as int? ?? 0,
      completedGoals: json['completedGoals'] as int? ?? 0,
      monthlySavingsTarget: (json['monthlySavingsTarget'] as num?)?.toDouble() ?? 0,
      thisMonthSaved: (json['thisMonthSaved'] as num?)?.toDouble() ?? 0,
      recentAccounts: recent
          .map((e) => SavingsAccount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
