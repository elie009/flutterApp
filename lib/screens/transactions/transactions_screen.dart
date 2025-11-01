import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/transaction.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final TextEditingController _searchController = TextEditingController();
  List<Transaction> _transactions = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedType;

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
      final transactions = await DataService().getTransactions(
        page: _currentPage,
        limit: 50,
        transactionType: _selectedType,
      );

      setState(() {
        if (refresh) {
          _transactions = transactions;
        } else {
          _transactions.addAll(transactions);
        }
        _hasMore = transactions.length >= 50;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
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
                  selected: _selectedType == null,
                  onSelected: (_) => _filterByType(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Income'),
                  selected: _selectedType == 'credit',
                  onSelected: (_) => _filterByType('credit'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expense'),
                  selected: _selectedType == 'debit',
                  onSelected: (_) => _filterByType('debit'),
                ),
              ],
            ),
          ),
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
          ),
          // Transactions List
          Expanded(
            child: _isLoading && _transactions.isEmpty
                ? const LoadingIndicator(message: 'Loading transactions...')
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
                                  
                                  // Filter by search
                                  if (_searchController.text.isNotEmpty &&
                                      !transaction.description
                                          .toLowerCase()
                                          .contains(
                                              _searchController.text.toLowerCase())) {
                                    return const SizedBox.shrink();
                                  }

                                  return Card(
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
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

