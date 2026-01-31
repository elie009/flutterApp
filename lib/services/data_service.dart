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
          '/bankaccounts/transactions/recent',
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

  // Transactions - GET api/BankAccounts/transactions
  Future<List<Transaction>> getTransactions({
    int page = 1,
    int limit = 50,
    String? bankAccountId,
    String? accountType,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (bankAccountId != null && bankAccountId.isNotEmpty) 'bankAccountId': bankAccountId,
        if (accountType != null && accountType.isNotEmpty) 'accountType': accountType,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
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

  // Create Transaction - POST api/BankAccounts/transactions
  Future<Transaction> createTransaction({
    required String bankAccountId,
    required double amount,
    required String transactionType, // 'CREDIT' or 'DEBIT'
    required String description,
    String? category,
    String? referenceNumber,
    String? externalTransactionId,
    DateTime? transactionDate,
    String? notes,
    String? merchant,
    String? location,
    bool isRecurring = false,
    String? recurringFrequency,
    String currency = 'USD',
    String? billId,
    String? savingsAccountId,
    String? loanId,
    String? investmentId,
    String? transactionPurpose,
    String? toBankAccountId, // For transfers
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'bankAccountId': bankAccountId,
        'amount': amount,
        'transactionType': transactionType.toUpperCase(),
        'description': description,
        'currency': currency,
        'transactionDate': (transactionDate ?? DateTime.now()).toIso8601String(),
        'isRecurring': isRecurring,
        if (category != null && category.isNotEmpty) 'category': category,
        if (referenceNumber != null && referenceNumber.isNotEmpty) 'referenceNumber': referenceNumber,
        if (externalTransactionId != null && externalTransactionId.isNotEmpty) 'externalTransactionId': externalTransactionId,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
        if (merchant != null && merchant.isNotEmpty) 'merchant': merchant,
        if (location != null && location.isNotEmpty) 'location': location,
        if (recurringFrequency != null && recurringFrequency.isNotEmpty) 'recurringFrequency': recurringFrequency,
        if (billId != null && billId.isNotEmpty) 'billId': billId,
        if (savingsAccountId != null && savingsAccountId.isNotEmpty) 'savingsAccountId': savingsAccountId,
        if (loanId != null && loanId.isNotEmpty) 'loanId': loanId,
        if (investmentId != null && investmentId.isNotEmpty) 'investmentId': investmentId,
        if (transactionPurpose != null && transactionPurpose.isNotEmpty) 'transactionPurpose': transactionPurpose,
        if (toBankAccountId != null && toBankAccountId.isNotEmpty) 'toBankAccountId': toBankAccountId,
      };

      final response = await ApiService().post(
        '/BankAccounts/transactions',
        data: requestBody,
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        return Transaction.fromJson(response.data['data'] as Map<String, dynamic>);
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create transaction');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Analyze transaction text (e.g. SMS/notification) and create a bank transaction.
  /// Calls POST /api/BankAccounts/transactions/analyze-text
  Future<Transaction> analyzeTransactionText({
    required String transactionText,
    String? bankAccountId,
    String? billId,
    String? loanId,
    String? savingsAccountId,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'transactionText': transactionText.trim(),
        if (bankAccountId != null && bankAccountId.isNotEmpty)
          'bankAccountId': bankAccountId,
        if (billId != null && billId.isNotEmpty) 'billId': billId,
        if (loanId != null && loanId.isNotEmpty) 'loanId': loanId,
        if (savingsAccountId != null && savingsAccountId.isNotEmpty)
          'savingsAccountId': savingsAccountId,
      };

      final response = await ApiService().post(
        '/BankAccounts/transactions/analyze-text',
        data: requestBody,
      );

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }
      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';
      final transactionData = data['data'];

      if (!success) {
        throw Exception(message);
      }
      if (transactionData == null) {
        throw Exception('No transaction data in response');
      }
      final map = transactionData is Map<String, dynamic>
          ? transactionData
          : Map<String, dynamic>.from(transactionData as Map);
      return Transaction.fromJson(map);
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

  /// Create a bill. POST /api/Bills. Request body: CreateBillDto.
  Future<Bill> createBill({
    required String billName,
    required String billType,
    required double amount,
    required DateTime dueDate,
    required String frequency,
    DateTime? statementDate,
    String? notes,
    String? provider,
    String? referenceNumber,
    bool autoGenerateNext = false,
    bool isScheduledPayment = false,
    String? scheduledPaymentBankAccountId,
    int? scheduledPaymentDaysBeforeDue,
  }) async {
    try {
      final requestBody = <String, dynamic>{
        'billName': billName.trim(),
        'billType': billType.trim(),
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'frequency': frequency,
        if (statementDate != null)
          'statementDate': statementDate.toIso8601String(),
        if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
        if (provider != null && provider.trim().isNotEmpty) 'provider': provider.trim(),
        if (referenceNumber != null && referenceNumber.trim().isNotEmpty)
          'referenceNumber': referenceNumber.trim(),
        'autoGenerateNext': autoGenerateNext,
        'isScheduledPayment': isScheduledPayment,
        if (scheduledPaymentBankAccountId != null &&
            scheduledPaymentBankAccountId.trim().isNotEmpty)
          'scheduledPaymentBankAccountId': scheduledPaymentBankAccountId.trim(),
        if (scheduledPaymentDaysBeforeDue != null)
          'scheduledPaymentDaysBeforeDue': scheduledPaymentDaysBeforeDue,
      };

      final response = await ApiService().post('/Bills', data: requestBody);

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid response from server');
      }
      final success = data['success'] as bool? ?? false;
      final message = data['message'] as String? ?? 'Unknown error';
      final billData = data['data'];

      if (!success) {
        throw Exception(message);
      }
      if (billData == null) {
        throw Exception('No bill data in response');
      }
      final map = billData is Map<String, dynamic>
          ? billData
          : Map<String, dynamic>.from(billData as Map);
      return Bill.fromJson(map);
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
      if (userId.isEmpty) return [];

      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (status != null) 'status': status,
      };

      final response = await ApiService().get(
        '/Loans/user/$userId',
        queryParameters: queryParams,
        timeout: const Duration(seconds: 15),
      );

      final rawData = response.data;
      if (rawData is! Map<String, dynamic>) return [];

      final data = rawData['data'];
      List<dynamic> list;
      if (data is List<dynamic>) {
        list = data;
      } else if (data is Map<String, dynamic> && data['data'] is List<dynamic>) {
        list = data['data'] as List<dynamic>;
      } else {
        list = [];
      }

      return list.map((e) {
        if (e is! Map<String, dynamic>) return null;
        try {
          return Loan.fromJson(e);
        } catch (_) {
          return null;
        }
      }).whereType<Loan>().toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get a single loan by id. Uses GET /Loans/{loanId} (NOT /Loans/user/...).
  Future<Loan> getLoan(String loanId) async {
    try {
      // Build path without "user" - single loan endpoint is /Loans/{loanId} only.
      const prefix = '/Loans/';
      final path = prefix + loanId;
      if (path.contains('user')) {
        debugPrint('ERROR getLoan: path must not contain "user". Got: $path');
        throw StateError('getLoan must call GET /Loans/{id}, not /Loans/user/...');
      }
      if (kDebugMode) debugPrint('getLoan: GET $path');
      final response = await ApiService().get(path);
      return Loan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  /// Update loan (PUT /Loans/{loanId}). Returns updated loan or throws.
  Future<Loan> updateLoan(
    String loanId, {
    String? purpose,
    String? additionalInfo,
    String? status,
    double? principal,
    double? interestRate,
    double? monthlyPayment,
    double? remainingBalance,
  }) async {
    final response = await ApiService().put(
      '/Loans/$loanId',
      data: {
        if (purpose != null) 'purpose': purpose,
        if (additionalInfo != null) 'additionalInfo': additionalInfo,
        if (status != null) 'status': status,
        if (principal != null) 'principal': principal,
        if (interestRate != null) 'interestRate': interestRate,
        if (monthlyPayment != null) 'monthlyPayment': monthlyPayment,
        if (remainingBalance != null) 'remainingBalance': remainingBalance,
      },
    );
    final raw = response.data;
    if (raw is! Map<String, dynamic>) throw Exception('Invalid response');
    final success = raw['success'] == true;
    final data = raw['data'];
    if (!success || data == null) {
      final msg = raw['message'] as String? ?? 'Failed to update loan';
      throw Exception(msg);
    }
    return Loan.fromJson(data as Map<String, dynamic>);
  }

  /// Apply for a loan (POST /Loans/apply). Returns the created loan or throws.
  Future<Loan> applyForLoan({
    required double principal,
    required String purpose,
    required int termMonths,
    double interestRate = 0,
    String loanType = 'PERSONAL',
    String? additionalInfo,
    double? monthlyIncome,
    String? employmentStatus,
  }) async {
    final response = await ApiService().post(
      '/Loans/apply',
      data: {
        'principal': principal,
        'interestRate': interestRate,
        'purpose': purpose,
        'term': termMonths,
        'loanType': loanType,
        if (additionalInfo != null && additionalInfo.isNotEmpty) 'additionalInfo': additionalInfo,
        if (monthlyIncome != null) 'monthlyIncome': monthlyIncome,
        if (employmentStatus != null) 'employmentStatus': employmentStatus,
      },
    );
    final raw = response.data;
    if (raw is! Map<String, dynamic>) throw Exception('Invalid response');
    final success = raw['success'] == true;
    final data = raw['data'];
    if (!success || data == null) {
      final msg = raw['message'] as String? ?? 'Failed to apply for loan';
      throw Exception(msg);
    }
    return Loan.fromJson(data as Map<String, dynamic>);
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

