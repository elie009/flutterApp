class TransactionCategory {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String type; // EXPENSE, INCOME, TRANSFER, BILL, SAVINGS, LOAN
  final String? icon;
  final String? color;
  final bool isSystemCategory;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int transactionCount;

  TransactionCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    required this.type,
    this.icon,
    this.color,
    required this.isSystemCategory,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
    required this.updatedAt,
    this.transactionCount = 0,
  });

  factory TransactionCategory.fromJson(Map<String, dynamic> json) {
    return TransactionCategory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String? ?? 'EXPENSE',
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      isSystemCategory: json['isSystemCategory'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      transactionCount: json['transactionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'type': type,
      'icon': icon,
      'color': color,
      'isSystemCategory': isSystemCategory,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'transactionCount': transactionCount,
    };
  }
}


