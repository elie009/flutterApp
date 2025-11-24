import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/currency_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/analytics_report.dart';

class IncomeStatementScreen extends StatefulWidget {
  const IncomeStatementScreen({super.key});

  @override
  State<IncomeStatementScreen> createState() => _IncomeStatementScreenState();
}

class _IncomeStatementScreenState extends State<IncomeStatementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  IncomeStatement? _incomeStatement;
  String _period = 'MONTHLY';
  bool _includeComparison = false;

  @override
  void initState() {
    super.initState();
    _loadIncomeStatement();
  }

  Future<void> _loadIncomeStatement() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final incomeStatement = await DataService().getIncomeStatement(
        period: _period,
        includeComparison: _includeComparison,
      );

      if (mounted) {
        setState(() {
          _incomeStatement = incomeStatement;
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
    _loadIncomeStatement();
  }

  Widget _buildSummaryCard(String title, double amount, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatCurrency(amount),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<IncomeStatementItem> items,
    required double total,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
          const Divider(),
          if (items.isNotEmpty)
            ...items.map((item) => ListTile(
                  title: Text(item.accountName),
                  subtitle: Text(item.category),
                  trailing: Text(
                    formatCurrency(item.amount),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  formatCurrency(total),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income Statement'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _period = value;
              });
              _loadIncomeStatement();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'MONTHLY',
                child: Text('Monthly'),
              ),
              const PopupMenuItem(
                value: 'QUARTERLY',
                child: Text('Quarterly'),
              ),
              const PopupMenuItem(
                value: 'YEARLY',
                child: Text('Yearly'),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _errorMessage != null
              ? ErrorWidget(
                  message: _errorMessage!,
                  onRetry: _refresh,
                )
              : _incomeStatement == null
                  ? const Center(
                      child: Text('No income statement data available'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Income Statement',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Period: ${formatDate(DateTime.parse(_incomeStatement!.periodStart))} - ${formatDate(DateTime.parse(_incomeStatement!.periodEnd))}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Summary Cards
                          Row(
                            children: [
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Revenue',
                                  _incomeStatement!.revenue.totalRevenue,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Total Expenses',
                                  _incomeStatement!.expenses.totalExpenses,
                                  Colors.red,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildSummaryCard(
                                  'Net Income',
                                  _incomeStatement!.netIncome,
                                  _incomeStatement!.netIncome >= 0
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Revenue Section
                          _buildSection(
                            title: 'Revenue',
                            items: _incomeStatement!.revenue.revenueItems,
                            total: _incomeStatement!.revenue.totalRevenue,
                            color: Colors.green,
                          ),

                          // Expenses Section
                          _buildSection(
                            title: 'Expenses',
                            items: _incomeStatement!.expenses.expenseItems,
                            total: _incomeStatement!.expenses.totalExpenses,
                            color: Colors.red,
                          ),

                          // Comparison Section
                          if (_incomeStatement!.comparison != null)
                            Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Comparison with Previous Period',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const Divider(),
                                    const SizedBox(height: 8),
                                    _buildComparisonRow(
                                      'Revenue Change',
                                      _incomeStatement!.comparison!.revenueChange,
                                      _incomeStatement!.comparison!.revenueChangePercentage,
                                    ),
                                    _buildComparisonRow(
                                      'Expenses Change',
                                      _incomeStatement!.comparison!.expensesChange,
                                      _incomeStatement!.comparison!.expensesChangePercentage,
                                    ),
                                    _buildComparisonRow(
                                      'Net Income Change',
                                      _incomeStatement!.comparison!.netIncomeChange,
                                      _incomeStatement!.comparison!.netIncomeChangePercentage,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          // Net Income Summary
                          Card(
                            color: _incomeStatement!.netIncome >= 0
                                ? Colors.green[50]
                                : Colors.red[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Net Income',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_incomeStatement!.netIncome),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24,
                                      color: _incomeStatement!.netIncome >= 0
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }

  Widget _buildComparisonRow(String label, double change, double changePercentage) {
    final isPositive = change >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                '${isPositive ? '+' : ''}${formatCurrency(change)} (${changePercentage.toStringAsFixed(1)}%)',
                style: TextStyle(
                  color: isPositive ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

