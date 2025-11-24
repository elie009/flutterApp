import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/currency_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/analytics_report.dart';

class BalanceSheetScreen extends StatefulWidget {
  const BalanceSheetScreen({super.key});

  @override
  State<BalanceSheetScreen> createState() => _BalanceSheetScreenState();
}

class _BalanceSheetScreenState extends State<BalanceSheetScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  BalanceSheet? _balanceSheet;
  DateTime? _asOfDate;

  @override
  void initState() {
    super.initState();
    _asOfDate = DateTime.now();
    _loadBalanceSheet();
  }

  Future<void> _loadBalanceSheet() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final balanceSheet = await DataService().getBalanceSheet(
        asOfDate: _asOfDate,
      );

      if (mounted) {
        setState(() {
          _balanceSheet = balanceSheet;
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
    _loadBalanceSheet();
  }

  Widget _buildBalanceSheetItem(BalanceSheetItem item) {
    return ListTile(
      title: Text(
        item.accountName,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: item.description != null
          ? Text(
              item.description!,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            )
          : null,
      trailing: Text(
        formatCurrency(item.amount),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<BalanceSheetItem> items,
    required double total,
    Color? titleColor,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: titleColor,
            ),
          ),
        ),
        Card(
          child: Column(
            children: [
              ...items.map((item) => _buildBalanceSheetItem(item)),
              const Divider(),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total $title:',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatCurrency(total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Balance Sheet'),
        actions: [
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
              : _balanceSheet == null
                  ? const Center(child: Text('No balance sheet data available'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Card(
                            color: AppTheme.primaryColor,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Balance Sheet',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'As of ${formatDate(DateTime.parse(_balanceSheet!.asOfDate))}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Balance Validation
                          _balanceSheet!.isBalanced
                              ? Card(
                                  color: Colors.green[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.check_circle,
                                          color: Colors.green[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Balance sheet is balanced: Assets = Liabilities + Equity',
                                            style: TextStyle(
                                              color: Colors.green[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Card(
                                  color: Colors.orange[50],
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.orange[700],
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Balance sheet is not balanced. Difference: ${formatCurrency((_balanceSheet!.totalAssets - _balanceSheet!.totalLiabilitiesAndEquity).abs())}',
                                            style: TextStyle(
                                              color: Colors.orange[700],
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          const SizedBox(height: 24),

                          // ASSETS SECTION
                          const Text(
                            'ASSETS',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            title: 'Current Assets',
                            items: _balanceSheet!.assets.currentAssets,
                            total: _balanceSheet!.assets.totalCurrentAssets,
                          ),
                          _buildSection(
                            title: 'Fixed Assets',
                            items: _balanceSheet!.assets.fixedAssets,
                            total: _balanceSheet!.assets.totalFixedAssets,
                          ),
                          _buildSection(
                            title: 'Other Assets',
                            items: _balanceSheet!.assets.otherAssets,
                            total: _balanceSheet!.assets.totalOtherAssets,
                          ),
                          Card(
                            color: AppTheme.primaryColor.withOpacity(0.1),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL ASSETS',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_balanceSheet!.totalAssets),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // LIABILITIES SECTION
                          const Text(
                            'LIABILITIES',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildSection(
                            title: 'Current Liabilities',
                            items: _balanceSheet!.liabilities.currentLiabilities,
                            total: _balanceSheet!.liabilities.totalCurrentLiabilities,
                            titleColor: Colors.red,
                          ),
                          _buildSection(
                            title: 'Long-term Liabilities',
                            items: _balanceSheet!.liabilities.longTermLiabilities,
                            total: _balanceSheet!.liabilities.totalLongTermLiabilities,
                            titleColor: Colors.red,
                          ),
                          Card(
                            color: Colors.red[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL LIABILITIES',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_balanceSheet!.liabilities.totalLiabilities),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // EQUITY SECTION
                          const Text(
                            'EQUITY',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Column(
                              children: [
                                ListTile(
                                  title: const Text('Owner\'s Capital'),
                                  trailing: Text(
                                    formatCurrency(_balanceSheet!.equity.ownersCapital),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                ListTile(
                                  title: const Text('Retained Earnings'),
                                  trailing: Text(
                                    formatCurrency(_balanceSheet!.equity.retainedEarnings),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Total Equity:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(_balanceSheet!.equity.totalEquity),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Total Liabilities & Equity
                          Card(
                            color: Colors.blue[50],
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'TOTAL LIABILITIES & EQUITY',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formatCurrency(_balanceSheet!.totalLiabilitiesAndEquity),
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Summary
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Summary',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildSummaryRow(
                                    'Total Assets',
                                    _balanceSheet!.totalAssets,
                                    Colors.blue,
                                  ),
                                  _buildSummaryRow(
                                    'Total Liabilities',
                                    _balanceSheet!.liabilities.totalLiabilities,
                                    Colors.red,
                                  ),
                                  _buildSummaryRow(
                                    'Total Equity',
                                    _balanceSheet!.equity.totalEquity,
                                    Colors.green,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSummaryRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            formatCurrency(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

