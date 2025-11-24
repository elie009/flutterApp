class Receipt {
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
  final List<ReceiptItem>? extractedItems;
  final String? ocrText;
  final bool isOcrProcessed;
  final DateTime? ocrProcessedAt;
  final String? thumbnailPath;
  final String? notes;
  final String? fileUrl;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  Receipt({
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
    required this.isOcrProcessed,
    this.ocrProcessedAt,
    this.thumbnailPath,
    this.notes,
    this.fileUrl,
    this.thumbnailUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'] as String,
      userId: json['userId'] as String,
      expenseId: json['expenseId'] as String?,
      fileName: json['fileName'] as String,
      filePath: json['filePath'] as String,
      fileType: json['fileType'] as String,
      fileSize: json['fileSize'] as int,
      originalFileName: json['originalFileName'] as String?,
      extractedAmount: json['extractedAmount'] != null
          ? (json['extractedAmount'] as num).toDouble()
          : null,
      extractedDate: json['extractedDate'] != null
          ? DateTime.parse(json['extractedDate'] as String)
          : null,
      extractedMerchant: json['extractedMerchant'] as String?,
      extractedItems: json['extractedItems'] != null
          ? (json['extractedItems'] as List)
              .map((item) => ReceiptItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      ocrText: json['ocrText'] as String?,
      isOcrProcessed: json['isOcrProcessed'] as bool,
      ocrProcessedAt: json['ocrProcessedAt'] != null
          ? DateTime.parse(json['ocrProcessedAt'] as String)
          : null,
      thumbnailPath: json['thumbnailPath'] as String?,
      notes: json['notes'] as String?,
      fileUrl: json['fileUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
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
      'extractedItems': extractedItems?.map((item) => item.toJson()).toList(),
      'ocrText': ocrText,
      'isOcrProcessed': isOcrProcessed,
      'ocrProcessedAt': ocrProcessedAt?.toIso8601String(),
      'thumbnailPath': thumbnailPath,
      'notes': notes,
      'fileUrl': fileUrl,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReceiptItem {
  final String description;
  final double? price;
  final int? quantity;

  ReceiptItem({
    required this.description,
    this.price,
    this.quantity,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      description: json['description'] as String,
      price: json['price'] != null ? (json['price'] as num).toDouble() : null,
      quantity: json['quantity'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'price': price,
      'quantity': quantity,
    };
  }
}

class ExpenseMatch {
  final String expenseId;
  final String description;
  final double amount;
  final DateTime expenseDate;
  final String? merchant;
  final String category;
  final double matchScore;
  final String matchReason;

  ExpenseMatch({
    required this.expenseId,
    required this.description,
    required this.amount,
    required this.expenseDate,
    this.merchant,
    required this.category,
    required this.matchScore,
    required this.matchReason,
  });

  factory ExpenseMatch.fromJson(Map<String, dynamic> json) {
    return ExpenseMatch(
      expenseId: json['expenseId'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      expenseDate: DateTime.parse(json['expenseDate'] as String),
      merchant: json['merchant'] as String?,
      category: json['category'] as String,
      matchScore: (json['matchScore'] as num).toDouble(),
      matchReason: json['matchReason'] as String,
    );
  }
}

