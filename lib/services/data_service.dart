import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/bill_analytics.dart';
import '../models/loan.dart';
import '../models/income_source.dart';
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';
import '../models/notification.dart';
import '../models/dashboard_summary.dart';
import '../models/savings_account.dart';
import '../models/savings_transaction.dart';
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

      // Get bank accounts summary for totalBalance
      final response = await ApiService().get('/BankAccounts/summary');
      
      // Parse totalBalance from the response
      final responseData = response.data['data'] ?? response.data;
      final totalBalance = _parseDouble(responseData['totalBalance']) ?? 0.0;
      final totalIncoming = _parseDouble(responseData['totalIncoming']) ?? 0.0;
      final totalOutgoing = _parseDouble(responseData['totalOutgoing']) ?? 0.0;
      
      // Also get bill analytics
      final billResponse = await ApiService().get('/Bills/analytics/summary');
      
      // Get recent transactions
      final transactionsResponse = await ApiService().get(
        '/BankAccounts/transactions',
        queryParameters: {'limit': 5},
      );

      // Parse bill analytics data
      final monthlyIncome = _parseDouble(responseData['monthlyIncome']) ?? 0.0;
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

      // Get disposable amount (expenses) for current year and month
      final now = DateTime.now();
      final disposableResponse = await ApiService().get(
        '/Dashboard/disposable-amount',
        queryParameters: {
          'year': now.year,
          'month': now.month,
        },
      );
      
      // Parse expense data
      final disposableData = disposableResponse.data['data'] ?? disposableResponse.data;
      // Try both camelCase and PascalCase for field names
      final totalFixedExpenses = _parseDouble(disposableData['totalFixedExpenses']) ?? 
                                  _parseDouble(disposableData['TotalFixedExpenses']) ?? 0.0;
      final totalVariableExpenses = _parseDouble(disposableData['totalVariableExpenses']) ?? 
                                     _parseDouble(disposableData['TotalVariableExpenses']) ?? 0.0;
      final remainingPercentage = _parseDouble(disposableData['remainingPercentage']) ?? 
                                   _parseDouble(disposableData['RemainingPercentage']) ?? 0.0;
      final remainingDisposableAmount = _parseDouble(disposableData['remainingDisposableAmount']) ?? 
                                        _parseDouble(disposableData['RemainingDisposableAmount']) ?? 0.0;

      // Get savings summary
      final savingsResponse = await ApiService().get('/Savings/summary');
      final savingsData = savingsResponse.data['data'] ?? savingsResponse.data;
      final totalSavings = _parseDouble(savingsData['totalSavings']) ?? 0.0;

      final summary = DashboardSummary(
        totalBalance: totalBalance,
        monthlyIncome: monthlyIncome,
        pendingBillsCount: pendingBillsCount,
        pendingBillsAmount: pendingBillsAmount,
        upcomingPayments: upcomingBills,
        recentTransactions: transactions,
        totalFixedExpenses: totalFixedExpenses,
        totalVariableExpenses: totalVariableExpenses,
        remainingPercentage: remainingPercentage,
        remainingDisposableAmount: remainingDisposableAmount,
        totalSavings: totalSavings,
        totalIncoming: totalIncoming,
        totalOutgoing: totalOutgoing,
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
    String? accountType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
        if (accountType != null) 'accountType': accountType,
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

      // Handle both paginated response and direct list response
      final responseData = response.data['data'];
      List<Bill> bills = [];
      Map<String, dynamic>? pagination;

      if (responseData is Map<String, dynamic>) {
        // Check if it's a paginated response with 'data' and pagination keys
        if (responseData.containsKey('data') && responseData.containsKey('page')) {
          // Paginated format: { data: [...], page: 1, limit: 20, totalCount: 5, ... }
          bills = (responseData['data'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ?? [];
          pagination = {
            'page': responseData['page'],
            'limit': responseData['limit'],
            'totalCount': responseData['totalCount'],
            'totalPages': responseData['totalPages'],
            'hasNextPage': responseData['hasNextPage'],
            'hasPreviousPage': responseData['hasPreviousPage'],
          };
        } else if (responseData.containsKey('data') && responseData.containsKey('pagination')) {
          // Alternative format with nested pagination object
          bills = (responseData['data'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ?? [];
          pagination = responseData['pagination'] as Map<String, dynamic>?;
        } else if (responseData.containsKey('bills') && responseData.containsKey('pagination')) {
          // Legacy format with 'bills' key
          bills = (responseData['bills'] as List<dynamic>?)
              ?.map((e) => Bill.fromJson(e as Map<String, dynamic>))
              .toList() ?? [];
          pagination = responseData['pagination'] as Map<String, dynamic>?;
        } else {
          // Single bill object - shouldn't happen but handle gracefully
          bills = [];
          pagination = null;
        }
      } else if (responseData is List) {
        // Direct list response
        bills = responseData.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
        pagination = null;
      }

      return {
        'bills': bills,
        'pagination': pagination,
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

  // Create bill
  Future<Bill> createBill(Map<String, dynamic> billData) async {
    try {
      final response = await ApiService().post('/Bills', data: billData);
      return Bill.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Update bill
  Future<Bill> updateBill(String billId, Map<String, dynamic> billData) async {
    try {
      final response = await ApiService().put('/Bills/$billId', data: billData);
      return Bill.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Delete bill
  Future<bool> deleteBill(String billId) async {
    try {
      final response = await ApiService().delete('/Bills/$billId');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Get bill analytics summary
  Future<BillAnalytics> getBillAnalyticsSummary() async {
    try {
      final response = await ApiService().get('/Bills/analytics/summary');
      return BillAnalytics.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get total pending amount
  Future<double> getTotalPendingAmount() async {
    try {
      final response = await ApiService().get('/Bills/analytics/total-pending');
      return (response.data['data'] as num?)?.toDouble() ?? 0.0;
    } catch (e) {
      rethrow;
    }
  }

  // Get bills for specific month
  Future<List<Bill>> getBillsForMonth({
    required int year,
    required int month,
    String? provider,
    String? billType,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'year': year,
        'month': month,
        if (provider != null) 'provider': provider,
        if (billType != null) 'billType': billType,
      };

      final response = await ApiService().get(
        '/Bills/monthly',
        queryParameters: queryParams,
      );
      
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Bill.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Quick update monthly bill
  Future<Bill> updateMonthlyBill(String billId, {
    double? amount,
    String? notes,
    String? status,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (amount != null) payload['amount'] = amount;
      if (notes != null) payload['notes'] = notes;
      if (status != null) payload['status'] = status;

      final response = await ApiService().put(
        '/Bills/$billId/monthly',
        data: payload,
      );
      return Bill.fromJson(response.data['data'] as Map<String, dynamic>);
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

      // Handle both paginated response and direct list response
      final responseData = response.data['data'];
      if (responseData is Map<String, dynamic>) {
        // Paginated response - the loans array is in 'data' key
        final loans = (responseData['data'] as List<dynamic>?)
            ?.map((e) => Loan.fromJson(e as Map<String, dynamic>))
            .toList() ?? [];
        return loans;
      } else if (responseData is List) {
        // Direct list response
        return responseData.map((e) => Loan.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Loan> getLoan(String loanId) async {
    try {
      final response = await ApiService().get('/Loans/$loanId');
      return Loan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Loan> updateLoan({
    required String loanId,
    String? purpose,
    String? additionalInfo,
    String? status,
    double? interestRate,
    double? monthlyPayment,
    double? remainingBalance,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (purpose != null) payload['purpose'] = purpose;
      if (additionalInfo != null) payload['additionalInfo'] = additionalInfo;
      if (status != null) payload['status'] = status;
      if (interestRate != null) payload['interestRate'] = interestRate;
      if (monthlyPayment != null) payload['monthlyPayment'] = monthlyPayment;
      if (remainingBalance != null) payload['remainingBalance'] = remainingBalance;

      final response = await ApiService().put(
        '/Loans/$loanId',
        data: payload,
      );
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

  Future<BankAccount> getBankAccount(String bankAccountId) async {
    try {
      final response = await ApiService().get('/BankAccounts/$bankAccountId');
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount> createBankAccount(Map<String, dynamic> accountData) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts',
        data: accountData,
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount> updateBankAccount(
    String bankAccountId,
    Map<String, dynamic> accountData,
  ) async {
    try {
      final response = await ApiService().put(
        '/BankAccounts/$bankAccountId',
        data: accountData,
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteBankAccount(String bankAccountId) async {
    try {
      final response = await ApiService().delete('/BankAccounts/$bankAccountId');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getBankAccountAnalytics({
    String period = 'month',
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/analytics',
        queryParameters: {'period': period},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<double> getTotalBalance() async {
    try {
      final response = await ApiService().get('/BankAccounts/total-balance');
      final data = response.data['data'];
      return _parseDouble(data) ?? 0.0;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankAccount>> getTopAccountsByBalance({int limit = 5}) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/top-accounts',
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Bank Account Integration & Sync
  Future<BankAccount> connectBankAccount(Map<String, dynamic> integrationData) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/connect',
        data: integrationData,
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount> syncBankAccount(
    String bankAccountId, {
    bool forceSync = false,
  }) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/sync',
        data: {
          'bankAccountId': bankAccountId,
          'forceSync': forceSync,
        },
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankAccount>> getConnectedAccounts() async {
    try {
      final response = await ApiService().get('/BankAccounts/connected');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> disconnectBankAccount(String bankAccountId) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/$bankAccountId/disconnect',
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Account Status Management
  Future<BankAccount> archiveBankAccount(String bankAccountId) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/$bankAccountId/archive',
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount> activateBankAccount(String bankAccountId) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/$bankAccountId/activate',
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<BankAccount> updateAccountBalance(
    String bankAccountId,
    double newBalance,
  ) async {
    try {
      final response = await ApiService().put(
        '/BankAccounts/$bankAccountId/balance',
        data: newBalance,
      );
      return BankAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Bank Transactions
  Future<BankTransaction> createTransaction(Map<String, dynamic> transactionData) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/transactions',
        data: transactionData,
      );
      return BankTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }
  
  // Alias for backward compatibility
  Future<BankTransaction> createBankTransaction(Map<String, dynamic> transactionData) async {
    return createTransaction(transactionData);
  }

  Future<List<BankTransaction>> getAccountTransactions(
    String bankAccountId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/$bankAccountId/transactions',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankTransaction>> getUserTransactions({
    String? accountType,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (accountType != null) {
        queryParams['accountType'] = accountType;
      }

      final response = await ApiService().get(
        '/BankAccounts/transactions',
        queryParameters: queryParams,
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<BankTransaction> getTransaction(String transactionId) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/transactions/$transactionId',
      );
      return BankTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankTransaction>> getRecentTransactions({int limit = 10}) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/transactions/recent',
        queryParameters: {'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransactionAnalytics({
    String period = 'month',
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/transactions/analytics',
        queryParameters: {'period': period},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getSpendingByCategory({
    String period = 'month',
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/transactions/spending-by-category',
        queryParameters: {'period': period},
      );
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(
            key,
            _parseDouble(value) ?? 0.0,
          ));
    } catch (e) {
      rethrow;
    }
  }

  // Expense Management
  Future<BankTransaction> createExpense(Map<String, dynamic> expenseData) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/expenses',
        data: expenseData,
      );
      return BankTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExpenseAnalytics({
    String period = 'month',
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/expenses/analytics',
        queryParameters: {'period': period},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getExpenseSummary() async {
    try {
      final response = await ApiService().get('/BankAccounts/expenses/summary');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<BankTransaction>> getExpensesByCategory(
    String category, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await ApiService().get(
        '/BankAccounts/expenses/category/$category',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => BankTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getExpenseCategories() async {
    try {
      final response = await ApiService().get('/BankAccounts/expenses/categories');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(
            key,
            _parseDouble(value) ?? 0.0,
          ));
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

  // Savings Accounts
  Future<List<SavingsAccount>> getSavingsAccounts() async {
    try {
      final response = await ApiService().get('/Savings/accounts');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => SavingsAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SavingsAccount> getSavingsAccount(String savingsAccountId) async {
    try {
      final response = await ApiService().get('/Savings/accounts/$savingsAccountId');
      return SavingsAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SavingsAccount> createSavingsAccount(Map<String, dynamic> accountData) async {
    try {
      final response = await ApiService().post(
        '/Savings/accounts',
        data: accountData,
      );
      return SavingsAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SavingsAccount> updateSavingsAccount(
    String savingsAccountId,
    Map<String, dynamic> accountData,
  ) async {
    try {
      final response = await ApiService().put(
        '/Savings/accounts/$savingsAccountId',
        data: accountData,
      );
      return SavingsAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteSavingsAccount(String savingsAccountId) async {
    try {
      final response = await ApiService().delete('/Savings/accounts/$savingsAccountId');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<SavingsAccount> updateSavingsGoal(
    String savingsAccountId, {
    double? targetAmount,
    DateTime? targetDate,
  }) async {
    try {
      final payload = <String, dynamic>{};
      if (targetAmount != null) payload['targetAmount'] = targetAmount;
      if (targetDate != null) payload['targetDate'] = targetDate.toIso8601String();

      final response = await ApiService().put(
        '/Savings/accounts/$savingsAccountId/goal',
        data: payload,
      );
      return SavingsAccount.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSavingsSummary() async {
    try {
      final response = await ApiService().get('/Savings/summary');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSavingsAnalytics({
    String period = 'month',
  }) async {
    try {
      final response = await ApiService().get(
        '/Savings/analytics',
        queryParameters: {'period': period},
      );
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<SavingsAccount>> getSavingsByType(String savingsType) async {
    try {
      final response = await ApiService().get('/Savings/goals/$savingsType');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => SavingsAccount.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getSavingsProgress() async {
    try {
      final response = await ApiService().get('/Savings/progress');
      return response.data['data'] as Map<String, dynamic>;
    } catch (e) {
      rethrow;
    }
  }

  // Savings Transactions
  Future<List<SavingsTransaction>> getSavingsTransactions(
    String savingsAccountId, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/Savings/accounts/$savingsAccountId/transactions',
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data
          .map((e) => SavingsTransaction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<SavingsTransaction> getSavingsTransaction(String transactionId) async {
    try {
      final response = await ApiService().get('/Savings/transactions/$transactionId');
      return SavingsTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<SavingsTransaction> createSavingsTransaction(
    Map<String, dynamic> transactionData,
  ) async {
    try {
      final response = await ApiService().post(
        '/Savings/transactions',
        data: transactionData,
      );
      return SavingsTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Savings Transfers
  Future<bool> transferBankToSavings({
    required String bankAccountId,
    required String savingsAccountId,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await ApiService().post(
        '/Savings/transfer/bank-to-savings',
        data: {
          'bankAccountId': bankAccountId,
          'savingsAccountId': savingsAccountId,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> transferSavingsToBank({
    required String savingsAccountId,
    required String bankAccountId,
    required double amount,
    String? description,
  }) async {
    try {
      final response = await ApiService().post(
        '/Savings/transfer/savings-to-bank',
        data: {
          'savingsAccountId': savingsAccountId,
          'bankAccountId': bankAccountId,
          'amount': amount,
          if (description != null) 'description': description,
        },
      );
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
      'totalFixedExpenses': totalFixedExpenses,
      'totalVariableExpenses': totalVariableExpenses,
      'remainingPercentage': remainingPercentage,
      'remainingDisposableAmount': remainingDisposableAmount,
      'totalSavings': totalSavings,
      'totalIncoming': totalIncoming,
      'totalOutgoing': totalOutgoing,
    };
  }
}

