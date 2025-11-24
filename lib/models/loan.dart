import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class Loan extends Equatable {
  final String id;
  final double principal;
  final double interestRate;
  final int term; // in months
  final String status; // 'PENDING', 'APPROVED', 'ACTIVE', 'COMPLETED'
  final double monthlyPayment;
  final double remainingBalance;
  final DateTime? nextDueDate;
  final String? purpose;
  final DateTime appliedAt;
  // New fields for enhanced loan management
  final String? loanType; // PERSONAL, MORTGAGE, AUTO, STUDENT, etc.
  final String? refinancedFromLoanId;
  final String? refinancedToLoanId;
  final DateTime? refinancingDate;
  final double? effectiveInterestRate;
  final double? totalInterest;
  final double? downPayment;
  final double? processingFee;
  final double? actualFinancedAmount;
  final String? interestComputationMethod;
  final String? paymentFrequency;
  final DateTime? startDate;

  const Loan({
    required this.id,
    required this.principal,
    required this.interestRate,
    required this.term,
    required this.status,
    required this.monthlyPayment,
    required this.remainingBalance,
    this.nextDueDate,
    this.purpose,
    required this.appliedAt,
    this.loanType,
    this.refinancedFromLoanId,
    this.refinancedToLoanId,
    this.refinancingDate,
    this.effectiveInterestRate,
    this.totalInterest,
    this.downPayment,
    this.processingFee,
    this.actualFinancedAmount,
    this.interestComputationMethod,
    this.paymentFrequency,
    this.startDate,
  });

  factory Loan.fromJson(Map<String, dynamic> json) {
    return Loan(
      id: json['id'] as String,
      principal: JsonParser.parseDoubleRequired(json['principal']),
      interestRate: JsonParser.parseDoubleRequired(json['interestRate']),
      term: JsonParser.parseIntRequired(json['term']),
      status: JsonParser.parseString(json['status']),
      monthlyPayment: JsonParser.parseDoubleRequired(json['monthlyPayment']),
      remainingBalance: JsonParser.parseDoubleRequired(json['remainingBalance']),
      nextDueDate: json['nextDueDate'] != null
          ? DateTime.parse(json['nextDueDate'] as String)
          : null,
      purpose: json['purpose'] as String?,
      appliedAt: DateTime.parse(json['appliedAt'] as String),
      loanType: json['loanType'] as String?,
      refinancedFromLoanId: json['refinancedFromLoanId'] as String?,
      refinancedToLoanId: json['refinancedToLoanId'] as String?,
      refinancingDate: json['refinancingDate'] != null
          ? DateTime.parse(json['refinancingDate'] as String)
          : null,
      effectiveInterestRate: json['effectiveInterestRate'] != null
          ? (json['effectiveInterestRate'] as num).toDouble()
          : null,
      totalInterest: json['totalInterest'] != null
          ? (json['totalInterest'] as num).toDouble()
          : null,
      downPayment: json['downPayment'] != null
          ? (json['downPayment'] as num).toDouble()
          : null,
      processingFee: json['processingFee'] != null
          ? (json['processingFee'] as num).toDouble()
          : null,
      actualFinancedAmount: json['actualFinancedAmount'] != null
          ? (json['actualFinancedAmount'] as num).toDouble()
          : null,
      interestComputationMethod: json['interestComputationMethod'] as String?,
      paymentFrequency: json['paymentFrequency'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'principal': principal,
      'interestRate': interestRate,
      'term': term,
      'status': status,
      'monthlyPayment': monthlyPayment,
      'remainingBalance': remainingBalance,
      'nextDueDate': nextDueDate?.toIso8601String(),
      'purpose': purpose,
      'appliedAt': appliedAt.toIso8601String(),
      'loanType': loanType,
      'refinancedFromLoanId': refinancedFromLoanId,
      'refinancedToLoanId': refinancedToLoanId,
      'refinancingDate': refinancingDate?.toIso8601String(),
      'effectiveInterestRate': effectiveInterestRate,
      'totalInterest': totalInterest,
      'downPayment': downPayment,
      'processingFee': processingFee,
      'actualFinancedAmount': actualFinancedAmount,
      'interestComputationMethod': interestComputationMethod,
      'paymentFrequency': paymentFrequency,
      'startDate': startDate?.toIso8601String(),
    };
  }

  bool get isActive => status == 'ACTIVE';
  bool get isPending => status == 'PENDING' || status == 'APPROVED';
  bool get isCompleted => status == 'COMPLETED';

  @override
  List<Object?> get props => [
        id,
        principal,
        interestRate,
        term,
        status,
        monthlyPayment,
        remainingBalance,
        nextDueDate,
        purpose,
        appliedAt,
      ];
}

