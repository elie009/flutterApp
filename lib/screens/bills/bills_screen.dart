import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/bill.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

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
      appBar: AppBar(
        title: const Text('Bills & Utilities'),
      ),
      body: Column(
        children: [
          // Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: _selectedStatus == null,
                  onSelected: (_) => _filterByStatus(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedStatus == 'PENDING',
                  onSelected: (_) => _filterByStatus('PENDING'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Paid'),
                  selected: _selectedStatus == 'PAID',
                  onSelected: (_) => _filterByStatus('PAID'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Overdue'),
                  selected: _selectedStatus == 'OVERDUE',
                  onSelected: (_) => _filterByStatus('OVERDUE'),
                ),
              ],
            ),
          ),
          // Bills List
          Expanded(
            child: _isLoading && _bills.isEmpty
                ? const LoadingIndicator(message: 'Loading bills...')
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
                            ? const Center(
                                child: Text(
                                  'No bills found',
                                  style: TextStyle(color: Colors.grey),
                                ),
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
                                        : null,
                                    child: ListTile(
                                      leading: Icon(
                                        Icons.receipt,
                                        color: bill.isOverdue
                                            ? AppTheme.errorColor
                                            : bill.isPaid
                                                ? AppTheme.successColor
                                                : AppTheme.warningColor,
                                      ),
                                      title: Text(bill.billName),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (bill.provider != null)
                                            Text(bill.provider!),
                                          Text(
                                            'Due: ${Formatters.formatDate(bill.dueDate)}',
                                            style: TextStyle(
                                              color: bill.isOverdue
                                                  ? AppTheme.errorColor
                                                  : null,
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
                                        NavigationHelper.navigateTo(
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

