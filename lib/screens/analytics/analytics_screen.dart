import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/currency_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/analytics_report.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'MONTHLY';
  bool _isLoading = true;
  String? _errorMessage;
  
  FinancialSummary? _summary;
  FullFinancialReport? _fullReport;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await Future.wait([
        DataService().getFinancialSummary(),
        DataService().getFullFinancialReport(period: _selectedPeriod),
      ]);

      if (mounted) {
        setState(() {
          _summary = results[0] as FinancialSummary;
          _fullReport = results[1] as FullFinancialReport;
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

  void _onPeriodChanged(String period) {
    setState(() {
      _selectedPeriod = period;
    });
    _loadAnalytics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAnalytics,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading analytics...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadAnalytics,
                )
              : _buildContent(),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildContent() {
    if (_summary == null || _fullReport == null) {
      return const Center(
        child: Text('No data available'),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAnalytics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPeriodSelector(),
            const SizedBox(height: 16),
            _buildSummaryCards(),
            const SizedBox(height: 24),
            if (_fullReport!.incomeReport.incomeBySource.isNotEmpty)
              _buildIncomeBySourceChart(),
            const SizedBox(height: 24),
            if (_fullReport!.incomeReport.incomeTrend.isNotEmpty)
              _buildIncomeTrendChart(),
            const SizedBox(height: 24),
            if (_fullReport!.expenseReport.expenseByCategory.isNotEmpty)
              _buildExpensePieChart(),
            const SizedBox(height: 24),
            if (_fullReport!.expenseReport.expenseTrend.isNotEmpty)
              _buildExpenseTrendChart(),
            const SizedBox(height: 24),
            if (_fullReport!.expenseReport.categoryComparison.isNotEmpty)
              _buildExpenseComparisonChart(),
            const SizedBox(height: 24),
            if (_fullReport!.loanReport != null &&
                _fullReport!.loanReport!.activeLoansCount > 0)
              _buildLoanReportSection(),
            const SizedBox(height: 24),
            if (_fullReport!.netWorthReport != null)
              _buildNetWorthSection(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildPeriodButton('MONTHLY', 'Monthly'),
          const SizedBox(width: 8),
          _buildPeriodButton('QUARTERLY', 'Quarterly'),
          const SizedBox(width: 8),
          _buildPeriodButton('YEARLY', 'Yearly'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period, String label) {
    final isSelected = _selectedPeriod == period;
    return Expanded(
      child: ElevatedButton(
        onPressed: () => _onPeriodChanged(period),
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected
              ? AppTheme.primaryColor
              : Colors.grey[200],
          foregroundColor: isSelected ? Colors.white : AppTheme.textPrimary,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Total Income',
                  _summary!.totalIncome,
                  _summary!.incomeChange,
                  Icons.trending_up,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Total Expenses',
                  _summary!.totalExpenses,
                  _summary!.expenseChange,
                  Icons.trending_down,
                  Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Disposable Income',
                  _summary!.disposableIncome,
                  _summary!.disposableIncomeChange,
                  Icons.account_balance_wallet,
                  AppTheme.primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Net Worth',
                  _summary!.netWorth,
                  _summary!.netWorthChange,
                  Icons.attach_money,
                  Colors.blue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    String title,
    double value,
    double change,
    IconData icon,
    Color color,
  ) {
    final isPositive = change >= 0;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              Formatters.formatCurrency(value, symbol: CurrencyHelper.getCurrentUserCurrencySymbol()),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 14,
                  color: isPositive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  '${isPositive ? '+' : ''}${change.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeBySourceChart() {
    if (_fullReport!.incomeReport.incomeBySource.isEmpty) {
      return const SizedBox.shrink();
    }

    final sources = _fullReport!.incomeReport.incomeBySource.entries.toList();
    final total = sources.fold<double>(0.0, (sum, e) => sum + e.value);
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income by Source',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: sources.asMap().entries.map((entry) {
                          final index = entry.key;
                          final source = entry.value;
                          final percentage = (source.value / total * 100);
                          return PieChartSectionData(
                            value: source.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: colors[index % colors.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sources.asMap().entries.map((entry) {
                        final index = entry.key;
                        final source = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  source.key,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                Formatters.formatCurrency(
                                  source.value,
                                  symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncomeTrendChart() {
    if (_fullReport!.incomeReport.incomeTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Income Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Avg: ${Formatters.formatCurrency(_fullReport!.incomeReport.monthlyAverage, symbol: CurrencyHelper.getCurrentUserCurrencySymbol())}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                Text(
                  'Growth: ${_fullReport!.incomeReport.growthRate.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 12,
                    color: _fullReport!.incomeReport.growthRate >= 0
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              Formatters.formatCurrency(
                                value,
                                symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _fullReport!.incomeReport.incomeTrend.length) {
                            return Text(
                              _fullReport!.incomeReport.incomeTrend[value.toInt()].label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _fullReport!.incomeReport.incomeTrend
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensePieChart() {
    if (_fullReport!.expenseReport.expenseByCategory.isEmpty) {
      return const SizedBox.shrink();
    }

    final categories = _fullReport!.expenseReport.expenseByCategory.entries.toList();
    categories.sort((a, b) => b.value.compareTo(a.value));
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense by Category',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Highest: ${_fullReport!.expenseReport.highestExpenseCategory} (${_fullReport!.expenseReport.highestExpensePercentage.toStringAsFixed(1)}%)',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: PieChart(
                      PieChartData(
                        sections: categories.asMap().entries.map((entry) {
                          final index = entry.key;
                          final category = entry.value;
                          final total = categories.fold<double>(
                              0.0, (sum, e) => sum + e.value);
                          final percentage = (category.value / total * 100);
                          return PieChartSectionData(
                            value: category.value,
                            title: '${percentage.toStringAsFixed(1)}%',
                            color: colors[index % colors.length],
                            radius: 60,
                            titleStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }).toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final category = entry.value;
                        final percentage = _fullReport!.expenseReport
                            .expensePercentage[category.key] ?? 0.0;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  color: colors[index % colors.length],
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  category.key,
                                  style: const TextStyle(fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    Formatters.formatCurrency(
                                      category.value,
                                      symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${percentage.toStringAsFixed(1)}%',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseTrendChart() {
    if (_fullReport!.expenseReport.expenseTrend.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Expense Trend',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'Fixed: ${Formatters.formatCurrency(_fullReport!.expenseReport.fixedExpenses, symbol: CurrencyHelper.getCurrentUserCurrencySymbol())}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
                const SizedBox(width: 16),
                Text(
                  'Variable: ${Formatters.formatCurrency(_fullReport!.expenseReport.variableExpenses, symbol: CurrencyHelper.getCurrentUserCurrencySymbol())}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              Formatters.formatCurrency(
                                value,
                                symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < _fullReport!.expenseReport.expenseTrend.length) {
                            return Text(
                              _fullReport!.expenseReport.expenseTrend[value.toInt()].label,
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _fullReport!.expenseReport.expenseTrend
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.red.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpenseComparisonChart() {
    if (_fullReport!.expenseReport.categoryComparison.isEmpty) {
      return const SizedBox.shrink();
    }

    final comparison = _fullReport!.expenseReport.categoryComparison;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Comparison (Current vs Previous)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: comparison.fold<double>(
                    0.0,
                    (max, item) => max > item.currentAmount
                        ? max
                        : (item.previousAmount > item.currentAmount
                            ? item.previousAmount
                            : item.currentAmount),
                  ) * 1.2,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < comparison.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                comparison[value.toInt()].category,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Text(
                              Formatters.formatCurrency(
                                value,
                                symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                              ),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: comparison.asMap().entries.map((entry) {
                    final index = entry.key;
                    final item = entry.value;
                    return BarChartGroupData(
                      x: index,
                      groupVertically: false,
                      barRods: [
                        BarChartRodData(
                          toY: item.currentAmount,
                          color: AppTheme.primaryColor,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: item.previousAmount,
                          color: Colors.grey[400]!,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                      barsSpace: 8,
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    const Text('Current', style: TextStyle(fontSize: 12)),
                  ],
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    const Text('Previous', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoanReportSection() {
    final loanReport = _fullReport!.loanReport!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Loan Report',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildLoanStatCard(
                    'Active Loans',
                    loanReport.activeLoansCount.toString(),
                    Icons.credit_card,
                    Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanStatCard(
                    'Total Remaining',
                    Formatters.formatCurrency(
                      loanReport.totalRemainingBalance,
                      symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                    ),
                    Icons.money_off,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildLoanStatCard(
                    'Monthly Payment',
                    Formatters.formatCurrency(
                      loanReport.totalMonthlyPayment,
                      symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                    ),
                    Icons.payment,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildLoanStatCard(
                    'Months to Debt-Free',
                    loanReport.monthsUntilDebtFree.toString(),
                    Icons.calendar_today,
                    Colors.green,
                  ),
                ),
              ],
            ),
            if (loanReport.repaymentTrend.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Repayment Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 150,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                Formatters.formatCurrency(
                                  value,
                                  symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                                ),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < loanReport.repaymentTrend.length) {
                              return Text(
                                loanReport.repaymentTrend[value.toInt()].label,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: AppTheme.textSecondary,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: loanReport.repaymentTrend
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.purple,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (loanReport.activeLoans.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Active Loans',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...loanReport.activeLoans.map((loan) => Card(
                    color: Colors.grey[50],
                    child: ListTile(
                      title: Text(loan.purpose),
                      subtitle: Text(
                        'Progress: ${loan.repaymentProgress.toStringAsFixed(1)}%',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            Formatters.formatCurrency(
                              loan.remainingBalance,
                              symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${loan.interestRate.toStringAsFixed(1)}% APR',
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLoanStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthSection() {
    final netWorthReport = _fullReport!.netWorthReport!;
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Net Worth',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: _buildNetWorthItem(
                    'Assets',
                    netWorthReport.totalAssets,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildNetWorthItem(
                    'Liabilities',
                    netWorthReport.totalLiabilities,
                    Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 1,
                  child: _buildNetWorthItem(
                    'Net Worth',
                    netWorthReport.currentNetWorth,
                    Colors.blue,
                  ),
                ),
              ],
            ),
            if (netWorthReport.netWorthTrend.isNotEmpty) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text(
                                Formatters.formatCurrency(
                                  value,
                                  symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                                ),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 &&
                                value.toInt() < netWorthReport.netWorthTrend.length) {
                              return Text(
                                netWorthReport.netWorthTrend[value.toInt()].label,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.textSecondary,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: netWorthReport.netWorthTrend
                            .asMap()
                            .entries
                            .map((e) => FlSpot(e.key.toDouble(), e.value.value))
                            .toList(),
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (netWorthReport.trendDescription.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        netWorthReport.trendDescription,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (netWorthReport.assetBreakdown.isNotEmpty ||
                netWorthReport.liabilityBreakdown.isNotEmpty) ...[
              const SizedBox(height: 16),
              if (netWorthReport.assetBreakdown.isNotEmpty) ...[
                const Text(
                  'Asset Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...netWorthReport.assetBreakdown.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 12)),
                          Text(
                            Formatters.formatCurrency(
                              entry.value,
                              symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
              if (netWorthReport.liabilityBreakdown.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text(
                  'Liability Breakdown',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...netWorthReport.liabilityBreakdown.entries.map((entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: const TextStyle(fontSize: 12)),
                          Text(
                            Formatters.formatCurrency(
                              entry.value,
                              symbol: CurrencyHelper.getCurrentUserCurrencySymbol(),
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNetWorthItem(String label, double value, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                Formatters.formatCurrency(value, symbol: CurrencyHelper.getCurrentUserCurrencySymbol()),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
