import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/bill.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/empty_state.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
class BillsScreen extends StatefulWidget {
  const BillsScreen({super.key});

  @override
  State<BillsScreen> createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<Bill> _bills = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadBills();
  }

  Future<void> _loadBills({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DataService().getBills(
        status: _selectedStatus,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _bills = result['bills'] as List<Bill>;
        } else {
          _bills.addAll(result['bills'] as List<Bill>);
        }
        final pagination = result['pagination'] as Map<String, dynamic>?;
        _hasMore = pagination != null &&
            (pagination['page'] as int) < (pagination['totalPages'] as int);
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
    await _loadBills(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    if (!_hasMore || _isLoading) {
      _refreshController.loadNoData();
      return;
    }

    _currentPage++;
    await _loadBills();
    _refreshController.loadComplete();
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadBills(refresh: true);
  }

  Future<void> _markAsPaid(Bill bill) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Mark "${bill.billName}" as paid?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DataService().markBillAsPaid(bill.id);
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Bill marked as paid',
          backgroundColor: AppTheme.successColor,
        );
        _loadBills(refresh: true);
      } else if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Failed to mark bill as paid',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Bills & Utilities',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All', style: TextStyle(color: Colors.black)),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _filterByStatus(null),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.green,
                    width: 2,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFC107),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Text('Pending', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  selected: _selectedStatus == 'PENDING',
                  onSelected: (_) => _filterByStatus('PENDING'),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const Text('Paid', style: TextStyle(color: Colors.black)),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                  selected: _selectedStatus == 'PAID',
                  onSelected: (_) => _filterByStatus('PAID'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue', style: TextStyle(color: Colors.black)),
                  selected: _selectedStatus == 'OVERDUE',
                  onSelected: (_) => _filterByStatus('OVERDUE'),
                  backgroundColor: Colors.white,
                  selectedColor: Colors.white,
                ),
              ],
            ),
          ),
          // Bills List
          Expanded(
            child: _isLoading && _bills.isEmpty
                ? const ShimmerList(itemCount: 5, itemHeight: 100)
                : _errorMessage != null && _bills.isEmpty
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: () => _loadBills(refresh: true),
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoadMore,
                        enablePullUp: true,
                        child: _bills.isEmpty
                            ? EmptyState(
                                icon: Icons.receipt_long,
                                title: 'No Bills Found',
                                message: 'You don\'t have any bills yet. Add your first bill to get started!',
                                actionLabel: 'Add Bill',
                                onAction: () {
                                  // TODO: Navigate to add bill screen
                                },
                              )
                            : ListView.builder(
                                itemCount: _bills.length,
                                itemBuilder: (context, index) {
                                  final bill = _bills[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    color: bill.isOverdue
                                        ? Colors.red.shade50
                                        : Colors.white,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.receipt,
                                        color: bill.isOverdue
                                            ? AppTheme.errorColor
                                            : bill.isPaid
                                                ? AppTheme.successColor
                                                : AppTheme.warningColor,
                                      ),
                                      title: Text(
                                        bill.billName,
                                        style: const TextStyle(color: Colors.black),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (bill.provider != null)
                                            Text(
                                              bill.provider!,
                                              style: const TextStyle(color: Colors.black87),
                                            ),
                                          Text(
                                            'Due: ${Formatters.formatDate(bill.dueDate)}',
                                            style: TextStyle(
                                              color: bill.isOverdue
                                                  ? AppTheme.errorColor
                                                  : Colors.black87,
                                              fontWeight: bill.isOverdue
                                                  ? FontWeight.bold
                                                  : null,
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            Formatters.formatCurrency(bill.amount),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: bill.isOverdue
                                                  ? AppTheme.errorColor
                                                  : bill.isPaid
                                                      ? AppTheme.successColor
                                                      : AppTheme.warningColor,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              bill.status,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        NavigationHelper.pushTo(
                                          context,
                                          'bill-detail',
                                          params: {'id': bill.id},
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                      ),
          ),
        ],
      ),
      floatingActionButton: StatefulBuilder(
        builder: (context, setState) {
          bool isHovered = false;
          return MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: GestureDetector(
              onTap: () {
                NavigationHelper.pushTo(context, 'add-bill');
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: isHovered ? AppTheme.primaryColor : Colors.white,
                  border: Border.all(
                    color: AppTheme.primaryColor,
                    width: 2.5,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withOpacity(0.16),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.add,
                    color: isHovered ? Colors.white : AppTheme.primaryColor,
                    size: 36,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

