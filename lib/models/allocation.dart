class AllocationTemplate {
  final String id;
  final String name;
  final String? description;
  final bool isSystemTemplate;
  final bool isActive;
  final List<AllocationTemplateCategory> categories;
  final DateTime createdAt;
  final DateTime updatedAt;

  AllocationTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.isSystemTemplate,
    required this.isActive,
    required this.categories,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllocationTemplate.fromJson(Map<String, dynamic> json) {
    return AllocationTemplate(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      isSystemTemplate: json['isSystemTemplate'] ?? false,
      isActive: json['isActive'] ?? true,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((c) => AllocationTemplateCategory.fromJson(c))
          .toList() ?? [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'isSystemTemplate': isSystemTemplate,
      'isActive': isActive,
      'categories': categories.map((c) => c.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AllocationTemplateCategory {
  final String id;
  final String categoryName;
  final String? description;
  final double percentage;
  final int displayOrder;
  final String? color;

  AllocationTemplateCategory({
    required this.id,
    required this.categoryName,
    this.description,
    required this.percentage,
    required this.displayOrder,
    this.color,
  });

  factory AllocationTemplateCategory.fromJson(Map<String, dynamic> json) {
    return AllocationTemplateCategory(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      percentage: (json['percentage'] ?? 0).toDouble(),
      displayOrder: json['displayOrder'] ?? 0,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
      'percentage': percentage,
      'displayOrder': displayOrder,
      'color': color,
    };
  }
}

class AllocationPlan {
  final String id;
  final String userId;
  final String? templateId;
  final String? templateName;
  final String planName;
  final double monthlyIncome;
  final bool isActive;
  final DateTime startDate;
  final DateTime? endDate;
  final List<AllocationCategory> categories;
  final AllocationSummary summary;
  final DateTime createdAt;
  final DateTime updatedAt;

  AllocationPlan({
    required this.id,
    required this.userId,
    this.templateId,
    this.templateName,
    required this.planName,
    required this.monthlyIncome,
    required this.isActive,
    required this.startDate,
    this.endDate,
    required this.categories,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AllocationPlan.fromJson(Map<String, dynamic> json) {
    return AllocationPlan(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      templateId: json['templateId'],
      templateName: json['templateName'],
      planName: json['planName'] ?? '',
      monthlyIncome: (json['monthlyIncome'] ?? 0).toDouble(),
      isActive: json['isActive'] ?? true,
      startDate: DateTime.parse(json['startDate'] ?? DateTime.now().toIso8601String()),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      categories: (json['categories'] as List<dynamic>?)
          ?.map((c) => AllocationCategory.fromJson(c))
          .toList() ?? [],
      summary: json['summary'] != null
          ? AllocationSummary.fromJson(json['summary'])
          : AllocationSummary.empty(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'templateId': templateId,
      'templateName': templateName,
      'planName': planName,
      'monthlyIncome': monthlyIncome,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'summary': summary.toJson(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class AllocationCategory {
  final String id;
  final String categoryName;
  final String? description;
  final double allocatedAmount;
  final double percentage;
  final double actualAmount;
  final double variance;
  final double variancePercentage;
  final String status;
  final int displayOrder;
  final String? color;

  AllocationCategory({
    required this.id,
    required this.categoryName,
    this.description,
    required this.allocatedAmount,
    required this.percentage,
    required this.actualAmount,
    required this.variance,
    required this.variancePercentage,
    required this.status,
    required this.displayOrder,
    this.color,
  });

  factory AllocationCategory.fromJson(Map<String, dynamic> json) {
    return AllocationCategory(
      id: json['id'] ?? '',
      categoryName: json['categoryName'] ?? '',
      description: json['description'],
      allocatedAmount: (json['allocatedAmount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      variance: (json['variance'] ?? 0).toDouble(),
      variancePercentage: (json['variancePercentage'] ?? 0).toDouble(),
      status: json['status'] ?? 'on_track',
      displayOrder: json['displayOrder'] ?? 0,
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryName': categoryName,
      'description': description,
      'allocatedAmount': allocatedAmount,
      'percentage': percentage,
      'actualAmount': actualAmount,
      'variance': variance,
      'variancePercentage': variancePercentage,
      'status': status,
      'displayOrder': displayOrder,
      'color': color,
    };
  }
}

class AllocationSummary {
  final double totalAllocated;
  final double totalActual;
  final double totalVariance;
  final double surplusDeficit;
  final double allocationPercentage;

  AllocationSummary({
    required this.totalAllocated,
    required this.totalActual,
    required this.totalVariance,
    required this.surplusDeficit,
    required this.allocationPercentage,
  });

  factory AllocationSummary.fromJson(Map<String, dynamic> json) {
    return AllocationSummary(
      totalAllocated: (json['totalAllocated'] ?? 0).toDouble(),
      totalActual: (json['totalActual'] ?? 0).toDouble(),
      totalVariance: (json['totalVariance'] ?? 0).toDouble(),
      surplusDeficit: (json['surplusDeficit'] ?? 0).toDouble(),
      allocationPercentage: (json['allocationPercentage'] ?? 0).toDouble(),
    );
  }

  factory AllocationSummary.empty() {
    return AllocationSummary(
      totalAllocated: 0,
      totalActual: 0,
      totalVariance: 0,
      surplusDeficit: 0,
      allocationPercentage: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAllocated': totalAllocated,
      'totalActual': totalActual,
      'totalVariance': totalVariance,
      'surplusDeficit': surplusDeficit,
      'allocationPercentage': allocationPercentage,
    };
  }
}

class AllocationHistory {
  final String id;
  final String planId;
  final String? categoryId;
  final String? categoryName;
  final DateTime periodDate;
  final double allocatedAmount;
  final double actualAmount;
  final double variance;
  final double variancePercentage;
  final String status;
  final DateTime createdAt;

  AllocationHistory({
    required this.id,
    required this.planId,
    this.categoryId,
    this.categoryName,
    required this.periodDate,
    required this.allocatedAmount,
    required this.actualAmount,
    required this.variance,
    required this.variancePercentage,
    required this.status,
    required this.createdAt,
  });

  factory AllocationHistory.fromJson(Map<String, dynamic> json) {
    return AllocationHistory(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      periodDate: DateTime.parse(json['periodDate'] ?? DateTime.now().toIso8601String()),
      allocatedAmount: (json['allocatedAmount'] ?? 0).toDouble(),
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      variance: (json['variance'] ?? 0).toDouble(),
      variancePercentage: (json['variancePercentage'] ?? 0).toDouble(),
      status: json['status'] ?? 'on_track',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'periodDate': periodDate.toIso8601String(),
      'allocatedAmount': allocatedAmount,
      'actualAmount': actualAmount,
      'variance': variance,
      'variancePercentage': variancePercentage,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AllocationRecommendation {
  final String id;
  final String planId;
  final String recommendationType;
  final String title;
  final String message;
  final String? categoryId;
  final String? categoryName;
  final double? suggestedAmount;
  final double? suggestedPercentage;
  final String priority;
  final bool isRead;
  final bool isApplied;
  final DateTime createdAt;
  final DateTime? appliedAt;

  AllocationRecommendation({
    required this.id,
    required this.planId,
    required this.recommendationType,
    required this.title,
    required this.message,
    this.categoryId,
    this.categoryName,
    this.suggestedAmount,
    this.suggestedPercentage,
    required this.priority,
    required this.isRead,
    required this.isApplied,
    required this.createdAt,
    this.appliedAt,
  });

  factory AllocationRecommendation.fromJson(Map<String, dynamic> json) {
    return AllocationRecommendation(
      id: json['id'] ?? '',
      planId: json['planId'] ?? '',
      recommendationType: json['recommendationType'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      categoryId: json['categoryId'],
      categoryName: json['categoryName'],
      suggestedAmount: json['suggestedAmount']?.toDouble(),
      suggestedPercentage: json['suggestedPercentage']?.toDouble(),
      priority: json['priority'] ?? 'medium',
      isRead: json['isRead'] ?? false,
      isApplied: json['isApplied'] ?? false,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      appliedAt: json['appliedAt'] != null ? DateTime.parse(json['appliedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'planId': planId,
      'recommendationType': recommendationType,
      'title': title,
      'message': message,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'suggestedAmount': suggestedAmount,
      'suggestedPercentage': suggestedPercentage,
      'priority': priority,
      'isRead': isRead,
      'isApplied': isApplied,
      'createdAt': createdAt.toIso8601String(),
      'appliedAt': appliedAt?.toIso8601String(),
    };
  }
}

class AllocationChartData {
  final List<AllocationChartDataPoint> dataPoints;
  final double totalIncome;
  final double totalAllocated;
  final double surplusDeficit;

  AllocationChartData({
    required this.dataPoints,
    required this.totalIncome,
    required this.totalAllocated,
    required this.surplusDeficit,
  });

  factory AllocationChartData.fromJson(Map<String, dynamic> json) {
    return AllocationChartData(
      dataPoints: (json['dataPoints'] as List<dynamic>?)
          ?.map((d) => AllocationChartDataPoint.fromJson(d))
          .toList() ?? [],
      totalIncome: (json['totalIncome'] ?? 0).toDouble(),
      totalAllocated: (json['totalAllocated'] ?? 0).toDouble(),
      surplusDeficit: (json['surplusDeficit'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dataPoints': dataPoints.map((d) => d.toJson()).toList(),
      'totalIncome': totalIncome,
      'totalAllocated': totalAllocated,
      'surplusDeficit': surplusDeficit,
    };
  }
}

class AllocationChartDataPoint {
  final String categoryName;
  final double allocatedAmount;
  final double actualAmount;
  final double percentage;
  final String? color;

  AllocationChartDataPoint({
    required this.categoryName,
    required this.allocatedAmount,
    required this.actualAmount,
    required this.percentage,
    this.color,
  });

  factory AllocationChartDataPoint.fromJson(Map<String, dynamic> json) {
    return AllocationChartDataPoint(
      categoryName: json['categoryName'] ?? '',
      allocatedAmount: (json['allocatedAmount'] ?? 0).toDouble(),
      actualAmount: (json['actualAmount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
      color: json['color'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryName': categoryName,
      'allocatedAmount': allocatedAmount,
      'actualAmount': actualAmount,
      'percentage': percentage,
      'color': color,
    };
  }
}

