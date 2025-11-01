import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../models/bank_transaction.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart' as custom_error;
import 'add_edit_bank_account_screen.dart';
import 'add_transaction_screen.dart';

class BankAccountDetailScreen extends StatefulWidget {
  final String bankAccountId;

  const BankAccountDetailScreen({
    super.key,
    required this.bankAccountId,
  });

  @override
  State<BankAccountDetailScreen> createState() => _BankAccountDetailScreenState();
}

class _BankAccountDetailScreenState extends State<BankAccountDetailScreen>
    with SingleTickerProviderStateMixin {
  BankAccount? _account;
  List<BankTransaction> _transactions = [];
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
      final account = await DataService().getBankAccount(widget.bankAccountId);
      final transactions = await DataService().getAccountTransactions(
        widget.bankAccountId,
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
                    const Expanded(
                      child: Center(
                        child: Text(
                          'Account Details',
                          style: TextStyle(
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
                            case 'activate':
                              _activateAccount();
                              break;
                            case 'sync':
                              _syncAccount();
                              break;
                            case 'archive':
                              _archiveAccount();
                              break;
                            case 'delete':
                              _deleteAccount();
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(value: 'edit', child: Text('Edit')),
                          if (_account!.isConnected)
                            const PopupMenuItem(value: 'sync', child: Text('Sync')),
                          if (_account!.isActive)
                            const PopupMenuItem(value: 'archive', child: Text('Archive')),
                          if (!_account!.isActive)
                            const PopupMenuItem(value: 'activate', child: Text('Activate')),
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
          ? const LoadingIndicator(message: 'Loading account details...')
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance Card
          Card(
            color: AppTheme.primaryColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Current Balance',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    Formatters.formatCurrency(_account!.currentBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem(
                        'Initial Balance',
                        Formatters.formatCurrency(_account!.initialBalance),
                      ),
                      _buildStatItem(
                        'Total Incoming',
                        Formatters.formatCurrency(_account!.totalIncoming),
                        color: const Color(0xFFBAFFC3),
                      ),
                      _buildStatItem(
                        'Total Outgoing',
                        Formatters.formatCurrency(_account!.totalOutgoing),
                        color: const Color(0xFFFA4D5F),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Account Information
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Account Information',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Account Name', _account!.accountName),
                  _buildInfoRow('Account Type', _account!.accountType.toUpperCase()),
                  if (_account!.accountNumber != null)
                    _buildInfoRow('Account Number', _account!.accountNumber!),
                  if (_account!.financialInstitution != null)
                    _buildInfoRow(
                      'Bank',
                      _account!.financialInstitution!,
                    ),
                  if (_account!.description != null)
                    _buildInfoRow('Description', _account!.description!),
                  _buildInfoRow('Currency', _account!.currency),
                  _buildInfoRow(
                    'Sync Frequency',
                    _account!.syncFrequency,
                  ),
                  _buildInfoRow(
                    'Status',
                    _account!.isActive ? 'Active' : 'Archived',
                  ),
                  if (_account!.isConnected)
                    _buildInfoRow('Connection', 'Connected'),
                  if (_account!.lastSyncedAt != null)
                    _buildInfoRow(
                      'Last Synced',
                      Formatters.formatDateTime(_account!.lastSyncedAt!),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick Stats
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quick Stats',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildQuickStat(
                        'Transactions',
                        _account!.transactionCount.toString(),
                        Icons.receipt,
                      ),
                      _buildQuickStat(
                        'Account Age',
                        _calculateAccountAge(),
                        Icons.calendar_today,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found',
          style: TextStyle(color: Colors.grey),
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
              backgroundColor: transaction.isIncome
                  ? Colors.green
                  : Colors.red,
              child: Icon(
                transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
            title: Text(transaction.description),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (transaction.category != null)
                  Text('Category: ${transaction.category}'),
                if (transaction.merchant != null)
                  Text('Merchant: ${transaction.merchant}'),
                Text(
                  Formatters.formatDateTime(transaction.transactionDate),
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${transaction.isIncome ? "+" : "-"}${Formatters.formatCurrency(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: transaction.isIncome ? Colors.green : Colors.red,
                  ),
                ),
                Text(
                  'Balance: ${Formatters.formatCurrency(transaction.balanceAfterTransaction)}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            onTap: () {
              // Could navigate to transaction detail screen
            },
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color ?? Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: AppTheme.primaryColor),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  String _calculateAccountAge() {
    final now = DateTime.now();
    final created = _account!.createdAt;
    final difference = now.difference(created);

    if (difference.inDays < 30) {
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months';
    } else {
      return '${(difference.inDays / 365).floor()} years';
    }
  }

  Future<void> _addTransaction(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _editAccount(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditBankAccountScreen(
          account: _account,
        ),
      ),
    );

    if (result == true) {
      _refresh();
    }
  }

  Future<void> _activateAccount() async {
    try {
      await DataService().activateBankAccount(_account!.id);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account activated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to activate: $e')),
        );
      }
    }
  }

  Future<void> _syncAccount() async {
    try {
      await DataService().syncBankAccount(_account!.id);
      _refresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account synced successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }

  Future<void> _archiveAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Account'),
        content: const Text('Are you sure you want to archive this account?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DataService().archiveBankAccount(_account!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account archived')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to archive: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete this account? This action cannot be undone.',
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

    if (confirm == true) {
      try {
        await DataService().deleteBankAccount(_account!.id);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account deleted')),
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
}

