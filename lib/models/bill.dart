import 'package:equatable/equatable.dart';

class Bill extends Equatable {
  final String id;
  final String billName;
  final double amount;
  final DateTime dueDate;
  final String status; // 'PENDING', 'PAID', 'OVERDUE'
  final String? provider;
  final String? billType; // 'UTILITY', 'INSURANCE', etc.
  final String? frequency; // 'MONTHLY', 'WEEKLY', etc.
  final String? notes;

  const Bill({
    required this.id,
    required this.billName,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.provider,
    this.billType,
    this.frequency,
    this.notes,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] as String,
      billName: json['billName'] as String,
      amount: (json['amount'] as num).toDouble(),
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: json['status'] as String,
      provider: json['provider'] as String?,
      billType: json['billType'] as String?,
      frequency: json['frequency'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'billName': billName,
      'amount': amount,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'provider': provider,
      'billType': billType,
      'frequency': frequency,
      'notes': notes,
    };
  }

  bool get isOverdue => status == 'OVERDUE' || 
      (status == 'PENDING' && dueDate.isBefore(DateTime.now()));
  bool get isPending => status == 'PENDING' && !isOverdue;
  bool get isPaid => status == 'PAID';

  @override
  List<Object?> get props => [
        id,
        billName,
        amount,
        dueDate,
        status,
        provider,
        billType,
        frequency,
        notes,
      ];
}

