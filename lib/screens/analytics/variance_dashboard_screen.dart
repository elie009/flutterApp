import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/bill_variance.dart';
import '../../models/bill.dart';
import '../../utils/navigation_helper.dart';

class VarianceDashboardScreen extends StatefulWidget {
  const VarianceDashboardScreen({super.key});

  @override
  State<VarianceDashboardScreen> createState() => _VarianceDashboardScreenState();
}

class _VarianceDashboardScreenState extends State<VarianceDashboardScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  
  List<BillVariance> _variances = [];
  List<Bill> _bills = [];
  Map<String, Bill> _billMap = {};

  // Summary statistics
  double _totalActual = 0.0;
  double _totalEstimated = 0.0;
  double _totalVariance = 0.0;
  int _overBudgetCount = 0;
  int _onTargetCount = 0;
  int _underBudgetCount = 0;
  int _noDataCount = 0;

  @override
  void initState() {
    super.initState();
    _loadVarianceData();
  }

  Future<void> _loadVarianceData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load bills first
      final billsResult = await DataService().getBills(page: 1, limit: 100);
      final bills = billsResult['bills'] as List<Bill>;
      
      // Filter bills that have provider and billType (required for variance)
      final validBills = bills
          .where((bill) => bill.provider != null && bill.billType != null)
          .toList();

      // Create bill map for quick lookup
      _billMap = {for (var bill in validBills) bill.id: bill};

      // Get variance for all valid bills
      final variances = await DataService().getBillsVariance(
        billIds: validBills.map((b) => b.id).toList(),
      );

      // Calculate summary statistics
      _calculateSummary(variances);

      if (mounted) {
        setState(() {
          _bills = validBills;
          _variances = variances;
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

  void _calculateSummary(List<BillVariance> variances) {
    _totalActual = 0.0;
    _totalEstimated = 0.0;
    _totalVariance = 0.0;
    _overBudgetCount = 0;
    _onTargetCount = 0;
    _underBudgetCount = 0;
    _noDataCount = 0;

    for (var variance in variances) {
      if (!variance.hasNoData) {
        _totalActual += variance.actualAmount;
        _totalEstimated += variance.estimatedAmount;
        _totalVariance += variance.variance;

        if (variance.isOverBudget) {
          _overBudgetCount++;
        } else if (variance.isOnTarget) {
          _onTargetCount++;
        } else if (variance.isUnderBudget) {
          _underBudgetCount++;
        }
      } else {
        _noDataCount++;
      }
    }
  }

  void _refresh() {
    _loadVarianceData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Variance Analysis'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading variance data...')
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
    if (_variances.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: Text(
            'No variance data available.\nAdd bills with provider and type to see variance analysis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVarianceData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            _buildSummarySection(),
            const SizedBox(height: 24),

            // Variance List
            const Text(
              'Bill Variance Details',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            ..._variances.map((variance) => _buildVarianceCard(variance)),
          ],
        ),
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Summary',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildSummaryCard(
              'Total Actual',
              Formatters.formatCurrency(_totalActual),
              AppTheme.primaryColor,
              Icons.receipt,
            ),
            _buildSummaryCard(
              'Total Estimated',
              Formatters.formatCurrency(_totalEstimated),
              Colors.blue,
              Icons.trending_up,
            ),
            _buildSummaryCard(
              'Total Variance',
              Formatters.formatCurrency(_totalVariance),
              _totalVariance >= 0 ? Colors.red : AppTheme.successColor,
              _totalVariance >= 0 ? Icons.trending_up : Icons.trending_down,
            ),
            _buildSummaryCard(
              'Bills Analyzed',
              '${_variances.length}',
              Colors.purple,
              Icons.assessment,
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Status Breakdown
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Status Breakdown',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildStatusRow('Over Budget', _overBudgetCount, Colors.red),
                _buildStatusRow('On Target', _onTargetCount, AppTheme.successColor),
                _buildStatusRow('Under Budget', _underBudgetCount, Colors.green),
                if (_noDataCount > 0)
                  _buildStatusRow('No Data', _noDataCount, Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVarianceCard(BillVariance variance) {
    final bill = _billMap[variance.billId];
    final statusColor = variance.isOverBudget
        ? Colors.red
        : variance.isOnTarget
            ? AppTheme.successColor
            : variance.isUnderBudget
                ? Colors.green
                : Colors.grey;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: bill != null
            ? () {
                NavigationHelper.navigateTo(
                  context,
                  'bill-detail',
                  params: {'id': variance.billId},
                );
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      bill?.billName ?? 'Bill ${variance.billId.substring(0, 8)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      variance.statusDisplay,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              if (bill?.provider != null) ...[
                const SizedBox(height: 4),
                Text(
                  bill!.provider!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Actual',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(variance.actualAmount),
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
                    'Estimated',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    variance.hasNoData
                        ? 'N/A'
                        : Formatters.formatCurrency(variance.estimatedAmount),
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
                    'Variance',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        variance.variance >= 0
                            ? Icons.trending_up
                            : Icons.trending_down,
                        size: 16,
                        color: variance.variance >= 0 ? Colors.red : Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        variance.hasNoData
                            ? 'N/A'
                            : '${variance.variance >= 0 ? '+' : ''}${Formatters.formatCurrency(variance.variance)} (${variance.variancePercentage >= 0 ? '+' : ''}${variance.variancePercentage.toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: variance.variance >= 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (variance.message.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        variance.isOverBudget
                            ? Icons.warning
                            : variance.isOnTarget
                                ? Icons.check_circle
                                : Icons.info,
                        size: 16,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          variance.message,
                          style: TextStyle(
                            fontSize: 12,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (variance.recommendation.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '💡 ${variance.recommendation}',
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
      ),
    );
  }
}

