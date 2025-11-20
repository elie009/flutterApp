import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/dashboard_summary.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../bank/add_transaction_screen.dart';
import '../bank/analyzer_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  DashboardSummary? _summary;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final summary = await DataService().getDashboardSummary(forceRefresh: forceRefresh);
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
      await _loadData(forceRefresh: true);
      _refreshController.refreshCompleted();
    } catch (e) {
      _refreshController.refreshFailed();
    }
  }

  void _handleTakePhoto(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    if (!mounted) return;
    NavigationHelper.showSnackBar(
      context,
      'Receipt scanning is coming soon.',
    );
  }

  void _handleUploadImage(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    if (!mounted) return;
    NavigationHelper.showSnackBar(
      context,
      'Image upload is coming soon.',
    );
  }

  Future<void> _navigateToAnalyzer(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    if (!mounted) {
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AnalyzerScreen(),
      ),
    );
    if (result == true && mounted) {
      _loadData(forceRefresh: true);
    }
  }

  Future<void> _navigateToAddTransaction(BuildContext sheetContext) async {
    Navigator.of(sheetContext).pop();
    if (!mounted) {
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddTransactionScreen(),
      ),
    );
    if (result == true && mounted) {
      _loadData(forceRefresh: true);
    }
  }

  void _showMoreOptionsModal() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add Transaction by',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // 2x2 Grid Layout
                Column(
                  children: [
                    // Row 1: Take photo and Upload Image
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleTakePhoto(sheetContext),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Take photo'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _handleUploadImage(sheetContext),
                            icon: const Icon(Icons.image_outlined),
                            label: const Text('Upload Image'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Row 2: Analyzer and Add manually
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToAnalyzer(sheetContext),
                            icon: const Icon(Icons.auto_awesome),
                            label: const Text('Analyzer'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _navigateToAddTransaction(sheetContext),
                            icon: const Icon(Icons.add),
                            label: const Text('Add manually'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF2196F3),
                size: 24,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212121),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
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
                    const SizedBox(width: 48), // Balance space
                    SkeletonBox(width: 100, height: 28),
                    SkeletonBox(width: 40, height: 40, shape: BoxShape.circle),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: 100, height: 14),
                          const SizedBox(height: 4),
                          SkeletonBox(width: 120, height: 24),
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
                            SkeletonBox(width: 100, height: 14),
                            const SizedBox(height: 4),
                            SkeletonBox(width: 120, height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SkeletonBox(width: double.infinity, height: 40, borderRadius: BorderRadius.circular(20)),
                const SizedBox(height: 12),
                SkeletonBox(width: 200, height: 16),
              ],
            ),
          ),
          // Category Grid Skeleton
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            child: Container(
              margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 0),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(
                  Radius.circular(20),
                ),
              ),
              child: GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 4),
                children: List.generate(9, (index) => Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFE0E0E0),
                    width: 1,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: SkeletonBox(width: 24, height: 24, borderRadius: BorderRadius.circular(10)),
                    ),
                    const SizedBox(height: 6),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: SkeletonBox(width: 60, height: 12),
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ),
        ),
      ],
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
                  onRetry: _loadData,
                )
              : SmartRefresher(
                  controller: _refreshController,
                  onRefresh: _onRefresh,
                  child: SingleChildScrollView(
                    child: Column(
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
                                const SizedBox(width: 48), // Balance space
                                const Text(
                                  'Categories',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
                                  // Calculate net to determine label type
                                  Builder(
                                    builder: (context) {
                                      final incoming = _summary?.totalIncoming ?? 0.0;
                                      final outgoing = _summary?.totalOutgoing ?? 0.0;
                                      String label;
                                      Color labelColor;
                                      
                                      if (incoming > outgoing) {
                                        label = 'Net Incoming';
                                        labelColor = const Color(0xFF4CAF50); // Green
                                      } else if (outgoing > incoming) {
                                        label = 'Net Outgoing';
                                        labelColor = const Color(0xFFE53935); // Red
                                      } else {
                                        label = 'Net Balance';
                                        labelColor = const Color(0xFF2196F3); // Blue
                                      }
                                      
                                      return Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white.withOpacity(0.9),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
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
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: const Color(0xFF10B981).withOpacity(0.5),
                                                width: 1,
                                              ),
                                            ),
                                          ),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(20),
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
                    
                    // Category Grid
                    ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(20)),
                      child: Container(
                        margin: const EdgeInsets.only(top: 20, left: 16, right: 16, bottom: 0),
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(
                            Radius.circular(20),
                          ),
                        ),
                        child: GridView.count(
                          crossAxisCount: 3,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.0,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 4),
                          children: [
                            _buildCategoryItem(
                              icon: Icons.restaurant,
                              label: 'Food',
                              onTap: () {
                                // Navigate to Food category
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.shopping_bag,
                              label: 'Groceries',
                              onTap: () {
                                // Navigate to Groceries category
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.add,
                              label: 'More',
                              onTap: _showMoreOptionsModal,
                            ),
                            _buildCategoryItem(
                              icon: Icons.settings,
                              label: 'Settings',
                              onTap: () {
                                // Navigate to Settings category
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.account_balance_wallet,
                              label: 'Income',
                              onTap: () {
                                NavigationHelper.navigateTo(context, 'income');
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.receipt_long,
                              label: 'Bills',
                              onTap: () {
                                NavigationHelper.navigateTo(context, 'bills');
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.savings,
                              label: 'Savings',
                              onTap: () {
                                NavigationHelper.navigateTo(context, 'savings');
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.credit_card,
                              label: 'Loans',
                              onTap: () {
                                NavigationHelper.navigateTo(context, 'loans');
                              },
                            ),
                            _buildCategoryItem(
                              icon: Icons.account_balance_rounded,
                              label: 'Account',
                              onTap: () {
                                // Use push instead of go to maintain navigation stack
                                context.pushNamed('banks');
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 100), // Space for bottom nav
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}
