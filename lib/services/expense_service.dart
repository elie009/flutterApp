import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../models/expense.dart';
import 'api_service.dart';

class ExpenseService {
  final ApiService _apiService = ApiService();
  final String _basePath = '/api/Expenses';

  // Expense CRUD Operations
  Future<List<Expense>> getExpenses({
    DateTime? startDate,
    DateTime? endDate,
    String? categoryId,
    String? approvalStatus,
    double? minAmount,
    double? maxAmount,
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'pageSize': pageSize,
      };
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (approvalStatus != null) queryParams['approvalStatus'] = approvalStatus;
      if (minAmount != null) queryParams['minAmount'] = minAmount;
      if (maxAmount != null) queryParams['maxAmount'] = maxAmount;

      final response = await _apiService.get(
        _basePath,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final data = response.data['data'];
        if (data is Map && data['data'] != null) {
          final expensesList = data['data'] as List;
          return expensesList.map((json) => Expense.fromJson(json)).toList();
        } else if (data is List) {
          return data.map((json) => Expense.fromJson(json)).toList();
        }
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get expenses: $e');
    }
  }

  Future<Expense> getExpense(String expenseId) async {
    try {
      final response = await _apiService.get('$_basePath/$expenseId');
      if (response.data['success'] == true && response.data['data'] != null) {
        return Expense.fromJson(response.data['data']);
      }
      throw Exception('Expense not found');
    } catch (e) {
      throw Exception('Failed to get expense: $e');
    }
  }

  Future<Expense> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await _apiService.post(_basePath, data: expenseData);
      if (response.data['success'] == true && response.data['data'] != null) {
        return Expense.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create expense');
    } catch (e) {
      throw Exception('Failed to create expense: $e');
    }
  }

  Future<Expense> updateExpense(String expenseId, Map<String, dynamic> expenseData) async {
    try {
      final response = await _apiService.put('$_basePath/$expenseId', data: expenseData);
      if (response.data['success'] == true && response.data['data'] != null) {
        return Expense.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to update expense');
    } catch (e) {
      throw Exception('Failed to update expense: $e');
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    try {
      final response = await _apiService.delete('$_basePath/$expenseId');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete expense: $e');
    }
  }

  // Category Operations
  Future<List<ExpenseCategory>> getCategories({bool includeInactive = false}) async {
    try {
      final response = await _apiService.get(
        '$_basePath/categories',
        queryParameters: {'includeInactive': includeInactive},
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        final categoriesList = response.data['data'] as List;
        return categoriesList.map((json) => ExpenseCategory.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get categories: $e');
    }
  }

  Future<ExpenseCategory> createCategory(Map<String, dynamic> categoryData) async {
    try {
      final response = await _apiService.post('$_basePath/categories', data: categoryData);
      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseCategory.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create category');
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  // Budget Operations
  Future<List<ExpenseBudget>> getBudgets({String? categoryId, bool includeInactive = false}) async {
    try {
      final queryParams = <String, dynamic>{'includeInactive': includeInactive};
      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final response = await _apiService.get(
        '$_basePath/budgets',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        final budgetsList = response.data['data'] as List;
        return budgetsList.map((json) => ExpenseBudget.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get budgets: $e');
    }
  }

  Future<ExpenseBudget> createBudget(Map<String, dynamic> budgetData) async {
    try {
      final response = await _apiService.post('$_basePath/budgets', data: budgetData);
      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseBudget.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to create budget');
    } catch (e) {
      throw Exception('Failed to create budget: $e');
    }
  }

  // Analytics
  Future<double> getTotalExpenses({DateTime? startDate, DateTime? endDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _apiService.get(
        '$_basePath/analytics/total',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return (response.data['data'] as num).toDouble();
      }
      return 0.0;
    } catch (e) {
      throw Exception('Failed to get total expenses: $e');
    }
  }

  // Receipt Operations
  Future<ExpenseReceipt> uploadReceipt(String expenseId, String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
      });

      final response = await _apiService.dio.post(
        '$_basePath/$expenseId/receipts',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseReceipt.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to upload receipt');
    } catch (e) {
      throw Exception('Failed to upload receipt: $e');
    }
  }

  Future<List<ExpenseReceipt>> getExpenseReceipts(String expenseId) async {
    try {
      final response = await _apiService.get('$_basePath/$expenseId/receipts');
      if (response.data['success'] == true && response.data['data'] != null) {
        final receiptsList = response.data['data'] as List;
        return receiptsList.map((json) => ExpenseReceipt.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get receipts: $e');
    }
  }

  Future<bool> deleteReceipt(String receiptId) async {
    try {
      final response = await _apiService.delete('$_basePath/receipts/$receiptId');
      return response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to delete receipt: $e');
    }
  }

  // Approval Workflow Operations
  Future<ExpenseApproval> submitForApproval(String expenseId, {String? notes}) async {
    try {
      final response = await _apiService.post(
        '$_basePath/approvals/submit',
        data: {
          'expenseId': expenseId,
          'notes': notes,
        },
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseApproval.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to submit for approval');
    } catch (e) {
      throw Exception('Failed to submit for approval: $e');
    }
  }

  Future<ExpenseApproval> approveExpense(String approvalId, {String? notes}) async {
    try {
      final response = await _apiService.post(
        '$_basePath/approvals/approve',
        data: {
          'approvalId': approvalId,
          'notes': notes,
        },
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseApproval.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to approve expense');
    } catch (e) {
      throw Exception('Failed to approve expense: $e');
    }
  }

  Future<ExpenseApproval> rejectExpense(String approvalId, String rejectionReason, {String? notes}) async {
    try {
      final response = await _apiService.post(
        '$_basePath/approvals/reject',
        data: {
          'approvalId': approvalId,
          'rejectionReason': rejectionReason,
          'notes': notes,
        },
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return ExpenseApproval.fromJson(response.data['data']);
      }
      throw Exception(response.data['message'] ?? 'Failed to reject expense');
    } catch (e) {
      throw Exception('Failed to reject expense: $e');
    }
  }

  Future<List<ExpenseApproval>> getPendingApprovals() async {
    try {
      final response = await _apiService.get('$_basePath/approvals/pending');
      if (response.data['success'] == true && response.data['data'] != null) {
        final approvalsList = response.data['data'] as List;
        return approvalsList.map((json) => ExpenseApproval.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get pending approvals: $e');
    }
  }

  Future<List<ExpenseApproval>> getApprovalHistory(String expenseId) async {
    try {
      final response = await _apiService.get('$_basePath/$expenseId/approvals');
      if (response.data['success'] == true && response.data['data'] != null) {
        final approvalsList = response.data['data'] as List;
        return approvalsList.map((json) => ExpenseApproval.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get approval history: $e');
    }
  }

  // Reporting Operations
  Future<Map<String, dynamic>> getExpenseReport({
    required DateTime startDate,
    required DateTime endDate,
    String? categoryId,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };
      if (categoryId != null) queryParams['categoryId'] = categoryId;

      final response = await _apiService.get(
        '$_basePath/reports',
        queryParameters: queryParams,
      );
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception(response.data['message'] ?? 'Failed to get expense report');
    } catch (e) {
      throw Exception('Failed to get expense report: $e');
    }
  }
}

