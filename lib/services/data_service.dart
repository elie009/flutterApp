import '../models/transaction.dart';
import '../models/bill.dart';
import '../models/utility.dart';
import '../models/bill_analytics.dart';
import '../models/bill_forecast.dart';
import '../models/bill_variance.dart';
import '../models/financial_prediction.dart';
import '../models/cash_flow_projection.dart';
import '../models/loan.dart';
import '../models/income_source.dart';
import '../models/bank_account.dart';
import '../models/bank_transaction.dart';
import '../models/notification.dart';
import '../models/dashboard_summary.dart';
import '../models/savings_account.dart';
import '../models/savings_transaction.dart';
import '../models/analytics_report.dart';
import '../models/allocation.dart';
import '../models/audit_log.dart';
import '../models/receipt.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

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
  Future<DashboardSummary> getDashboardSummary({bool forceRefresh = false}) async {
    try {
      // Try cache first if not forcing refresh
      if (!forceRefresh) {
        final cached = StorageService.getCache(AppConfig.cacheDashboard);
        if (cached != null) {
          try {
            final jsonData = jsonDecode(cached);
            return DashboardSummary.fromJson(jsonData);
          } catch (e) {
            // If cache parsing fails, continue to fetch from API
          }
        }
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

  Future<bool> markBillAsPaid(String billId, {String? notes, String? bankAccountId}) async {
    try {
      final response = await ApiService().put(
        '/Bills/$billId/mark-paid',
        data: {
          if (notes != null) 'notes': notes,
          if (bankAccountId != null) 'bankAccountId': bankAccountId,
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

  // Get bill forecast
  Future<BillForecast> getBillForecast({
    required String provider,
    required String billType,
    String method = 'weighted', // 'simple', 'weighted', 'seasonal'
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'provider': provider,
        'billType': billType,
        'method': method,
      };

      final response = await ApiService().get(
        '/Bills/analytics/forecast',
        queryParameters: queryParams,
      );
      
      return BillForecast.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get bill variance
  Future<BillVariance> getBillVariance(String billId) async {
    try {
      final response = await ApiService().get('/Bills/$billId/variance');
      return BillVariance.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get variance for multiple bills
  Future<List<BillVariance>> getBillsVariance({List<String>? billIds}) async {
    try {
      // If no bill IDs provided, get all bills first
      if (billIds == null || billIds.isEmpty) {
        final billsResult = await getBills(page: 1, limit: 100);
        final bills = billsResult['bills'] as List<Bill>;
        billIds = bills
            .where((bill) => bill.provider != null && bill.billType != null)
            .map((bill) => bill.id)
            .toList();
      }

      // Get variance for each bill
      final variances = <BillVariance>[];
      for (final billId in billIds) {
        try {
          final variance = await getBillVariance(billId);
          variances.add(variance);
        } catch (e) {
          // Skip bills that fail variance calculation
          continue;
        }
      }

      return variances;
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

  Future<Loan> applyForLoan({
    required double principal,
    required double interestRate,
    required int term,
    required String purpose,
    required double monthlyIncome,
    required String employmentStatus,
    String? additionalInfo,
    double? downPayment,
    double? processingFee,
    String? interestComputationMethod,
    String? loanType,
    String? refinancedFromLoanId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'principal': principal,
        'interestRate': interestRate,
        'term': term,
        'purpose': purpose,
        'monthlyIncome': monthlyIncome,
        'employmentStatus': employmentStatus,
      };

      if (additionalInfo != null && additionalInfo.isNotEmpty) {
        payload['additionalInfo'] = additionalInfo;
      }
      if (downPayment != null) {
        payload['downPayment'] = downPayment;
      }
      if (processingFee != null) {
        payload['processingFee'] = processingFee;
      }
      if (interestComputationMethod != null && interestComputationMethod.isNotEmpty) {
        payload['interestComputationMethod'] = interestComputationMethod;
      }
      if (loanType != null && loanType.isNotEmpty) {
        payload['loanType'] = loanType;
      }
      if (refinancedFromLoanId != null && refinancedFromLoanId.isNotEmpty) {
        payload['refinancedFromLoanId'] = refinancedFromLoanId;
      }

      final response = await ApiService().post(
        '/Loans/apply',
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

  // Disburse loan with optional bank account crediting
  Future<Map<String, dynamic>> disburseLoan({
    required String loanId,
    required String disbursedBy,
    required String disbursementMethod,
    String? reference,
    String? bankAccountId,
  }) async {
    try {
      final payload = <String, dynamic>{
        'loanId': loanId,
        'disbursedBy': disbursedBy,
        'disbursementMethod': disbursementMethod,
      };
      if (reference != null && reference.isNotEmpty) {
        payload['reference'] = reference;
      }
      if (bankAccountId != null && bankAccountId.isNotEmpty) {
        payload['bankAccountId'] = bankAccountId;
      }

      final response = await ApiService().post(
        '/admin/transactions/disburse',
        data: payload,
      );
      
      return {
        'success': response.data['success'] == true,
        'data': response.data['data'] as Map<String, dynamic>? ?? {},
        'message': response.data['message'] as String? ?? 'Loan disbursed successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': e.toString(),
        'data': {},
      };
    }
  }

  // Income Sources
  Future<Map<String, dynamic>> getIncomeSources({
    bool includeSummary = true,
    bool activeOnly = true,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/incomesource/with-summary',
        queryParameters: {
          'activeOnly': activeOnly,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data'] as Map<String, dynamic>;
      final incomeSources = (data['incomeSources'] as List<dynamic>?)
          ?.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>))
          .toList() ?? [];

      return {
        'incomeSources': incomeSources,
        'totalMonthlyIncome': _parseDouble(data['totalMonthlyIncome']) ?? 0.0,
        'totalSources': _parseInt(data['totalSources']) ?? 0,
        'totalActiveSources': _parseInt(data['totalActiveSources']) ?? 0,
        'totalPrimarySources': _parseInt(data['totalPrimarySources']) ?? 0,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<List<IncomeSource>> getAllIncomeSources({
    bool activeOnly = true,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/incomesource',
        queryParameters: {
          'activeOnly': activeOnly,
          'page': page,
          'limit': limit,
        },
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeSource> getIncomeSource(String id) async {
    try {
      final response = await ApiService().get('/incomesource/$id');
      return IncomeSource.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeSource> createIncomeSource(Map<String, dynamic> incomeData) async {
    try {
      final response = await ApiService().post(
        '/incomesource',
        data: incomeData,
      );
      return IncomeSource.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeSource> updateIncomeSource(String id, Map<String, dynamic> incomeData) async {
    try {
      final response = await ApiService().put(
        '/incomesource/$id',
        data: incomeData,
      );
      return IncomeSource.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteIncomeSource(String id) async {
    try {
      final response = await ApiService().delete('/incomesource/$id');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<double> getTotalMonthlyIncome() async {
    try {
      final response = await ApiService().get('/incomesource/total-monthly-income');
      return _parseDouble(response.data['data']) ?? 0.0;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getIncomeByCategory() async {
    try {
      final response = await ApiService().get('/incomesource/income-by-category');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(
            key,
            _parseDouble(value) ?? 0.0,
          ));
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, double>> getIncomeByFrequency() async {
    try {
      final response = await ApiService().get('/incomesource/income-by-frequency');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return data.map((key, value) => MapEntry(
            key,
            _parseDouble(value) ?? 0.0,
          ));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAvailableCategories() async {
    try {
      final response = await ApiService().get('/incomesource/available-categories');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<String>> getAvailableFrequencies() async {
    try {
      final response = await ApiService().get('/incomesource/available-frequencies');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => e.toString()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<IncomeSource>> getIncomeSourcesByCategory(String category, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/incomesource/by-category/$category',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<IncomeSource>> getIncomeSourcesByFrequency(String frequency, {
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await ApiService().get(
        '/incomesource/by-frequency/$frequency',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => IncomeSource.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
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
      final data = response.data['data'] ?? response.data;
      if (data is Map<String, dynamic>) {
        return data;
      }
      // Return empty map if data is not a map
      return <String, dynamic>{};
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

  // Analyze transaction text
  Future<BankTransaction> analyzeTransactionText({
    required String transactionText,
    String? bankAccountId,
    String? billId,
    String? loanId,
    String? savingsAccountId,
  }) async {
    try {
      final response = await ApiService().post(
        '/BankAccounts/transactions/analyze-text',
        data: {
          'transactionText': transactionText,
          if (bankAccountId != null) 'bankAccountId': bankAccountId,
          if (billId != null) 'billId': billId,
          if (loanId != null) 'loanId': loanId,
          if (savingsAccountId != null) 'savingsAccountId': savingsAccountId,
        },
      );
      return BankTransaction.fromJson(response.data['data'] as Map<String, dynamic>);
    } on DioException catch (e) {
      // Re-throw DioException to preserve response data
      rethrow;
    } catch (e) {
      rethrow;
    }
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
  Future<List<SavingsAccount>> getSavingsAccounts({bool? isActive}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['isActive'] = isActive;
      }
      
      final response = await ApiService().get(
        '/Savings/accounts',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );
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

  // Analytics & Reports
  Future<FinancialSummary> getFinancialSummary({DateTime? date}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (date != null) {
        queryParams['date'] = date.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/summary',
        queryParameters: queryParams.isEmpty ? null : queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return FinancialSummary.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<FullFinancialReport> getFullFinancialReport({
    String period = 'MONTHLY',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'CUSTOM' && startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/full',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return FullFinancialReport.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<IncomeReport> getIncomeReport({
    String period = 'MONTHLY',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'CUSTOM' && startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/income',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return IncomeReport.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<ExpenseReport> getExpenseReport({
    String period = 'MONTHLY',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'CUSTOM' && startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/expenses',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return ExpenseReport.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }


  Future<LoanReport> getLoanReport({
    String period = 'MONTHLY',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'CUSTOM' && startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/loans',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return LoanReport.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }


  Future<NetWorthReport> getNetWorthReport({
    String period = 'MONTHLY',
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };

      if (period == 'CUSTOM' && startDate != null && endDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/networth',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return NetWorthReport.fromJson(data);
    } catch (e) {
      rethrow;
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

  // Get financial predictions
  Future<List<FinancialPrediction>> getFinancialPredictions() async {
    try {
      final response = await ApiService().get('/Reports/predictions');
      final data = response.data['data'] as List<dynamic>?;
      if (data == null) return [];
      return data
          .map((e) => FinancialPrediction.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get cash flow projection
  Future<CashFlowProjection> getCashFlowProjection({int monthsAhead = 6}) async {
    try {
      final response = await ApiService().get(
        '/Reports/cashflow-projection',
        queryParameters: {'monthsAhead': monthsAhead},
      );
      return CashFlowProjection.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Get Balance Sheet
  Future<BalanceSheet> getBalanceSheet({DateTime? asOfDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (asOfDate != null) {
        queryParams['asOfDate'] = asOfDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/balance-sheet',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return BalanceSheet.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get Cash Flow Statement
  Future<CashFlowStatement> getCashFlowStatement({
    DateTime? startDate,
    DateTime? endDate,
    String period = 'MONTHLY',
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/cashflow-statement',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return CashFlowStatement.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get Income Statement
  Future<IncomeStatement> getIncomeStatement({
    DateTime? startDate,
    DateTime? endDate,
    String period = 'MONTHLY',
    bool includeComparison = false,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'includeComparison': includeComparison.toString(),
      };
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/Reports/income-statement',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return IncomeStatement.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // ==================== UTILITY MANAGEMENT ====================

  Future<Map<String, dynamic>> getUtilities({
    String? status,
    String? utilityType,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (status != null) queryParams['status'] = status;
      if (utilityType != null) queryParams['utilityType'] = utilityType;

      final response = await ApiService().get(
        '/utilities',
        queryParameters: queryParams,
      );

      final responseData = response.data;
      List<Utility> utilities = [];
      Map<String, dynamic>? pagination;

      if (responseData is Map<String, dynamic>) {
        if (responseData.containsKey('data') && responseData['data'] is Map) {
          final dataMap = responseData['data'] as Map<String, dynamic>;
          if (dataMap.containsKey('data') && dataMap['data'] is List) {
            utilities = (dataMap['data'] as List<dynamic>)
                .map((e) => Utility.fromJson(e as Map<String, dynamic>))
                .toList();
            pagination = dataMap['pagination'] as Map<String, dynamic>?;
          }
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          utilities = (responseData['data'] as List<dynamic>)
              .map((e) => Utility.fromJson(e as Map<String, dynamic>))
              .toList();
          pagination = responseData['pagination'] as Map<String, dynamic>?;
        }
      } else if (responseData is List) {
        utilities = responseData
            .map((e) => Utility.fromJson(e as Map<String, dynamic>))
            .toList();
        pagination = null;
      }

      return {
        'utilities': utilities,
        'pagination': pagination,
      };
    } catch (e) {
      rethrow;
    }
  }

  Future<Utility> getUtility(String utilityId) async {
    try {
      final response = await ApiService().get('/utilities/$utilityId');
      return Utility.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markUtilityAsPaid(String utilityId,
      {String? notes, String? bankAccountId}) async {
    try {
      final response = await ApiService().put(
        '/utilities/$utilityId/mark-paid',
        data: {
          if (notes != null) 'notes': notes,
          if (bankAccountId != null) 'bankAccountId': bankAccountId,
        },
      );
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<Utility>> getOverdueUtilities() async {
    try {
      final response = await ApiService().get('/utilities/overdue');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Utility.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Utility>> getUpcomingUtilities({int days = 7}) async {
    try {
      final response = await ApiService().get(
        '/utilities/upcoming',
        queryParameters: {'days': days},
      );
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Utility.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Utility> createUtility(Map<String, dynamic> utilityData) async {
    try {
      final response = await ApiService().post('/utilities', data: utilityData);
      return Utility.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<Utility> updateUtility(
      String utilityId, Map<String, dynamic> utilityData) async {
    try {
      final response =
          await ApiService().put('/utilities/$utilityId', data: utilityData);
      return Utility.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteUtility(String utilityId) async {
    try {
      final response = await ApiService().delete('/utilities/$utilityId');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // ==================== ALLOCATION PLANNER METHODS ====================

  // Template Operations
  Future<List<AllocationTemplate>> getAllocationTemplates() async {
    try {
      final response = await ApiService().get('/Allocation/templates');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationTemplate.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AllocationTemplate> getAllocationTemplate(String templateId) async {
    try {
      final response = await ApiService().get('/Allocation/templates/$templateId');
      return AllocationTemplate.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Plan Operations
  Future<AllocationPlan?> getActiveAllocationPlan() async {
    try {
      final response = await ApiService().get('/Allocation/plans/active');
      if (response.data['success'] == true && response.data['data'] != null) {
        return AllocationPlan.fromJson(response.data['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<AllocationPlan>> getAllocationPlans() async {
    try {
      final response = await ApiService().get('/Allocation/plans');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationPlan.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<AllocationPlan> getAllocationPlan(String planId) async {
    try {
      final response = await ApiService().get('/Allocation/plans/$planId');
      return AllocationPlan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<AllocationPlan> createAllocationPlan(Map<String, dynamic> planData) async {
    try {
      final response = await ApiService().post('/Allocation/plans', data: planData);
      return AllocationPlan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<AllocationPlan> updateAllocationPlan(String planId, Map<String, dynamic> planData) async {
    try {
      final response = await ApiService().put('/Allocation/plans/$planId', data: planData);
      return AllocationPlan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAllocationPlan(String planId) async {
    try {
      final response = await ApiService().delete('/Allocation/plans/$planId');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<AllocationPlan> applyAllocationTemplate(String templateId, double monthlyIncome) async {
    try {
      final response = await ApiService().post(
        '/Allocation/plans/apply-template',
        data: {'templateId': templateId, 'monthlyIncome': monthlyIncome},
      );
      return AllocationPlan.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // Category Operations
  Future<List<AllocationCategory>> getAllocationCategories(String planId) async {
    try {
      final response = await ApiService().get('/Allocation/plans/$planId/categories');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationCategory.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // History & Tracking
  Future<List<AllocationHistory>> getAllocationHistory({
    String? planId,
    String? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? months,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (planId != null) queryParams['planId'] = planId;
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (startDate != null) queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();
      if (months != null) queryParams['months'] = months;

      final response = await ApiService().get('/Allocation/history', queryParameters: queryParams);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationHistory.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> recordAllocationHistory(String planId) async {
    try {
      final response = await ApiService().post('/Allocation/plans/$planId/record-history');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  // Recommendations
  Future<List<AllocationRecommendation>> getAllocationRecommendations({String? planId}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (planId != null) queryParams['planId'] = planId;

      final response = await ApiService().get('/Allocation/recommendations', queryParameters: queryParams);
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationRecommendation.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> markRecommendationRead(String recommendationId) async {
    try {
      final response = await ApiService().post('/Allocation/recommendations/$recommendationId/read');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> applyRecommendation(String recommendationId) async {
    try {
      final response = await ApiService().post('/Allocation/recommendations/$recommendationId/apply');
      return response.data['success'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<List<AllocationRecommendation>> generateAllocationRecommendations(String planId) async {
    try {
      final response = await ApiService().post('/Allocation/plans/$planId/generate-recommendations');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((json) => AllocationRecommendation.fromJson(json as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Charts & Calculations
  Future<AllocationChartData> getAllocationChartData(String planId, {DateTime? periodDate}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (periodDate != null) queryParams['periodDate'] = periodDate.toIso8601String();

      final response = await ApiService().get(
        '/Allocation/plans/$planId/chart-data',
        queryParameters: queryParams,
      );
      return AllocationChartData.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<AllocationSummary> getAllocationSummary(String planId) async {
    try {
      final response = await ApiService().get('/Allocation/plans/$planId/summary');
      return AllocationSummary.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  // ==========================================
  // AUDIT LOGS METHODS
  // ==========================================

  // Get audit logs with filtering
  Future<PaginatedAuditLogs> getAuditLogs(AuditLogQuery query) async {
    try {
      final response = await ApiService().get(
        '/AuditLogs',
        queryParameters: query.toQueryParams(),
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return PaginatedAuditLogs.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get audit log by ID
  Future<AuditLog> getAuditLog(String logId) async {
    try {
      final response = await ApiService().get('/AuditLogs/$logId');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return AuditLog.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Get audit log summary
  Future<AuditLogSummary> getAuditLogSummary({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final response = await ApiService().get(
        '/AuditLogs/summary',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return AuditLogSummary.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  // Export audit logs to CSV
  Future<String> exportAuditLogsToCsv(AuditLogQuery query) async {
    try {
      final response = await ApiService().post(
        '/AuditLogs/export/csv',
        data: query.toQueryParams(),
        responseType: ResponseType.bytes,
      );

      // Save to file (implementation depends on your file system access)
      // For now, return base64 encoded string
      return response.data.toString();
    } catch (e) {
      rethrow;
    }
  }

  // Export audit logs to PDF
  Future<String> exportAuditLogsToPdf(AuditLogQuery query) async {
    try {
      final response = await ApiService().post(
        '/AuditLogs/export/pdf',
        data: query.toQueryParams(),
        responseType: ResponseType.bytes,
      );

      // Save to file (implementation depends on your file system access)
      // For now, return base64 encoded string
      return response.data.toString();
    } catch (e) {
      rethrow;
    }
  }

  // Receipt Management
  Future<Receipt> uploadReceipt(File file) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split('/').last),
      });

      final response = await ApiService().post(
        '/Receipts/upload',
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return Receipt.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Receipt> processReceiptOcr(String receiptId) async {
    try {
      final response = await ApiService().post('/Receipts/$receiptId/process-ocr');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return Receipt.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<Receipt> getReceipt(String receiptId) async {
    try {
      final response = await ApiService().get('/Receipts/$receiptId');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return Receipt.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Receipt>> getReceipts({
    DateTime? startDate,
    DateTime? endDate,
    String? merchant,
    double? minAmount,
    double? maxAmount,
    bool? isOcrProcessed,
    String? searchText,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      if (merchant != null) {
        queryParams['merchant'] = merchant;
      }
      if (minAmount != null) {
        queryParams['minAmount'] = minAmount;
      }
      if (maxAmount != null) {
        queryParams['maxAmount'] = maxAmount;
      }
      if (isOcrProcessed != null) {
        queryParams['isOcrProcessed'] = isOcrProcessed;
      }
      if (searchText != null && searchText.isNotEmpty) {
        queryParams['searchText'] = searchText;
      }

      final response = await ApiService().get(
        '/Receipts',
        queryParameters: queryParams,
      );

      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => Receipt.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReceipt(String receiptId) async {
    try {
      await ApiService().delete('/Receipts/$receiptId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Receipt> linkReceiptToExpense(String receiptId, String expenseId) async {
    try {
      final response = await ApiService().post('/Receipts/$receiptId/link-expense/$expenseId');
      final data = response.data['data'] as Map<String, dynamic>? ?? {};
      return Receipt.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<ExpenseMatch>> findMatchingExpenses(String receiptId) async {
    try {
      final response = await ApiService().get('/Receipts/$receiptId/match-expenses');
      final data = response.data['data'] as List<dynamic>? ?? [];
      return data.map((e) => ExpenseMatch.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      rethrow;
    }
  }
}

