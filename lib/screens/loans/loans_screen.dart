import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/skeleton_loader.dart';
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

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header Section
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonBox(width: 120, height: 28),
                const SizedBox(height: 20),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      SkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(16)),
                      const SizedBox(width: 8),
                      SkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(16)),
                      const SizedBox(width: 8),
                      SkeletonBox(width: 60, height: 32, borderRadius: BorderRadius.circular(16)),
                      const SizedBox(width: 8),
                      SkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.circular(16)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Loans list skeleton
          ...List.generate(5, (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    SkeletonBox(width: 50, height: 50, borderRadius: BorderRadius.circular(10)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SkeletonBox(width: double.infinity, height: 16),
                          const SizedBox(height: 8),
                          SkeletonBox(width: 120, height: 12),
                          const SizedBox(height: 8),
                          SkeletonBox(width: 80, height: 12),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        SkeletonBox(width: 80, height: 16),
                        const SizedBox(height: 4),
                        SkeletonBox(width: 100, height: 12),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8F5E9),
      body: _isLoading && _loans.isEmpty
          ? _buildSkeletonLoader()
          : _errorMessage != null && _loans.isEmpty
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: () => _loadLoans(refresh: true),
                )
              : Column(
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
                        bottom: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'My Loans',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          // Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                FilterChip(
                                  label: const Text('All'),
                                  selected: _selectedStatus == null,
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedStatus == null
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                  ),
                                  onSelected: (_) => _filterByStatus(null),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Active'),
                                  selected: _selectedStatus == 'ACTIVE',
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedStatus == 'ACTIVE'
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                  ),
                                  onSelected: (_) => _filterByStatus('ACTIVE'),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Pending'),
                                  selected: _selectedStatus == 'PENDING',
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedStatus == 'PENDING'
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                  ),
                                  onSelected: (_) => _filterByStatus('PENDING'),
                                ),
                                const SizedBox(width: 8),
                                FilterChip(
                                  label: const Text('Completed'),
                                  selected: _selectedStatus == 'COMPLETED',
                                  selectedColor: Colors.white,
                                  labelStyle: TextStyle(
                                    color: _selectedStatus == 'COMPLETED'
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                  ),
                                  onSelected: (_) => _filterByStatus('COMPLETED'),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Loans List
                    Expanded(
                      child: SmartRefresher(
                        controller: _refreshController,
                        onRefresh: _onRefresh,
                        onLoading: _onLoadMore,
                        enablePullUp: true,
                        child: _loans.isEmpty
                            ? const Center(
                                child: Text(
                                  'No loans found',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                itemCount: _loans.length,
                                itemBuilder: (context, index) {
                                  final loan = _loans[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: ListTile(
                                      contentPadding: const EdgeInsets.all(16),
                                      leading: Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          Icons.account_balance_rounded,
                                          color: Color(0xFF10B981),
                                          size: 28,
                                        ),
                                      ),
                                      title: Text(
                                        loan.purpose ?? 'Loan',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            'Principal: ${Formatters.formatCurrency(loan.principal)}',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          if (loan.nextDueDate != null)
                                            Text(
                                              'Due: ${Formatters.formatDate(loan.nextDueDate!)}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: loan.isActive
                                                  ? AppTheme.successColor.withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              loan.status,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: loan.isActive
                                                    ? AppTheme.successColor
                                                    : Colors.grey,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      trailing: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            Formatters.formatCurrency(loan.remainingBalance),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Color(0xFF10B981),
                                            ),
                                          ),
                                          Text(
                                            '${Formatters.formatCurrency(loan.monthlyPayment)}/mo',
                                            style: const TextStyle(
                                              fontSize: 11,
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

