import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/dashboard_summary.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/summary_card.dart';
import '../../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await DataService().getDashboardSummary();
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onRefresh() async {
    try {
      await _loadDashboard();
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              NavigationHelper.navigateTo(context, 'notifications');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading dashboard...')
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadDashboard,
                )
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Summary Cards Grid
                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.5,
                          children: [
                            SummaryCard(
                              title: 'Total Balance',
                              amount: _summary?.totalBalance ?? 0.0,
                              icon: Icons.account_balance,
                              color: AppTheme.primaryColor,
                            ),
                            SummaryCard(
                              title: 'Monthly Income',
                              amount: _summary?.monthlyIncome ?? 0.0,
                              icon: Icons.trending_up,
                              color: AppTheme.successColor,
                            ),
                            SummaryCard(
                              title: 'Pending Bills',
                              count: _summary?.pendingBillsCount ?? 0,
                              amount: _summary?.pendingBillsAmount ?? 0.0,
                              icon: Icons.receipt_long,
                              color: AppTheme.warningColor,
                            ),
                            SummaryCard(
                              title: 'Upcoming Payments',
                              count: _summary?.upcomingPayments.length ?? 0,
                              icon: Icons.calendar_today,
                              color: AppTheme.errorColor,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Recent Transactions
                        const Text(
                          'Recent Transactions',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_summary?.recentTransactions.isEmpty ?? true)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'No recent transactions',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...(_summary?.recentTransactions.map((transaction) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: transaction.isIncome
                                          ? AppTheme.successColor
                                          : AppTheme.errorColor,
                                      child: Icon(
                                        transaction.isIncome
                                            ? Icons.arrow_downward
                                            : Icons.arrow_upward,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(transaction.description),
                                    subtitle: Text(
                                      Formatters.formatDate(transaction.transactionDate),
                                    ),
                                    trailing: Text(
                                      Formatters.formatCurrency(transaction.amount),
                                      style: TextStyle(
                                        color: transaction.isIncome
                                            ? AppTheme.successColor
                                            : AppTheme.errorColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList() ?? []),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            NavigationHelper.navigateTo(context, 'transactions');
                          },
                          child: const Text('View All Transactions'),
                        ),
                        const SizedBox(height: 24),
                        // Upcoming Payments
                        const Text(
                          'Upcoming Payments',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_summary?.upcomingPayments.isEmpty ?? true)
                          const Padding(
                            padding: EdgeInsets.all(24.0),
                            child: Text(
                              'No upcoming payments',
                              style: TextStyle(color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          )
                        else
                          ...(_summary?.upcomingPayments.map((bill) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: ListTile(
                                    leading: const Icon(Icons.receipt),
                                    title: Text(bill.billName),
                                    subtitle: Text(
                                      'Due: ${Formatters.formatDate(bill.dueDate)}',
                                    ),
                                    trailing: Text(
                                      Formatters.formatCurrency(bill.amount),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    onTap: () {
                                      NavigationHelper.navigateTo(
                                        context,
                                        'bill-detail',
                                        params: {'id': bill.id},
                                      );
                                    },
                                  ),
                                );
                              }).toList() ?? []),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            NavigationHelper.navigateTo(context, 'bills');
                          },
                          child: const Text('View All Bills'),
                        ),
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

