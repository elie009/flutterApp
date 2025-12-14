import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  final String id;
  final String type; // 'PAYMENT_DUE', 'BILL_OVERDUE', 'LOAN_APPROVED', etc.
  final String title;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? templateVariables; // Contains billId, loanId, etc.

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.templateVariables,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      templateVariables: json['templateVariables'] != null
          ? Map<String, dynamic>.from(json['templateVariables'] as Map)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'message': message,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
      if (templateVariables != null) 'templateVariables': templateVariables,
    };
  }

  @override
  List<Object?> get props => [
        id,
        type,
        title,
        message,
        isRead,
        createdAt,
        templateVariables,
      ];
}

