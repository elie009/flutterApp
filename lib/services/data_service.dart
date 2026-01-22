import 'package:flutter/foundation.dart';
import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/loan.dart';
import '../models/income_source.dart';
import '../models/bank_account.dart';
import '../models/notification.dart';
import '../models/dashboard_summary.dart';
import '../models/transaction_category.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'dart:convert';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  // Recent Activity
  Future<Map<String, dynamic>> getRecentActivity() async {
    try {
      final response = await ApiService().get('/Dashboard/recent-activity');
      
      if (response.data['success'] == true && response.data['data'] != null) {
        return response.data['data'] as Map<String, dynamic>;
      }
      
      throw Exception('Failed to get recent activity');
    } catch (e) {
      rethrow;
    }
  }

  // Dashboard Summary
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      // Try cache first
      final cached = StorageService.getCache(AppConfig.cacheDashboard);
      if (cached != null) {
        // Could check timestamp here for expiry
      }

      // Get total balance from the new endpoint
      debugPrint('📊 getDashboardSummary: Fetching total balance from /BankAccounts/total-balance');
      final balanceResponse = await ApiService().get('/BankAccounts/total-balance');
      debugPrint('📊 getDashboardSummary: Got response: ${balanceResponse.data}');
      
      // Get recent transactions (handle 404 gracefully)
      List<Transaction> transactions = [];
      try {
        final transactionsResponse = await ApiService().get(
          '/Transactions',
          queryParameters: {'limit': 5},
        );
        final transactionsData = transactionsResponse.data['data'] as List<dynamic>? ?? [];
        transactions = transactionsData
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ getDashboardSummary: Transactions API error (ignoring): $e');
        // Continue without transactions
      }

      // Parse and combine data
      final totalBalance = (balanceResponse.data['data'] as num?)?.toDouble() ?? 0.0;
      debugPrint('📊 getDashboardSummary: Parsed total balance: \$$totalBalance');
      final monthlyIncome = 0.0; // Removed from old endpoint
      
      // Bill analytics removed - set to defaults
      final pendingBillsCount = 0;
      final pendingBillsAmount = 0.0;

      // Get upcoming bills (next 7 days) - handle errors gracefully
      List<Bill> upcomingBills = [];
      try {
        final upcomingBillsResponse = await ApiService().get(
          '/Bills/upcoming',
          queryParameters: {'days': 7},
        );
        final billsData = upcomingBillsResponse.data['data'] as List<dynamic>? ?? [];
        upcomingBills = billsData
            .map((e) => Bill.fromJson(e as Map<String, dynamic>))
            .toList();
      } catch (e) {
        debugPrint('⚠️ getDashboardSummary: Bills API error (ignoring): $e');
        // Continue without bills
      }

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
        'page': page,
        'limit': limit,
        if (transactionType != null) 'transactionType': transactionType,
        if (category != null) 'category': category,
        if (dateFrom != null) 'dateFrom': dateFrom,
        if (dateTo != null) 'dateTo': dateTo,
      };

      final response = await ApiService().get(
        '/Transactions',
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
      final response = await ApiService().get('/Bills/summary');
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

  // Get total balance across all accounts (excluding credit cards)
  Future<double> getTotalBalance() async {
    try {
      debugPrint('📊 Fetching total balance from /BankAccounts/total-balance');
      
      final response = await ApiService().get('/BankAccounts/total-balance');
      
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        
        if (data != null) {
          double totalBalance = 0.0;
          
          // Handle different data types
          if (data is num) {
            totalBalance = data.toDouble();
          } else if (data is String) {
            totalBalance = double.tryParse(data) ?? 0.0;
          }
          
          debugPrint('📊 Total Balance: \$${totalBalance.toStringAsFixed(2)}');
          return totalBalance;
        }
      }
      
      debugPrint('⚠️ No data returned from total balance API');
      return 0.0;
    } catch (e) {
      debugPrint('❌ Error getting total balance: $e');
      return 0.0;
    }
  }

  // Get total debt from credit card accounts
  Future<double> getTotalDebt() async {
    try {
      final response = await ApiService().get('/BankAccounts/total-debt');
      
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          if (data is num) {
            return data.toDouble();
          } else if (data is String) {
            final parsed = double.tryParse(data);
            if (parsed != null) return parsed;
          }
        }
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('Error getting total debt: $e');
      return 0.0;
    }
  }

  // Get savings goals progress percentage
  Future<double> getSavingsProgress() async {
    try {
      final response = await ApiService().get('/Savings/progress');
      
      if (response.data != null && response.data['success'] == true) {
        final data = response.data['data'];
        if (data != null) {
          if (data is num) {
            // Convert percentage (0-100) to decimal (0.0-1.0) for CircularProgressIndicator
            return (data.toDouble() / 100.0).clamp(0.0, 1.0);
          } else if (data is String) {
            final parsed = double.tryParse(data);
            if (parsed != null) return (parsed / 100.0).clamp(0.0, 1.0);
          }
        }
      }
      
      return 0.0;
    } catch (e) {
      debugPrint('Error getting savings progress: $e');
      return 0.0;
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
      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
        if (type != null) 'type': type,
      };

      final response = await ApiService().get(
        '/Notifications/user/$userId',
        queryParameters: queryParams,
      );

      // Handle the API response structure: { success: true, data: { data: [...], page: 1, ... } }
      final responseData = response.data['data'] as Map<String, dynamic>?;
      if (responseData == null) {
        return [];
      }

      final notificationsData = responseData['data'] as List<dynamic>? ?? [];
      return notificationsData
          .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getUnreadNotificationCount() async {
    try {
      final userId = AuthService.getCurrentUser()?.id ?? '';
      if (userId.isEmpty) {
        return 0;
      }

      final response = await ApiService().get(
        '/Notifications/user/$userId/unread-count',
      );

      final count = response.data['data'] as int? ?? 0;
      return count;
    } catch (e) {
      // Fallback: count unread from getNotifications
      try {
        final notifications = await getNotifications(status: 'unread', limit: 100);
        return notifications.where((n) => !n.isRead).length;
      } catch (e) {
        return 0;
      }
    }
  }

  Future<bool> markNotificationAsRead(String notificationId) async {
    try {
      final response = await ApiService().put('/Notifications/$notificationId/read');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Categories
  Future<List<dynamic>> getCategories({String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type;
      }

      final response = await ApiService().get(
        '/categories',
        queryParameters: queryParams.isEmpty ? null : queryParams,
        timeout: AppConfig.categoriesApiTimeout,
      );

      final data = response.data['data'] as List<dynamic>? ?? 
                   (response.data is List ? response.data as List<dynamic> : []);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  // Transaction Categories
  Future<List<TransactionCategory>> getTransactionCategories({String? type}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null) {
        queryParams['type'] = type;
      }
      
      final response = await ApiService().get(
        '/Categories',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
      
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) {
        return [];
      }
      
      return data.map((e) => TransactionCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteTransactionCategory(String categoryId) async {
    try {
      final response = await ApiService().delete('/Categories/$categoryId');
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

