import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/bank_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/theme.dart';
import 'bank_account_detail_screen.dart';
import 'add_edit_bank_account_screen.dart';
import 'add_transaction_screen.dart';

class BankAccountsScreen extends StatefulWidget {
  const BankAccountsScreen({super.key});

  @override
  State<BankAccountsScreen> createState() => _BankAccountsScreenState();
}

class _BankAccountsScreenState extends State<BankAccountsScreen> {
  List<BankAccount> _accounts = [];
  double _totalBalance = 0.0;
  int _totalAccounts = 0;
  int _activeAccounts = 0;
  int _connectedAccounts = 0;
  bool _isLoading = true;
  String? _errorMessage;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  // Helper methods to safely parse summary data
  double? _parseDoubleFromSummary(Map<String, dynamic> summary, String key) {
    final value = summary[key];
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  int? _parseIntFromSummary(Map<String, dynamic> summary, String key) {
    final value = summary[key];
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  Future<void> _loadBankAccounts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accounts = await DataService().getBankAccounts(
        isActive: _showInactive ? null : true,
      );
      final summary = await DataService().getBankAccountsSummary();

      setState(() {
        _accounts = accounts;
        // Safely parse summary data with type checking
        _totalBalance = _parseDoubleFromSummary(summary, 'totalBalance') ?? 0.0;
        _totalAccounts = _parseIntFromSummary(summary, 'totalAccounts') ?? accounts.length;
        _activeAccounts = _parseIntFromSummary(summary, 'activeAccounts') ?? accounts.where((a) => a.isActive).length;
        _connectedAccounts = _parseIntFromSummary(summary, 'connectedAccounts') ?? accounts.where((a) => a.isConnected).length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (!didPop && mounted) {
          // Schedule navigation immediately after current frame
          Future.microtask(() {
            if (!mounted) return;
            try {
              // If we can pop (because we used push), pop to previous route
              if (context.canPop()) {
                context.pop();
              } else {
                // Fallback: navigate to category or dashboard if no route to pop
                // This handles cases where user navigated directly to this screen
                context.go('/category');
              }
            } catch (e) {
              // If navigation fails, try dashboard as last resort
              if (mounted) {
                try {
                  context.go('/dashboard');
                } catch (_) {
                  // canPop: false should prevent app closure even if navigation fails
                }
              }
            }
          });
        }
      },
      child: Scaffold(
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
              bottom: 20,
            ),
            child: const Center(
              child: Text(
                'Bank Accounts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          // Body Content
          Expanded(
            child: _isLoading
          ? SkeletonList(itemCount: 6)
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadBankAccounts,
                )
              : RefreshIndicator(
                  onRefresh: _loadBankAccounts,
                  child: CustomScrollView(
                    slivers: [
                      // Summary Section
                      SliverToBoxAdapter(
                        child: Column(
                          children: [
                            // Total Balance Card
                            Container(
                              margin: const EdgeInsets.all(16),
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Total Balance',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    Formatters.formatCurrency(_totalBalance),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildStatChip(
                                        'Accounts',
                                        '$_totalAccounts',
                                        Icons.account_balance_wallet,
                                      ),
                                      _buildStatChip(
                                        'Active',
                                        '$_activeAccounts',
                                        Icons.check_circle,
                                      ),
                                      if (_connectedAccounts > 0)
                                        _buildStatChip(
                                          'Connected',
                                          '$_connectedAccounts',
                                          Icons.link,
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Quick Actions
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _addAccount(context),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text(
                                        'Add Account',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      onPressed: () => _addTransaction(context),
                                      icon: const Icon(Icons.add_circle_outline, size: 18),
                                      label: const Text(
                                        'Add Transaction',
                                        style: TextStyle(fontSize: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                      // Accounts List
                      _accounts.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.account_balance_wallet,
                                      size: 64,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No bank accounts found',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ElevatedButton.icon(
                                      onPressed: () => _addAccount(context),
                                      icon: const Icon(Icons.add),
                                      label: const Text('Add Your First Account'),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) {
                                  final account = _accounts[index];
                                  return _buildAccountCard(account);
                                },
                                childCount: _accounts.length,
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

  Widget _buildStatChip(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountCard(BankAccount account) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToDetail(account.id),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: _getAccountTypeColor(account.accountType),
                child: Icon(
                  _getAccountTypeIcon(account.accountType),
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            account.accountName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!account.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Archived',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${account.accountType.toUpperCase()}${account.accountNumber != null ? ' • ${account.accountNumber}' : ''}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    if (account.financialInstitution != null)
                      Text(
                        account.financialInstitution!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(account.currentBalance),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  if (account.isConnected)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.link,
                          size: 14,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Connected',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.green,
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
    );
  }

  Color _getAccountTypeColor(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Colors.blue;
      case 'wallet':
        return Colors.purple;
      case 'credit':
        return Colors.red;
      case 'cash':
        return Colors.green;
      case 'investment':
        return Colors.orange;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getAccountTypeIcon(String accountType) {
    switch (accountType.toLowerCase()) {
      case 'bank':
        return Icons.account_balance;
      case 'wallet':
        return Icons.wallet;
      case 'credit':
        return Icons.credit_card;
      case 'cash':
        return Icons.money;
      case 'investment':
        return Icons.trending_up;
      default:
        return Icons.account_balance_wallet;
    }
  }

  void _navigateToDetail(String accountId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BankAccountDetailScreen(
          bankAccountId: accountId,
        ),
      ),
    ).then((_) => _loadBankAccounts());
  }

  Future<void> _addAccount(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditBankAccountScreen(),
      ),
    );

    if (result == true) {
      _loadBankAccounts();
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
      _loadBankAccounts();
    }
  }

  Future<void> _showAnalytics() async {
    try {
      final analytics = await DataService().getBankAccountAnalytics();
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Account Analytics'),
            content: SingleChildScrollView(
              child: Text(analytics.toString()),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load analytics: $e')),
        );
      }
    }
  }

  Future<void> _syncAllConnected() async {
    try {
      final connected = await DataService().getConnectedAccounts();
      int synced = 0;
      for (final account in connected) {
        try {
          await DataService().syncBankAccount(account.id);
          synced++;
        } catch (e) {
          // Continue with other accounts
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Synced $synced of ${connected.length} accounts'),
          ),
        );
        _loadBankAccounts();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sync failed: $e')),
        );
      }
    }
  }
}

