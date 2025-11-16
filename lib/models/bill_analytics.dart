class BillAnalytics {
  final double totalPendingAmount;
  final double totalPaidAmount;
  final double totalOverdueAmount;
  final int totalPendingBills;
  final int totalPaidBills;
  final int totalOverdueBills;
  final DateTime generatedAt;

  const BillAnalytics({
    required this.totalPendingAmount,
    required this.totalPaidAmount,
    required this.totalOverdueAmount,
    required this.totalPendingBills,
    required this.totalPaidBills,
    required this.totalOverdueBills,
    required this.generatedAt,
  });

  factory BillAnalytics.fromJson(Map<String, dynamic> json) {
    return BillAnalytics(
      totalPendingAmount: (json['totalPendingAmount'] as num?)?.toDouble() ?? 0.0,
      totalPaidAmount: (json['totalPaidAmount'] as num?)?.toDouble() ?? 0.0,
      totalOverdueAmount: (json['totalOverdueAmount'] as num?)?.toDouble() ?? 0.0,
      totalPendingBills: (json['totalPendingBills'] as num?)?.toInt() ?? 0,
      totalPaidBills: (json['totalPaidBills'] as num?)?.toInt() ?? 0,
      totalOverdueBills: (json['totalOverdueBills'] as num?)?.toInt() ?? 0,
      generatedAt: json['generatedAt'] != null 
          ? DateTime.parse(json['generatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalPendingAmount': totalPendingAmount,
      'totalPaidAmount': totalPaidAmount,
      'totalOverdueAmount': totalOverdueAmount,
      'totalPendingBills': totalPendingBills,
      'totalPaidBills': totalPaidBills,
      'totalOverdueBills': totalOverdueBills,
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}




