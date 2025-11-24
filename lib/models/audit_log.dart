class AuditLog {
  final String id;
  final String userId;
  final String? userEmail;
  final String action;
  final String entityType;
  final String? entityId;
  final String? entityName;
  final String logType; // USER_ACTIVITY, SYSTEM_EVENT, SECURITY_EVENT, COMPLIANCE_EVENT
  final String? severity; // INFO, WARNING, ERROR, CRITICAL
  final String description;
  final Map<String, dynamic>? oldValues;
  final Map<String, dynamic>? newValues;
  final String? ipAddress;
  final String? userAgent;
  final String? requestMethod;
  final String? requestPath;
  final String? requestId;
  final String? complianceType; // SOX, GDPR, HIPAA, etc.
  final String? category;
  final String? subCategory;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    required this.userId,
    this.userEmail,
    required this.action,
    required this.entityType,
    this.entityId,
    this.entityName,
    required this.logType,
    this.severity,
    required this.description,
    this.oldValues,
    this.newValues,
    this.ipAddress,
    this.userAgent,
    this.requestMethod,
    this.requestPath,
    this.requestId,
    this.complianceType,
    this.category,
    this.subCategory,
    this.metadata,
    required this.createdAt,
  });

  factory AuditLog.fromJson(Map<String, dynamic> json) {
    return AuditLog(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'],
      action: json['action'] ?? '',
      entityType: json['entityType'] ?? '',
      entityId: json['entityId'],
      entityName: json['entityName'],
      logType: json['logType'] ?? '',
      severity: json['severity'],
      description: json['description'] ?? '',
      oldValues: json['oldValues'] != null
          ? Map<String, dynamic>.from(json['oldValues'])
          : null,
      newValues: json['newValues'] != null
          ? Map<String, dynamic>.from(json['newValues'])
          : null,
      ipAddress: json['ipAddress'],
      userAgent: json['userAgent'],
      requestMethod: json['requestMethod'],
      requestPath: json['requestPath'],
      requestId: json['requestId'],
      complianceType: json['complianceType'],
      category: json['category'],
      subCategory: json['subCategory'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userEmail': userEmail,
      'action': action,
      'entityType': entityType,
      'entityId': entityId,
      'entityName': entityName,
      'logType': logType,
      'severity': severity,
      'description': description,
      'oldValues': oldValues,
      'newValues': newValues,
      'ipAddress': ipAddress,
      'userAgent': userAgent,
      'requestMethod': requestMethod,
      'requestPath': requestPath,
      'requestId': requestId,
      'complianceType': complianceType,
      'category': category,
      'subCategory': subCategory,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class AuditLogQuery {
  final String? userId;
  final String? action;
  final String? entityType;
  final String? entityId;
  final String? logType;
  final String? severity;
  final String? complianceType;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchTerm;
  final int page;
  final int pageSize;
  final String? sortBy;
  final String? sortOrder; // ASC or DESC

  AuditLogQuery({
    this.userId,
    this.action,
    this.entityType,
    this.entityId,
    this.logType,
    this.severity,
    this.complianceType,
    this.category,
    this.startDate,
    this.endDate,
    this.searchTerm,
    this.page = 1,
    this.pageSize = 50,
    this.sortBy = 'CreatedAt',
    this.sortOrder = 'DESC',
  });

  Map<String, dynamic> toQueryParams() {
    final params = <String, dynamic>{
      'page': page,
      'pageSize': pageSize,
      'sortBy': sortBy ?? 'CreatedAt',
      'sortOrder': sortOrder ?? 'DESC',
    };

    if (userId != null) params['userId'] = userId;
    if (action != null) params['action'] = action;
    if (entityType != null) params['entityType'] = entityType;
    if (entityId != null) params['entityId'] = entityId;
    if (logType != null) params['logType'] = logType;
    if (severity != null) params['severity'] = severity;
    if (complianceType != null) params['complianceType'] = complianceType;
    if (category != null) params['category'] = category;
    if (startDate != null) params['startDate'] = startDate!.toIso8601String();
    if (endDate != null) params['endDate'] = endDate!.toIso8601String();
    if (searchTerm != null && searchTerm!.isNotEmpty) {
      params['searchTerm'] = searchTerm;
    }

    return params;
  }
}

class PaginatedAuditLogs {
  final List<AuditLog> logs;
  final int totalCount;
  final int page;
  final int pageSize;
  final int totalPages;

  PaginatedAuditLogs({
    required this.logs,
    required this.totalCount,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  factory PaginatedAuditLogs.fromJson(Map<String, dynamic> json) {
    return PaginatedAuditLogs(
      logs: (json['logs'] as List<dynamic>?)
              ?.map((e) => AuditLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalCount: json['totalCount'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['pageSize'] ?? 50,
      totalPages: json['totalPages'] ?? 0,
    );
  }
}

class AuditLogSummary {
  final int totalLogs;
  final int userActivityLogs;
  final int systemEventLogs;
  final int securityEventLogs;
  final int complianceEventLogs;
  final Map<String, int> logsByAction;
  final Map<String, int> logsByEntityType;
  final Map<String, int> logsBySeverity;
  final Map<String, int> logsByComplianceType;

  AuditLogSummary({
    required this.totalLogs,
    required this.userActivityLogs,
    required this.systemEventLogs,
    required this.securityEventLogs,
    required this.complianceEventLogs,
    required this.logsByAction,
    required this.logsByEntityType,
    required this.logsBySeverity,
    required this.logsByComplianceType,
  });

  factory AuditLogSummary.fromJson(Map<String, dynamic> json) {
    return AuditLogSummary(
      totalLogs: json['totalLogs'] ?? 0,
      userActivityLogs: json['userActivityLogs'] ?? 0,
      systemEventLogs: json['systemEventLogs'] ?? 0,
      securityEventLogs: json['securityEventLogs'] ?? 0,
      complianceEventLogs: json['complianceEventLogs'] ?? 0,
      logsByAction: json['logsByAction'] != null
          ? Map<String, int>.from(
              (json['logsByAction'] as Map).map((k, v) => MapEntry(k.toString(), v as int)))
          : {},
      logsByEntityType: json['logsByEntityType'] != null
          ? Map<String, int>.from((json['logsByEntityType'] as Map)
              .map((k, v) => MapEntry(k.toString(), v as int)))
          : {},
      logsBySeverity: json['logsBySeverity'] != null
          ? Map<String, int>.from((json['logsBySeverity'] as Map)
              .map((k, v) => MapEntry(k.toString(), v as int)))
          : {},
      logsByComplianceType: json['logsByComplianceType'] != null
          ? Map<String, int>.from((json['logsByComplianceType'] as Map)
              .map((k, v) => MapEntry(k.toString(), v as int)))
          : {},
    );
  }
}

