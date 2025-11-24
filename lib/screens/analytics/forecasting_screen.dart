import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/bill_forecast.dart';
import '../../models/bill.dart';
import '../../models/savings_account.dart';
import '../../models/loan.dart';

class ForecastingScreen extends StatefulWidget {
  const ForecastingScreen({super.key});

  @override
  State<ForecastingScreen> createState() => _ForecastingScreenState();
}

class _ForecastingScreenState extends State<ForecastingScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  List<BillForecast> _billForecasts = [];
  List<Bill> _bills = [];
  List<SavingsAccount> _savingsAccounts = [];
  List<Loan> _loans = [];

  @override
  void initState() {
    super.initState();
    _loadForecasts();
  }

  Future<void> _loadForecasts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load bills, savings, and loans
      final billsResult = await DataService().getBills(page: 1, limit: 50);
      final savingsResult = await DataService().getSavingsAccounts();
      final loansResult = await DataService().getLoans();

      _bills = (billsResult['bills'] as List<Bill>?) ?? [];
      _savingsAccounts = savingsResult['savingsAccounts'] as List<SavingsAccount>? ?? [];
      _loans = loansResult['loans'] as List<Loan>? ?? [];

      // Get unique provider/billType combinations for forecasts
      final uniqueBills = <String, Bill>{};
      for (var bill in _bills) {
        if (bill.provider != null && bill.billType != null) {
          final key = '${bill.provider}_${bill.billType}';
          if (!uniqueBills.containsKey(key)) {
            uniqueBills[key] = bill;
          }
        }
      }

      // Load forecasts for each unique bill
      final forecasts = <BillForecast>[];
      for (var bill in uniqueBills.values) {
        try {
          final forecast = await DataService().getBillForecast(
            provider: bill.provider!,
            billType: bill.billType!,
            method: 'weighted',
          );
          forecasts.add(forecast);
        } catch (e) {
          // Skip if forecast fails for this bill
        }
      }

      if (mounted) {
        setState(() {
          _billForecasts = forecasts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _refresh() {
    _loadForecasts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Forecasting'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading forecasts...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _refresh,
                )
              : _buildContent(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bill Forecasts Section
          if (_billForecasts.isNotEmpty) ...[
            const Text(
              'Bill Forecasts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._billForecasts.map((forecast) => _buildBillForecastCard(forecast)),
            const SizedBox(height: 24),
          ],

          // Savings Projections Section
          if (_savingsAccounts.isNotEmpty) ...[
            const Text(
              'Savings Goal Projections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._savingsAccounts
                .where((account) => !account.isGoalCompleted)
                .map((account) => _buildSavingsProjectionCard(account)),
            const SizedBox(height: 24),
          ],

          // Loan Payoff Projections Section
          if (_loans.isNotEmpty) ...[
            const Text(
              'Loan Payoff Projections',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            ..._loans
                .where((loan) => loan.status == 'ACTIVE' && loan.remainingBalance > 0)
                .map((loan) => _buildLoanProjectionCard(loan)),
          ],

          // Empty state
          if (_billForecasts.isEmpty &&
              _savingsAccounts.isEmpty &&
              _loans.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No forecasting data available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBillForecastCard(BillForecast forecast) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.trending_up, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text(
                      'Next Month Forecast',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: forecast.confidence.toLowerCase() == 'high'
                        ? AppTheme.successColor.withOpacity(0.2)
                        : forecast.confidence.toLowerCase() == 'medium'
                            ? AppTheme.warningColor.withOpacity(0.2)
                            : AppTheme.errorColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    forecast.confidenceDisplay,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: forecast.confidence.toLowerCase() == 'high'
                          ? AppTheme.successColor
                          : forecast.confidence.toLowerCase() == 'medium'
                              ? AppTheme.warningColor
                              : AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Estimated Amount',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(forecast.estimatedAmount),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Method',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  forecast.methodDisplay,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (forecast.recommendation.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                forecast.recommendation,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSavingsProjectionCard(SavingsAccount account) {
    final monthsRemaining = account.daysRemaining > 0
        ? (account.daysRemaining / 30.0).ceil()
        : 0;
    final projectedDate = account.daysRemaining > 0
        ? DateTime.now().add(Duration(days: account.daysRemaining))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.savings, color: AppTheme.successColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    account.accountName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Current Progress',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${account.progressPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.successColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: account.progressPercentage / 100,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                account.progressPercentage >= 100
                    ? AppTheme.successColor
                    : AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Remaining',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(account.remainingAmount),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Target',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(account.monthlyTarget),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (projectedDate != null) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Projected Completion',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    Formatters.formatDate(projectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Approximately $monthsRemaining months remaining',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoanProjectionCard(Loan loan) {
    final monthsRemaining = loan.monthlyPayment > 0
        ? (loan.remainingBalance / loan.monthlyPayment).ceil()
        : 0;
    final projectedDate = loan.monthlyPayment > 0
        ? DateTime.now().add(Duration(days: monthsRemaining * 30))
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    loan.purpose ?? 'Loan',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Remaining Balance',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(loan.remainingBalance),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Monthly Payment',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(loan.monthlyPayment),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (projectedDate != null && monthsRemaining > 0) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Projected Payoff Date',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    Formatters.formatDate(projectedDate),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Approximately $monthsRemaining months remaining',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

