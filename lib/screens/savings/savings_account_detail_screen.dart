import 'package:flutter/material.dart';
import '../../models/savings_account.dart';
import '../../models/savings_transaction.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as custom_error;
import 'add_edit_savings_account_screen.dart';
import 'savings_transfer_screen.dart';

class SavingsAccountDetailScreen extends StatefulWidget {
  final String savingsAccountId;

  const SavingsAccountDetailScreen({
    super.key,
    required this.savingsAccountId,
  });

  @override
  State<SavingsAccountDetailScreen> createState() => _SavingsAccountDetailScreenState();
}

class _SavingsAccountDetailScreenState extends State<SavingsAccountDetailScreen>
    with SingleTickerProviderStateMixin {
  SavingsAccount? _account;
  List<SavingsTransaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAccountDetails();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadAccountDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final account = await DataService().getSavingsAccount(widget.savingsAccountId);
      final transactions = await DataService().getSavingsTransactions(
        widget.savingsAccountId,
        limit: 50,
      );

      setState(() {
        _account = account;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _refresh() async {
    await _loadAccountDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      floatingActionButton: _account != null
          ? FloatingActionButton.extended(
              onPressed: () => _transferMoney(context),
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Transfer'),
              backgroundColor: AppTheme.primaryColor,
            )
          : null,
      body: Column(
        children: [
          // Header Section with Green Background and Curved Edges
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 10,
              left: 20,
              right: 20,
              bottom: 10,
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          _account?.accountName ?? 'Savings Account',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    if (_account != null)
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert, color: Colors.white),
                        color: Colors.white,
                        onSelected: (value) async {
                          switch (value) {
                            case 'edit':
                              _editAccount(context);
                              break;
                            case 'delete':
                              _deleteAccount();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                  tabs: const [
                    Tab(text: 'Overview'),
                    Tab(text: 'Transactions'),
                  ],
                ),
              ],
            ),
          ),
          // Body Content
          Expanded(
            child: _isLoading
                ? const LoadingIndicator(message: 'Loading savings account...')
                : _errorMessage != null
                    ? custom_error.ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: _loadAccountDetails,
                      )
                    : _account == null
                        ? const Center(child: Text('Account not found'))
                        : RefreshIndicator(
                            onRefresh: _refresh,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildOverviewTab(),
                                _buildTransactionsTab(),
                              ],
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    if (_account == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Account Summary Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Current Balance',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            Formatters.formatCurrency(_account!.currentBalance),
                            style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.savings,
                          color: AppTheme.primaryColor,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Target Amount',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(_account!.targetAmount),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Remaining',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            Formatters.formatCurrency(_account!.remainingAmount),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Progress Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Progress',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_account!.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (_account!.progressPercentage / 100.0).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _account!.isGoalCompleted
                            ? Colors.green
                            : AppTheme.primaryColor,
                      ),
                      minHeight: 12,
                    ),
                  ),
                  if (_account!.isGoalCompleted) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'Goal Completed!',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Goal Details Card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Goal Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.account_balance_wallet,
                    'Account Name',
                    _account!.accountName,
                  ),
                  const Divider(),
                  _buildInfoRow(
                    Icons.category,
                    'Savings Type',
                    _account!.savingsType.split('_').map((w) =>
                      w[0].toUpperCase() + w.substring(1).toLowerCase()
                    ).join(' '),
                  ),
                  if (_account!.goal != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.flag,
                      'Goal',
                      _account!.goal!,
                    ),
                  ],
                  if (_account!.description != null) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.description,
                      'Description',
                      _account!.description!,
                    ),
                  ],
                  const Divider(),
                  _buildInfoRow(
                    Icons.calendar_today,
                    'Target Date',
                    Formatters.formatDate(_account!.targetDate),
                  ),
                  if (_account!.daysRemaining > 0) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.timer,
                      'Days Remaining',
                      '${_account!.daysRemaining} days',
                    ),
                  ],
                  if (_account!.monthlyTarget > 0) ...[
                    const Divider(),
                    _buildInfoRow(
                      Icons.trending_up,
                      'Monthly Target',
                      Formatters.formatCurrency(_account!.monthlyTarget),
                    ),
                  ],
                  const Divider(),
                  _buildInfoRow(
                    Icons.attach_money,
                    'Currency',
                    _account!.currency,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No transactions yet',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: transaction.isDeposit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              child: Icon(
                transaction.isDeposit
                    ? Icons.arrow_downward
                    : Icons.arrow_upward,
                color: transaction.isDeposit ? Colors.green : Colors.red,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(Formatters.formatDate(transaction.transactionDate)),
                if (transaction.category != null)
                  Text('Category: ${transaction.category}'),
                if (transaction.notes != null)
                  Text(
                    transaction.notes!,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
              ],
            ),
            trailing: Text(
              '${transaction.isDeposit ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: transaction.isDeposit ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _editAccount(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditSavingsAccountScreen(
          savingsAccount: _account,
        ),
      ),
    );

    if (result == true) {
      _loadAccountDetails();
    }
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Savings Account'),
        content: const Text(
          'Are you sure you want to delete this savings account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DataService().deleteSavingsAccount(widget.savingsAccountId);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Savings account deleted')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: $e')),
          );
        }
      }
    }
  }

  Future<void> _transferMoney(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsTransferScreen(
          savingsAccountId: widget.savingsAccountId,
        ),
      ),
    );

    if (result == true) {
      _loadAccountDetails();
    }
  }
}

