import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/loan.dart';
import '../models/income_source.dart';
import '../models/bank_account.dart';
import '../models/notification.dart';
import '../models/dashboard_summary.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'dart:convert';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Helper methods to parse values that might be strings or numbers
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    if (value is num) return value.toDouble();
    return null;
  }

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is num) return value.toInt();
    return null;
  }

  // Dashboard Summary
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      // Try cache first
      final cached = StorageService.getCache(AppConfig.cacheDashboard);
      if (cached != null) {
        // Could check timestamp here for expiry
      }

      final response = await ApiService().get('/BankAccounts/summary');
      
      // Also get bill analytics
      final billResponse = await ApiService().get('/Bills/analytics/summary');
      
      // Get recent transactions
      final transactionsResponse = await ApiService().get(
        '/BankAccounts/transactions',
        queryParameters: {'limit': 5},
      );

      // Parse and combine data
      final totalBalance = _parseDouble(response.data['totalBalance']) ?? 0.0;
      final monthlyIncome = _parseDouble(response.data['monthlyIncome']) ?? 0.0;
      
      final pendingBillsCount = _parseInt(billResponse.data['pendingCount']) ?? 0;
      final pendingBillsAmount = _parseDouble(billResponse.data['pendingAmount']) ?? 0.0;
      
      final transactions = (transactionsResponse.data['data'] as List<dynamic>?)
          ?.map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      // Get upcoming bills (next 7 days)
      final upcomingBillsResponse = await ApiService().get(
        '/Bills/upcoming',
        queryParameters: {'days': 7},
      );
      final upcomingBills = (upcomingBillsResponse.data['data'] as List<dynamic>?)
          ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      final summary = DashboardSummary(
        totalBalance: totalBalance,
        monthlyIncome: monthlyIncome,
        pendingBillsCount: pendingBillsCount,
        pendingBillsAmount: pendingBillsAmount,
        upcomingPayments: upcomingBills,
        recentTransactions: transactions,
      );

      // Cache the result
      await StorageService.saveCache(
        AppConfig.cacheDashboard,
        jsonEncode(summary.toJson()),
      );

      return summary;
    } catch (e) {
      rethrow;
    }
  }

  // Transactions
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 50,
    String? transactionType,
    String? category,
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        if (transactionType != null) 'transactionType': transactionType,
        if (category != null) 'category': category,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final response = await ApiService().get(
        '/BankAccounts/transactions',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Bills
  Future<Map<String, dynamic>> getBills({
    String? status,
    int page = 1,
    int limit = 20,
    String? provider,
    String? billType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (provider != null) 'provider': provider,
        if (billType != null) 'billType': billType,
      };

      final response = await ApiService().get(
        '/Bills',
        queryParameters: queryParams,
      );

      final billsData = response.data['data'] as Map<String, dynamic>;
      final bills = (billsData['bills'] as List<dynamic>?)
          ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'bills': bills,
        'pagination': billsData['pagination'],
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Bill> getBill(String billId) async {
    try {
      final response = await ApiService().get('/Bills/$billId');
      return Bill.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markBillAsPaid(String billId, {String? notes}) async {
    try {
      final response = await ApiService().put(
        '/Bills/$billId/status',
        data: {
          'status': 'PAID',
          if (notes != null) 'notes': notes,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Bill>> getOverdueBills() async {
    try {
      final response = await ApiService().get('/Bills/overdue');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Bill>> getUpcomingBills({int days = 7}) async {
    try {
      final response = await ApiService().get(
        '/Bills/upcoming',
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Loans
  Future<List<Loan>> getUserLoans({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id ?? '';
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await ApiService().get(
        '/Loans/user/$userId',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Loan> getLoan(String loanId) async {
    try {
      final response = await ApiService().get('/Loans/user/$loanId');
      return Loan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> makeLoanPayment({
    required String loanId,
    required double amount,
    required String method,
    String? reference,
  }) async {
    try {
      final response = await ApiService().post(
        '/payments',
        data: {
          'loanId': loanId,
          'amount': amount,
          'method': method,
          if (reference != null) 'reference': reference,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Income Sources
  Future<Map<String, dynamic>> getIncomeSources({bool includeSummary = true}) async {
    try {
      final response = await ApiService().get(
        '/IncomeSources',
        queryParameters: {'includeSummary': includeSummary},
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final incomeSources = (data['incomeSources'] as List<dynamic>?)
          ?.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'incomeSources': incomeSources,
        'totalMonthlyIncome': data['totalMonthlyIncome'] as double? ?? 0.0,
        'totalSources': data['totalSources'] as int? ?? 0,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeSource> createIncomeSource(IncomeSource incomeSource) async {
    try {
      final response = await ApiService().post(
        '/IncomeSources',
        data: incomeSource.toJson(),
      );
      return IncomeSource.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeSource> updateIncomeSource(String id, IncomeSource incomeSource) async {
    try {
      final response = await ApiService().put(
        '/IncomeSources/$id',
        data: incomeSource.toJson(),
      );
      return IncomeSource.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteIncomeSource(String id) async {
    try {
      final response = await ApiService().delete('/IncomeSources/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Bank Accounts
  Future<List<BankAccount>> getBankAccounts({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }

      final response = await ApiService().get(
        '/BankAccounts',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBankAccountsSummary() async {
    try {
      final response = await ApiService().get('/BankAccounts/summary');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Notifications
  Future<List<AppNotification>> getNotifications({
    String? status,
    String? type,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final userId = AuthService.getCurrentUser()?.id ?? '';
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      };

      final response = await ApiService().get(
        '/notifications/$userId',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await ApiService().put('/notifications/$notificationId/read');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }
}

// Add toJson method to DashboardSummary for caching
extension DashboardSummaryExtension on DashboardSummary {
  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'monthlyIncome': monthlyIncome,
      'pendingBillsCount': pendingBillsCount,
      'pendingBillsAmount': pendingBillsAmount,
      'upcomingPayments': upcomingPayments.map((e) => e.toJson()).toList(),
      'recentTransactions': recentTransactions.map((e) => e.toJson()).toList(),
    };
  }
}

