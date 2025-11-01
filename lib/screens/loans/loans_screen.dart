import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  List<Loan> _loans = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loans = await DataService().getUserLoans(
        status: _selectedStatus,
        page: _currentPage,
        limit: 20,
      );

      setState(() {
        if (refresh) {
          _loans = loans;
        } else {
          _loans.addAll(loans);
        }
        _hasMore = loans.length >= 20;
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
    await _loadLoans(refresh: true);
    _refreshController.refreshCompleted();
  }

  void _onLoadMore() async {
    if (!_hasMore || _isLoading) {
      _refreshController.loadNoData();
      return;
    }

    _currentPage++;
    await _loadLoans();
    _refreshController.loadComplete();
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadLoans(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loans'),
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
                  label: const Text('Active'),
                  selected: _selectedStatus == 'ACTIVE',
                  onSelected: (_) => _filterByStatus('ACTIVE'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pending'),
                  selected: _selectedStatus == 'PENDING',
                  onSelected: (_) => _filterByStatus('PENDING'),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Completed'),
                  selected: _selectedStatus == 'COMPLETED',
                  onSelected: (_) => _filterByStatus('COMPLETED'),
                ),
              ],
            ),
          ),
          // Loans List
          Expanded(
            child: _isLoading && _loans.isEmpty
                ? const LoadingIndicator(message: 'Loading loans...')
                : _errorMessage != null && _loans.isEmpty
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: () => _loadLoans(refresh: true),
                      )
                    : SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoadMore,
                        enablePullUp: true,
                        child: _loans.isEmpty
                            ? const Center(
                                child: Text(
                                  'No loans found',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              )
                            : ListView.builder(
                                itemCount: _loans.length,
                                itemBuilder: (context, index) {
                                  final loan = _loans[index];
                                  return Card(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 4,
                                    ),
                                    child: ListTile(
                                      leading: const Icon(
                                        Icons.credit_card,
                                        size: 40,
                                      ),
                                      title: Text(
                                        loan.purpose ?? 'Loan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Principal: ${Formatters.formatCurrency(loan.principal)}',
                                          ),
                                          if (loan.nextDueDate != null)
                                            Text(
                                              'Next Due: ${Formatters.formatDate(loan.nextDueDate!)}',
                                            ),
                                          Text(
                                            'Status: ${loan.status}',
                                            style: TextStyle(
                                              color: loan.isActive
                                                  ? AppTheme.successColor
                                                  : Colors.grey,
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
                                            Formatters.formatCurrency(
                                              loan.remainingBalance,
                                            ),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Monthly: ${Formatters.formatCurrency(loan.monthlyPayment)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap: () {
                                        NavigationHelper.navigateTo(
                                          context,
                                          'loan-detail',
                                          params: {'id': loan.id},
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
    );
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }
}

