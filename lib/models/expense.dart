import 'package:equatable/equatable.dart';
import '../utils/json_parser.dart';

class Expense extends Equatable {
  final String id;
  final String userId;
  final String description;
  final double amount;
  final String categoryId;
  final String categoryName;
  final DateTime expenseDate;
  final String currency;
  final String? notes;
  final String? merchant;
  final String? paymentMethod;
  final String? bankAccountId;
  final String? location;
  final bool isTaxDeductible;
  final bool isReimbursable;
  final String? reimbursementRequestId;
  final double? mileage;
  final double? mileageRate;
  final double? perDiemAmount;
  final int? numberOfDays;
  final String approvalStatus;
  final String? approvedBy;
  final DateTime? approvedAt;
  final String? approvalNotes;
  final bool hasReceipt;
  final String? receiptId;
  final String? budgetId;
  final bool isRecurring;
  final String? recurringFrequency;
  final String? parentExpenseId;
  final String? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expense({
    required this.id,
    required this.userId,
    required this.description,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.expenseDate,
    this.currency = 'USD',
    this.notes,
    this.merchant,
    this.paymentMethod,
    this.bankAccountId,
    this.location,
    this.isTaxDeductible = false,
    this.isReimbursable = false,
    this.reimbursementRequestId,
    this.mileage,
    this.mileageRate,
    this.perDiemAmount,
    this.numberOfDays,
    this.approvalStatus = 'PENDING_APPROVAL',
    this.approvedBy,
    this.approvedAt,
    this.approvalNotes,
    this.hasReceipt = false,
    this.receiptId,
    this.budgetId,
    this.isRecurring = false,
    this.recurringFrequency,
    this.parentExpenseId,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['userId'] as String,
      description: json['description'] as String,
      amount: JsonParser.parseDoubleRequired(json['amount']),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String? ?? '',
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      currency: json['currency'] as String? ?? 'USD',
      notes: json['notes'] as String?,
      merchant: json['merchant'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      bankAccountId: json['bankAccountId'] as String?,
      location: json['location'] as String?,
      isTaxDeductible: json['isTaxDeductible'] as bool? ?? false,
      isReimbursable: json['isReimbursable'] as bool? ?? false,
      reimbursementRequestId: json['reimbursementRequestId'] as String?,
      mileage: json['mileage'] != null ? (json['mileage'] as num).toDouble() : null,
      mileageRate: json['mileageRate'] != null ? (json['mileageRate'] as num).toDouble() : null,
      perDiemAmount: json['perDiemAmount'] != null ? (json['perDiemAmount'] as num).toDouble() : null,
      numberOfDays: json['numberOfDays'] as int?,
      approvalStatus: json['approvalStatus'] as String? ?? 'PENDING_APPROVAL',
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
      approvalNotes: json['approvalNotes'] as String?,
      hasReceipt: json['hasReceipt'] as bool? ?? false,
      receiptId: json['receiptId'] as String?,
      budgetId: json['budgetId'] as String?,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringFrequency: json['recurringFrequency'] as String?,
      parentExpenseId: json['parentExpenseId'] as String?,
      tags: json['tags'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'description': description,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'expenseDate': expenseDate.toIso8601String(),
      'currency': currency,
      'notes': notes,
      'merchant': merchant,
      'paymentMethod': paymentMethod,
      'bankAccountId': bankAccountId,
      'location': location,
      'isTaxDeductible': isTaxDeductible,
      'isReimbursable': isReimbursable,
      'reimbursementRequestId': reimbursementRequestId,
      'mileage': mileage,
      'mileageRate': mileageRate,
      'perDiemAmount': perDiemAmount,
      'numberOfDays': numberOfDays,
      'approvalStatus': approvalStatus,
      'approvedBy': approvedBy,
      'approvedAt': approvedAt?.toIso8601String(),
      'approvalNotes': approvalNotes,
      'hasReceipt': hasReceipt,
      'receiptId': receiptId,
      'budgetId': budgetId,
      'isRecurring': isRecurring,
      'recurringFrequency': recurringFrequency,
      'parentExpenseId': parentExpenseId,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isApproved => approvalStatus == 'APPROVED';
  bool get isPending => approvalStatus == 'PENDING_APPROVAL';
  bool get isRejected => approvalStatus == 'REJECTED';

  @override
  List<Object?> get props => [
        id,
        userId,
        description,
        amount,
        categoryId,
        categoryName,
        expenseDate,
        currency,
        notes,
        merchant,
        paymentMethod,
        bankAccountId,
        location,
        isTaxDeductible,
        isReimbursable,
        approvalStatus,
        hasReceipt,
        createdAt,
        updatedAt,
      ];
}

class ExpenseCategory extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final double? monthlyBudget;
  final double? yearlyBudget;
  final String? parentCategoryId;
  final String? parentCategoryName;
  final bool isTaxDeductible;
  final String? taxCategory;
  final bool isActive;
  final int displayOrder;
  final int expenseCount;
  final double totalExpenses;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseCategory({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.monthlyBudget,
    this.yearlyBudget,
    this.parentCategoryId,
    this.parentCategoryName,
    this.isTaxDeductible = false,
    this.taxCategory,
    this.isActive = true,
    this.displayOrder = 0,
    this.expenseCount = 0,
    this.totalExpenses = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) {
    return ExpenseCategory(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      monthlyBudget: json['monthlyBudget'] != null ? (json['monthlyBudget'] as num).toDouble() : null,
      yearlyBudget: json['yearlyBudget'] != null ? (json['yearlyBudget'] as num).toDouble() : null,
      parentCategoryId: json['parentCategoryId'] as String?,
      parentCategoryName: json['parentCategoryName'] as String?,
      isTaxDeductible: json['isTaxDeductible'] as bool? ?? false,
      taxCategory: json['taxCategory'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0,
      expenseCount: json['expenseCount'] as int? ?? 0,
      totalExpenses: json['totalExpenses'] != null ? (json['totalExpenses'] as num).toDouble() : 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'monthlyBudget': monthlyBudget,
      'yearlyBudget': yearlyBudget,
      'parentCategoryId': parentCategoryId,
      'parentCategoryName': parentCategoryName,
      'isTaxDeductible': isTaxDeductible,
      'taxCategory': taxCategory,
      'isActive': isActive,
      'displayOrder': displayOrder,
      'expenseCount': expenseCount,
      'totalExpenses': totalExpenses,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        icon,
        color,
        monthlyBudget,
        yearlyBudget,
        isTaxDeductible,
        isActive,
        displayOrder,
      ];
}

class ExpenseBudget extends Equatable {
  final String id;
  final String userId;
  final String categoryId;
  final String categoryName;
  final double budgetAmount;
  final String periodType;
  final DateTime startDate;
  final DateTime endDate;
  final String? notes;
  final double? alertThreshold;
  final bool isActive;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final bool isOverBudget;
  final bool isNearLimit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseBudget({
    required this.id,
    required this.userId,
    required this.categoryId,
    required this.categoryName,
    required this.budgetAmount,
    required this.periodType,
    required this.startDate,
    required this.endDate,
    this.notes,
    this.alertThreshold,
    this.isActive = true,
    this.spentAmount = 0,
    this.remainingAmount = 0,
    this.percentageUsed = 0,
    this.isOverBudget = false,
    this.isNearLimit = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseBudget.fromJson(Map<String, dynamic> json) {
    return ExpenseBudget(
      id: json['id'] as String,
      userId: json['userId'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String? ?? '',
      budgetAmount: JsonParser.parseDoubleRequired(json['budgetAmount']),
      periodType: json['periodType'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      notes: json['notes'] as String?,
      alertThreshold: json['alertThreshold'] != null ? (json['alertThreshold'] as num).toDouble() : null,
      isActive: json['isActive'] as bool? ?? true,
      spentAmount: json['spentAmount'] != null ? (json['spentAmount'] as num).toDouble() : 0,
      remainingAmount: json['remainingAmount'] != null ? (json['remainingAmount'] as num).toDouble() : 0,
      percentageUsed: json['percentageUsed'] != null ? (json['percentageUsed'] as num).toDouble() : 0,
      isOverBudget: json['isOverBudget'] as bool? ?? false,
      isNearLimit: json['isNearLimit'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'budgetAmount': budgetAmount,
      'periodType': periodType,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'notes': notes,
      'alertThreshold': alertThreshold,
      'isActive': isActive,
      'spentAmount': spentAmount,
      'remainingAmount': remainingAmount,
      'percentageUsed': percentageUsed,
      'isOverBudget': isOverBudget,
      'isNearLimit': isNearLimit,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        categoryId,
        categoryName,
        budgetAmount,
        periodType,
        startDate,
        endDate,
        isActive,
        spentAmount,
        remainingAmount,
        percentageUsed,
      ];
}

class ExpenseReceipt extends Equatable {
  final String id;
  final String userId;
  final String? expenseId;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final String? originalFileName;
  final double? extractedAmount;
  final DateTime? extractedDate;
  final String? extractedMerchant;
  final String? extractedItems;
  final String? ocrText;
  final bool isOcrProcessed;
  final DateTime? ocrProcessedAt;
  final String? thumbnailPath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseReceipt({
    required this.id,
    required this.userId,
    this.expenseId,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    this.originalFileName,
    this.extractedAmount,
    this.extractedDate,
    this.extractedMerchant,
    this.extractedItems,
    this.ocrText,
    this.isOcrProcessed = false,
    this.ocrProcessedAt,
    this.thumbnailPath,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseReceipt.fromJson(Map<String, dynamic> json) {
    return ExpenseReceipt(
      id: json['id'] as String,
      userId: json['userId'] as String,
      expenseId: json['expenseId'] as String?,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      originalFileName: json['originalFileName'] as String?,
      extractedAmount: json['extractedAmount'] != null ? (json['extractedAmount'] as num).toDouble() : null,
      extractedDate: json['extractedDate'] != null ? DateTime.parse(json['extractedDate'] as String) : null,
      extractedMerchant: json['extractedMerchant'] as String?,
      extractedItems: json['extractedItems'] as String?,
      ocrText: json['ocrText'] as String?,
      isOcrProcessed: json['isOcrProcessed'] as bool? ?? false,
      ocrProcessedAt: json['ocrProcessedAt'] != null ? DateTime.parse(json['ocrProcessedAt'] as String) : null,
      thumbnailPath: json['thumbnailPath'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'expenseId': expenseId,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'originalFileName': originalFileName,
      'extractedAmount': extractedAmount,
      'extractedDate': extractedDate?.toIso8601String(),
      'extractedMerchant': extractedMerchant,
      'extractedItems': extractedItems,
      'ocrText': ocrText,
      'isOcrProcessed': isOcrProcessed,
      'ocrProcessedAt': ocrProcessedAt?.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        expenseId,
        fileName,
        filePath,
        fileType,
        fileSize,
      ];
}

class ExpenseApproval extends Equatable {
  final String id;
  final String expenseId;
  final String requestedBy;
  final String? approvedBy;
  final String status; // PENDING, APPROVED, REJECTED
  final String? notes;
  final String? rejectionReason;
  final DateTime requestedAt;
  final DateTime? reviewedAt;
  final int approvalLevel;
  final String? nextApproverId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ExpenseApproval({
    required this.id,
    required this.expenseId,
    required this.requestedBy,
    this.approvedBy,
    required this.status,
    this.notes,
    this.rejectionReason,
    required this.requestedAt,
    this.reviewedAt,
    this.approvalLevel = 1,
    this.nextApproverId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenseApproval.fromJson(Map<String, dynamic> json) {
    return ExpenseApproval(
      id: json['id'] as String,
      expenseId: json['expenseId'] as String,
      requestedBy: json['requestedBy'] as String,
      approvedBy: json['approvedBy'] as String?,
      status: json['status'] as String? ?? 'PENDING',
      notes: json['notes'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
      approvalLevel: json['approvalLevel'] as int? ?? 1,
      nextApproverId: json['nextApproverId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'expenseId': expenseId,
      'requestedBy': requestedBy,
      'approvedBy': approvedBy,
      'status': status,
      'notes': notes,
      'rejectionReason': rejectionReason,
      'requestedAt': requestedAt.toIso8601String(),
      'reviewedAt': reviewedAt?.toIso8601String(),
      'approvalLevel': approvalLevel,
      'nextApproverId': nextApproverId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  bool get isPending => status == 'PENDING';
  bool get isApproved => status == 'APPROVED';
  bool get isRejected => status == 'REJECTED';

  @override
  List<Object?> get props => [
        id,
        expenseId,
        requestedBy,
        approvedBy,
        status,
        notes,
        rejectionReason,
      ];
}

