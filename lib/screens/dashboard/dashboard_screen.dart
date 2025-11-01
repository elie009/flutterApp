import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/dashboard_summary.dart';
import '../../models/transaction.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/error_widget.dart';

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
  String _selectedTransactionTab = 'Monthly';

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

  String _formatTransactionDate(DateTime date) {
    final months = ['January', 'February', 'March', 'April', 'May', 'June',
                    'July', 'August', 'September', 'October', 'November', 'December'];
    return '${months[date.month - 1]} ${date.day}';
  }

  Widget _buildTransactionIcon(Transaction transaction) {
    IconData icon;
    Color iconColor;

    if (transaction.category?.toLowerCase() == 'salary') {
      icon = Icons.attach_money;
      iconColor = Colors.lightBlue;
    } else if (transaction.category?.toLowerCase() == 'groceries' || 
               transaction.category?.toLowerCase() == 'food' ||
               transaction.category?.toLowerCase() == 'pantry') {
      icon = Icons.shopping_bag;
      iconColor = Colors.lightBlue;
    } else if (transaction.category?.toLowerCase() == 'rent') {
      icon = Icons.key;
      iconColor = Colors.lightBlue;
    } else {
      icon = transaction.isIncome ? Icons.arrow_downward : Icons.arrow_upward;
      iconColor = Colors.lightBlue;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: iconColor, size: 24),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section Skeleton
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(
              top: 50,
              left: 20,
              right: 20,
              bottom: 30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSkeletonBox(width: 180, height: 28),
                        const SizedBox(height: 8),
                        _buildSkeletonBox(width: 120, height: 16),
                      ],
                    ),
                    _buildSkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSkeletonBox(width: 100, height: 14),
                          const SizedBox(height: 4),
                          _buildSkeletonBox(width: 120, height: 24),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSkeletonBox(width: 100, height: 14),
                            const SizedBox(height: 4),
                            _buildSkeletonBox(width: 120, height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSkeletonBox(width: double.infinity, height: 40, borderRadius: BorderRadius.circular(12)),
                const SizedBox(height: 12),
                _buildSkeletonBox(width: 200, height: 16),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Stats Card Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildSkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(12)),
                        const SizedBox(height: 8),
                        _buildSkeletonBox(width: 80, height: 12),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(width: 60, height: 16),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(12)),
                        const SizedBox(height: 8),
                        _buildSkeletonBox(width: 80, height: 12),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(width: 60, height: 16),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 80,
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _buildSkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(12)),
                        const SizedBox(height: 8),
                        _buildSkeletonBox(width: 80, height: 12),
                        const SizedBox(height: 4),
                        _buildSkeletonBox(width: 60, height: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Transaction List Card Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildSkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(8)),
                      const SizedBox(width: 8),
                      _buildSkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(8)),
                      const SizedBox(width: 8),
                      _buildSkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(8)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Transaction items
                  ...List.generate(5, (index) => Padding(
                    padding: EdgeInsets.only(bottom: index < 4 ? 16 : 0),
                    child: Row(
                      children: [
                        _buildSkeletonBox(width: 40, height: 40, borderRadius: BorderRadius.circular(10)),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSkeletonBox(width: double.infinity, height: 16),
                              const SizedBox(height: 8),
                              _buildSkeletonBox(width: 100, height: 12),
                            ],
                          ),
                        ),
                        _buildSkeletonBox(width: 80, height: 16),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: shape == BoxShape.circle 
              ? Colors.white.withOpacity(0.3)
              : Colors.grey.shade300,
          borderRadius: borderRadius,
          shape: shape,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: _isLoading
          ? _buildSkeletonLoader()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadDashboard,
                )
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section with Green Background
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          padding: const EdgeInsets.only(
                            top: 50,
                            left: 20,
                            right: 20,
                            bottom: 30,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hi, Welcome Back',
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        'Good Morning',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.notifications_outlined),
                                    color: Colors.white,
                                    onPressed: () {
                                      NavigationHelper.navigateTo(context, 'notifications');
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.description_outlined,
                                              size: 16,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Total Balance',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          Formatters.formatCurrency(_summary?.totalBalance ?? 0.0),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width: 2,
                                    height: 50,
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.description_outlined,
                                                size: 16,
                                                color: Colors.white.withOpacity(0.8),
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                'Total Expense',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            Formatters.formatCurrency(_summary?.totalExpense ?? 0.0),
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Custom Progress Bar with Text Inside
                                    LayoutBuilder(
                                      builder: (context, constraints) {
                                        final progress = (_summary?.remainingPercentage ?? 0.0) / 100.0;
                                        final progressWidth = constraints.maxWidth * progress;
                                        return Stack(
                                          children: [
                                            Container(
                                              height: 40,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: const Color(0xFF10B981).withOpacity(0.5),
                                                  width: 1,
                                                ),
                                              ),
                                            ),
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: TweenAnimationBuilder<double>(
                                                duration: const Duration(milliseconds: 500),
                                                tween: Tween(
                                                  begin: 0.0,
                                                  end: progressWidth,
                                                ),
                                                builder: (context, value, child) {
                                                  return Container(
                                                    height: 40,
                                                    width: value,
                                                    color: const Color(0xFF3E9C5E),
                                                  );
                                                },
                                              ),
                                            ),
                                            Container(
                                              height: 40,
                                              alignment: Alignment.center,
                                              child: Text(
                                                Formatters.formatCurrency(_summary?.remainingDisposableAmount ?? 0.0),
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  shadows: [
                                                    Shadow(
                                                      offset: Offset(0, 1),
                                                      blurRadius: 2,
                                                      color: Colors.black26,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFFFFFFFF),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${(_summary?.remainingPercentage ?? 0.0).toStringAsFixed(0)}% Of your remaining disposable amount',
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: Colors.white.withOpacity(0.9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Stats Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Color(0xFF10B981),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Total Saving\nAmount',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatCurrency(_summary?.totalSavings ?? 0.0),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 80,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2196F3).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.money_outlined,
                                          color: Color(0xFF2196F3),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Revenue Last Week',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatCurrency(_summary?.monthlyIncome ?? 4000.00),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 1,
                                  height: 80,
                                  color: Colors.grey.withOpacity(0.2),
                                ),
                                Expanded(
                                  child: Column(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF2196F3).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.restaurant_outlined,
                                          color: Color(0xFF2196F3),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Food Last Week',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF757575),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        Formatters.formatCurrency(-100.00),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF212121),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Transaction List Card
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedTransactionTab = 'Daily';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedTransactionTab == 'Daily' 
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Daily',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedTransactionTab == 'Daily' 
                                                ? Colors.white 
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedTransactionTab = 'Weekly';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedTransactionTab == 'Weekly' 
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Weekly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedTransactionTab == 'Weekly' 
                                                ? Colors.white 
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _selectedTransactionTab = 'Monthly';
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: _selectedTransactionTab == 'Monthly' 
                                              ? const Color(0xFF10B981)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          'Monthly',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: _selectedTransactionTab == 'Monthly' 
                                                ? Colors.white 
                                                : const Color(0xFF757575),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                if (_summary?.recentTransactions.isEmpty ?? true)
                                  const Padding(
                                    padding: EdgeInsets.all(24.0),
                                    child: Text(
                                      'No recent transactions',
                                      style: TextStyle(color: Color(0xFF757575)),
                                      textAlign: TextAlign.center,
                                    ),
                                  )
                                else
                                  ...(_summary!.recentTransactions.take(5).map((transaction) {
                                        return Column(
                                          children: [
                                            ListTile(
                                              contentPadding: EdgeInsets.zero,
                                              leading: _buildTransactionIcon(transaction),
                                              title: Text(
                                                transaction.description,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF212121),
                                                ),
                                              ),
                                              subtitle: Text(
                                                '${transaction.transactionDate.hour}:${transaction.transactionDate.minute.toString().padLeft(2, '0')} - ${_formatTransactionDate(transaction.transactionDate)}',
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF2196F3),
                                                ),
                                              ),
                                              trailing: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    Formatters.formatCurrency(transaction.amount),
                                                    style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF212121),
                                                    ),
                                                  ),
                                                  Text(
                                                    transaction.category ?? '',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Color(0xFF757575),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            if (_summary!.recentTransactions.indexOf(transaction) < 
                                                _summary!.recentTransactions.take(5).length - 1)
                                              const Divider(
                                                height: 1,
                                                thickness: 1,
                                                color: Color(0xFFE0E0E0),
                                              ),
                                          ],
                                        );
                                      }).toList()),
                              ],
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 100), // Space for bottom nav
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

