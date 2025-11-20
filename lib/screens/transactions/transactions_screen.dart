import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:file_picker/file_picker.dart';
import '../../models/transaction.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
import '../../utils/theme.dart';
import '../bank/add_transaction_screen.dart';
import '../bank/analyzer_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedType;
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // If dateFrom is set but dateTo is not, default dateTo to today
      DateTime? effectiveDateTo = _dateTo;
      if (_dateFrom != null && _dateTo == null) {
        effectiveDateTo = DateTime.now();
      }
      
      // Format dates as YYYY-MM-DD for API
      final String? dateFromStr = _dateFrom != null
          ? '${_dateFrom!.year}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}'
          : null;
      final String? dateToStr = effectiveDateTo != null
          ? '${effectiveDateTo.year}-${effectiveDateTo.month.toString().padLeft(2, '0')}-${effectiveDateTo.day.toString().padLeft(2, '0')}'
          : null;

      // Determine page and limit based on context
      // When applying date filters (refresh with dates): page=1, limit=50
      // When paginating with date filters: use current page, limit=50
      // When refreshing without date filters: page=1, limit=10
      // Initial load without date filters: page=1, limit=10
      // Pagination without date filters: use current page, limit=50
      final int limit;
      final int page;
      final bool hasDateFilters = dateFromStr != null || dateToStr != null;
      
      if (hasDateFilters) {
        // Date filters active
        if (refresh || _currentPage == 1) {
          // Applying date filters - reset to page 1
          page = 1;
          limit = 50;
        } else {
          // Pagination with date filters - use current page
          page = _currentPage;
          limit = 50;
        }
      } else if (refresh) {
        // Refresh without date filters - use limit=10
        page = 1;
        limit = 10;
      } else if (_currentPage == 1) {
        // Initial load without date filters - use limit=10
        page = 1;
        limit = 10;
      } else {
        // Pagination without date filters - use limit=50
        page = _currentPage;
        limit = 50;
      }
      
      // Don't include accountType in API calls
      final String? accountTypeParam = null;
      
      final transactions = await DataService().getTransactions(
        page: page,
        limit: limit,
        transactionType: _selectedType,
        dateFrom: dateFromStr,
        dateTo: dateToStr,
        accountType: accountTypeParam,
      );

      // Filter by transaction type (case-insensitive) as a safety measure
      List<Transaction> filteredTransactions = transactions;
      if (_selectedType != null) {
        filteredTransactions = transactions.where((transaction) {
          return transaction.transactionType.toLowerCase() == _selectedType!.toLowerCase();
        }).toList();
      }

      // Sort transactions by transactionDate in descending order (newest first)
      final sortedTransactions = List<Transaction>.from(filteredTransactions)
        ..sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

      setState(() {
        if (refresh) {
          _transactions = sortedTransactions;
        } else {
          _transactions.addAll(sortedTransactions);
          // Re-sort all transactions after adding new ones
          _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
          // Re-filter after adding to ensure only correct type is shown
          if (_selectedType != null) {
            _transactions = _transactions.where((transaction) {
              return transaction.transactionType.toLowerCase() == _selectedType!.toLowerCase();
            }).toList();
          }
        }
        _hasMore = transactions.length >= limit;
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
    await _loadTransactions(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    if (!_hasMore || _isLoading) {
      _refreshController.loadNoData();
      return;
    }

    _currentPage++;
    await _loadTransactions();
    _refreshController.loadComplete();
  }

  void _filterByType(String? type) {
    setState(() {
      _selectedType = type;
    });
    _loadTransactions(refresh: true);
  }

  void _clearDateFilter() {
    setState(() {
      _dateFrom = null;
      _dateTo = null;
    });
    _loadTransactions(refresh: true);
  }

  void _handleTakePhoto(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Receipt scanning is coming soon.'),
      ),
    );
  }

  void _handleUploadImage(BuildContext sheetContext) {
    Navigator.of(sheetContext).pop();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Image upload is coming soon.'),
      ),
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
      _loadTransactions(refresh: true);
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
      _loadTransactions(refresh: true);
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

  Future<void> _showDateFilterDialog() async {
    DateTime? tempDateFrom = _dateFrom;
    DateTime? tempDateTo = _dateTo;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Filter by Date Range',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              // Date From
              ListTile(
                title: const Text('Date From'),
                subtitle: Text(
                  tempDateFrom != null
                      ? '${tempDateFrom!.year}-${tempDateFrom!.month.toString().padLeft(2, '0')}-${tempDateFrom!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tempDateFrom ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    setModalState(() {
                      tempDateFrom = picked;
                      // If dateTo is set and picked date is after dateTo, clear dateTo
                      if (tempDateTo != null && picked.isAfter(tempDateTo!)) {
                        tempDateTo = null;
                      }
                    });
                  }
                },
              ),
              const Divider(),
              // Date To
              ListTile(
                title: const Text('Date To'),
                subtitle: Text(
                  tempDateTo != null
                      ? '${tempDateTo!.year}-${tempDateTo!.month.toString().padLeft(2, '0')}-${tempDateTo!.day.toString().padLeft(2, '0')}'
                      : 'Select date',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: tempDateTo ?? (tempDateFrom ?? DateTime.now()),
                    firstDate: tempDateFrom ?? DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    // Validation: dateTo must be greater than dateFrom
                    if (tempDateFrom != null && picked.isBefore(tempDateFrom!)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Date To must be greater than Date From'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    setModalState(() {
                      tempDateTo = picked;
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              // Clear Button
              if (tempDateFrom != null || tempDateTo != null)
                TextButton(
                  onPressed: () {
                    setModalState(() {
                      tempDateFrom = null;
                      tempDateTo = null;
                    });
                  },
                  child: const Text('Clear'),
                ),
              const SizedBox(height: 10),
              // Apply Button
              ElevatedButton(
                onPressed: () {
                  // Final validation
                  if (tempDateFrom != null && tempDateTo != null && tempDateTo!.isBefore(tempDateFrom!)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Date To must be greater than Date From'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                  setState(() {
                    _dateFrom = tempDateFrom;
                    _dateTo = tempDateTo;
                  });
                  Navigator.pop(context);
                  _loadTransactions(refresh: true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Apply Filter'),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
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
                'Transactions',
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
            child: Column(
              children: [
                // Filter Chips
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: _selectedType == null,
                        onSelected: (_) => _filterByType(null),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_upward,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('Debit'),
                          ],
                        ),
                        selected: _selectedType == 'debit',
                        onSelected: (_) => _filterByType('debit'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: const BoxDecoration(
                                color: Colors.green,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_downward,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text('Credit'),
                          ],
                        ),
                        selected: _selectedType == 'credit',
                        onSelected: (_) => _filterByType('credit'),
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Icon(Icons.settings, size: 18),
                        selected: _dateFrom != null || _dateTo != null,
                        onSelected: (_) => _showDateFilterDialog(),
                      ),
                    ],
                  ),
                ),
                // + More Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _showMoreOptionsModal,
                      icon: const Icon(Icons.add),
                      label: const Text('More'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF10B981),
                        side: const BorderSide(color: Color(0xFF10B981)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                // Transactions List
                Expanded(
                  child: _isLoading && _transactions.isEmpty
                      ? SkeletonList(itemCount: 8)
                      : _errorMessage != null && _transactions.isEmpty
                          ? ErrorDisplay(
                              message: _errorMessage!,
                              onRetry: () => _loadTransactions(refresh: true),
                            )
                          : SmartRefresher(
                              controller: _refreshController,
                              onRefresh: _onRefresh,
                              onLoading: _onLoadMore,
                              enablePullUp: true,
                              child: _transactions.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No transactions found',
                                        style: TextStyle(color: Colors.grey),
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: _transactions.length,
                                      itemBuilder: (context, index) {
                                        final transaction = _transactions[index];

                                        return Card(
                                          color: Colors.white,
                                          margin: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 4,
                                          ),
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
                                            subtitle: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  Formatters.formatDateTime(
                                                    transaction.transactionDate,
                                                  ),
                                                ),
                                                if (transaction.category != null)
                                                  Text(
                                                    transaction.category!,
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                              ],
                                            ),
                                            trailing: Text(
                                              '${transaction.isIncome ? '+' : '-'}${Formatters.formatCurrency(transaction.amount)}',
                                              style: TextStyle(
                                                color: transaction.isIncome
                                                    ? AppTheme.successColor
                                                    : AppTheme.errorColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                ),
              ],
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

