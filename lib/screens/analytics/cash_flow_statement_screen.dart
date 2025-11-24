import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import '../../utils/formatters.dart';
import '../../utils/currency_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../services/data_service.dart';
import '../../models/analytics_report.dart';

class CashFlowStatementScreen extends StatefulWidget {
  const CashFlowStatementScreen({super.key});

  @override
  State<CashFlowStatementScreen> createState() => _CashFlowStatementScreenState();
}

class _CashFlowStatementScreenState extends State<CashFlowStatementScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  CashFlowStatement? _cashFlowStatement;
  String _period = 'MONTHLY';

  @override
  void initState() {
    super.initState();
    _loadCashFlowStatement();
  }

  Future<void> _loadCashFlowStatement() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cashFlowStatement = await DataService().getCashFlowStatement(
        period: _period,
      );

      if (mounted) {
        setState(() {
          _cashFlowStatement = cashFlowStatement;
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
    _loadCashFlowStatement();
  }

  Widget _buildCashFlowItem(CashFlowItem item) {
    return ListTile(
      title: Text(
        item.description,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        item.category,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
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
    required double inflows,
    required double outflows,
    required double netCash,
    required List<CashFlowItem> items,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cash Inflows:'),
                    Text(
                      formatCurrency(inflows),
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Cash Outflows:'),
                    Text(
                      formatCurrency(outflows),
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Cash Flow:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatCurrency(netCash),
                      style: TextStyle(
                        color: netCash >= 0 ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (items.isNotEmpty) ...[
            const Divider(),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Transaction Details',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...items.map((item) => _buildCashFlowItem(item)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cash Flow Statement'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                _period = value;
              });
              _loadCashFlowStatement();
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
              : _cashFlowStatement == null
                  ? const Center(
                      child: Text('No cash flow statement data available'),
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
                                    'Cash Flow Statement',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Period: ${formatDate(DateTime.parse(_cashFlowStatement!.periodStart))} - ${formatDate(DateTime.parse(_cashFlowStatement!.periodEnd))}',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  _cashFlowStatement!.isBalanced
                                      ? Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.green,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Cash flow statement is balanced',
                                              style: TextStyle(
                                                color: Colors.green,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          children: [
                                            Icon(
                                              Icons.error,
                                              color: Colors.orange,
                                              size: 20,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Cash flow statement is not balanced',
                                              style: TextStyle(
                                                color: Colors.orange,
                                              ),
                                            ),
                                          ],
                                        ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Operating Activities
                          _buildSection(
                            title: 'Operating Activities',
                            inflows: _cashFlowStatement!.operatingActivities.totalOperatingInflows,
                            outflows: _cashFlowStatement!.operatingActivities.totalOperatingOutflows,
                            netCash: _cashFlowStatement!.operatingActivities.netCashFromOperations,
                            items: _cashFlowStatement!.operatingActivities.outflowItems,
                            icon: Icons.account_balance,
                            color: Colors.blue,
                          ),

                          // Investing Activities
                          _buildSection(
                            title: 'Investing Activities',
                            inflows: _cashFlowStatement!.investingActivities.totalInvestingInflows,
                            outflows: _cashFlowStatement!.investingActivities.totalInvestingOutflows,
                            netCash: _cashFlowStatement!.investingActivities.netCashFromInvesting,
                            items: _cashFlowStatement!.investingActivities.outflowItems,
                            icon: Icons.trending_up,
                            color: Colors.purple,
                          ),

                          // Financing Activities
                          _buildSection(
                            title: 'Financing Activities',
                            inflows: _cashFlowStatement!.financingActivities.totalFinancingInflows,
                            outflows: _cashFlowStatement!.financingActivities.totalFinancingOutflows,
                            netCash: _cashFlowStatement!.financingActivities.netCashFromFinancing,
                            items: _cashFlowStatement!.financingActivities.outflowItems,
                            icon: Icons.trending_down,
                            color: Colors.orange,
                          ),

                          // Summary
                          Card(
                            color: Colors.grey[100],
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
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Beginning Cash:'),
                                      Text(
                                        formatCurrency(_cashFlowStatement!.beginningCash),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Net Cash Flow:'),
                                      Text(
                                        formatCurrency(_cashFlowStatement!.netCashFlow),
                                        style: TextStyle(
                                          color: _cashFlowStatement!.netCashFlow >= 0
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(height: 24),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Ending Cash:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      Text(
                                        formatCurrency(_cashFlowStatement!.endingCash),
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
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
}

