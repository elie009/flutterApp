import 'package:flutter/material.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/theme.dart';
import 'savings_account_detail_screen.dart';
import 'add_edit_savings_account_screen.dart';

class SavingsCategoriesScreen extends StatefulWidget {
  const SavingsCategoriesScreen({super.key});

  @override
  State<SavingsCategoriesScreen> createState() => _SavingsCategoriesScreenState();
}

class _SavingsCategoriesScreenState extends State<SavingsCategoriesScreen> {
  List<SavingsAccount> _accounts = [];
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavingsData();
  }

  Future<void> _loadSavingsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final accounts = await DataService().getSavingsAccounts();
      final summary = await DataService().getSavingsSummary();
      setState(() {
        _accounts = accounts;
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

  Map<String, List<SavingsAccount>> _groupByType(List<SavingsAccount> accounts) {
    final grouped = <String, List<SavingsAccount>>{};
    for (final account in accounts.where((a) => a.isActive)) {
      final type = account.savingsType;
      if (!grouped.containsKey(type)) {
        grouped[type] = [];
      }
      grouped[type]!.add(account);
    }
    return grouped;
  }

  IconData _getSavingsTypeIcon(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return Icons.warning;
      case 'VACATION':
        return Icons.beach_access;
      case 'INVESTMENT':
        return Icons.trending_up;
      case 'RETIREMENT':
        return Icons.emoji_events;
      case 'EDUCATION':
        return Icons.school;
      case 'HOME_DOWN_PAYMENT':
      case 'HOME_DOWNPAYMENT':
        return Icons.home;
      case 'CAR_PURCHASE':
        return Icons.directions_car;
      case 'WEDDING':
        return Icons.favorite;
      case 'TRAVEL':
        return Icons.flight;
      case 'BUSINESS':
        return Icons.business;
      case 'HEALTH':
        return Icons.health_and_safety;
      case 'TAX_SAVINGS':
        return Icons.receipt;
      default:
        return Icons.savings;
    }
  }

  Color _getSavingsTypeColor(String type) {
    switch (type.toUpperCase()) {
      case 'EMERGENCY':
        return Colors.red;
      case 'VACATION':
        return Colors.blue;
      case 'INVESTMENT':
        return Colors.green;
      case 'RETIREMENT':
        return Colors.orange;
      case 'EDUCATION':
        return Colors.purple;
      case 'HOME_DOWN_PAYMENT':
      case 'HOME_DOWNPAYMENT':
        return Colors.brown;
      case 'CAR_PURCHASE':
        return Colors.teal;
      case 'WEDDING':
        return Colors.pink;
      case 'TRAVEL':
        return Colors.cyan;
      case 'BUSINESS':
        return Colors.indigo;
      case 'HEALTH':
        return Colors.lightGreen;
      case 'TAX_SAVINGS':
        return Colors.amber;
      default:
        return AppTheme.primaryColor;
    }
  }

  String _formatSavingsType(String type) {
    return type.split('_').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
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
              bottom: 20,
            ),
            child: const Center(
              child: Text(
                'Savings',
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
                  onRetry: _loadSavingsData,
                )
              : RefreshIndicator(
                  onRefresh: _loadSavingsData,
                  child: CustomScrollView(
                    slivers: [
                      // Summary Section
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Total Savings',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                Formatters.formatCurrency(
                                  (_summary?['totalSavingsBalance'] as num?)?.toDouble() ??
                                  (_summary?['totalBalance'] as num?)?.toDouble() ?? 0.0,
                                ),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (_summary != null) ...[
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _buildStatChip(
                                      'Accounts',
                                      '${_summary!['totalSavingsAccounts'] ?? 0}',
                                      Icons.account_balance_wallet,
                                    ),
                                    _buildStatChip(
                                      'Active Goals',
                                      '${_summary!['activeGoals'] ?? 0}',
                                      Icons.track_changes,
                                    ),
                                    _buildStatChip(
                                      'Completed',
                                      '${_summary!['completedGoals'] ?? 0}',
                                      Icons.check_circle,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Overall Progress',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            '${(_summary!['overallProgressPercentage'] as num?)?.toStringAsFixed(1) ?? '0.0'}%',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: ((_summary!['overallProgressPercentage'] as num?)?.toDouble() ?? 0.0) / 100.0,
                                          backgroundColor: Colors.white.withOpacity(0.3),
                                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                          minHeight: 8,
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
                      // Savings Accounts by Type
                      if (_accounts.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.savings,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No savings accounts yet',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton.icon(
                                  onPressed: () => _addSavingsAccount(context),
                                  icon: const Icon(Icons.add),
                                  label: const Text('Create Your First Savings Account'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        ..._groupByType(_accounts).entries.map((entry) {
                          return SliverToBoxAdapter(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: _getSavingsTypeColor(entry.key)
                                              .withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Icon(
                                          _getSavingsTypeIcon(entry.key),
                                          color: _getSavingsTypeColor(entry.key),
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        _formatSavingsType(entry.key),
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '${entry.value.length}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                ...entry.value.map((account) => _buildSavingsCard(account)),
                              ],
                            ),
                          );
                        }).toList(),
                    ],
                  ),
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addSavingsAccount(context),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildSavingsCard(SavingsAccount account) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: () => _navigateToDetail(account.id),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getSavingsTypeColor(account.savingsType)
                          .withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getSavingsTypeIcon(account.savingsType),
                      color: _getSavingsTypeColor(account.savingsType),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          account.accountName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (account.goal != null)
                          Text(
                            account.goal!,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  if (account.isGoalCompleted)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Complete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(account.currentBalance),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Target',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCurrency(account.targetAmount),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${account.progressPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (account.progressPercentage / 100.0).clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getSavingsTypeColor(account.savingsType),
                      ),
                      minHeight: 8,
                    ),
                  ),
                  if (account.daysRemaining > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${account.daysRemaining} days remaining',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Monthly: ${Formatters.formatCurrency(account.monthlyTarget)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToDetail(String accountId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingsAccountDetailScreen(
          savingsAccountId: accountId,
        ),
      ),
    ).then((_) => _loadSavingsData());
  }

  Future<void> _addSavingsAccount(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddEditSavingsAccountScreen(),
      ),
    );

    if (result == true) {
      _loadSavingsData();
    }
  }
}

