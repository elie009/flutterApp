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

