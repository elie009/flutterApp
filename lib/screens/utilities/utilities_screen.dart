import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/utility.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/error_widget.dart';
import '../../widgets/bottom_nav_bar.dart';

class UtilitiesScreen extends StatefulWidget {
  const UtilitiesScreen({super.key});

  @override
  State<UtilitiesScreen> createState() => _UtilitiesScreenState();
}

class _UtilitiesScreenState extends State<UtilitiesScreen>
    with SingleTickerProviderStateMixin {
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Utility> _utilities = [];
  bool _isLoading = true;
  String? _errorMessage;
  String? _selectedStatus;
  String? _selectedUtilityType;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUtilities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> _loadUtilities() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await DataService().getUtilities(
        status: _selectedStatus,
        utilityType: _selectedUtilityType,
        page: 1,
        limit: 100,
      );

      setState(() {
        _utilities = result['utilities'] as List<Utility>;
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
    await _loadUtilities();
    _refreshController.refreshCompleted();
  }

  void _filterByStatus(String? status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadUtilities();
  }

  void _filterByType(String? type) {
    setState(() {
      _selectedUtilityType = type;
    });
    _loadUtilities();
  }

  List<Utility> _getFilteredUtilities() {
    switch (_tabController.index) {
      case 0:
        return _utilities;
      case 1:
        return _utilities.where((u) => u.isOverdue).toList();
      case 2:
        return _utilities.where((u) => u.isPending).toList();
      default:
        return _utilities;
    }
  }

  Future<void> _markAsPaid(Utility utility) async {
    try {
      await DataService().markUtilityAsPaid(utility.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Utility marked as paid')),
        );
        _loadUtilities();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUtilities = _getFilteredUtilities();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Utilities'),
        bottom: TabBar(
          controller: _tabController,
          onTap: (index) {
            setState(() {});
          },
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Overdue'),
            Tab(text: 'Pending'),
          ],
        ),
      ),
      body: _errorMessage != null
          ? CustomErrorWidget(
              message: _errorMessage!,
              onRetry: _loadUtilities,
            )
          : SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              child: _isLoading
                  ? _buildShimmerLoader()
                  : filteredUtilities.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filteredUtilities.length,
                          itemBuilder: (context, index) {
                            final utility = filteredUtilities[index];
                            return _buildUtilityCard(utility);
                          },
                        ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add utility screen
          NavigationHelper.navigateToAddUtility(context);
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildShimmerLoader() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Container(
              height: 120,
              width: double.infinity,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bolt_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No utilities found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first utility to get started',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityCard(Utility utility) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        utility.utilityName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${utility.provider} • ${utility.utilityType}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Chip(
                  label: Text(utility.status),
                  backgroundColor: utility.isPaid
                      ? Colors.green[100]
                      : utility.isOverdue
                          ? Colors.red[100]
                          : Colors.orange[100],
                  labelStyle: TextStyle(
                    color: utility.isPaid
                        ? Colors.green[800]
                        : utility.isOverdue
                            ? Colors.red[800]
                            : Colors.orange[800],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (utility.consumption != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Consumption: ${utility.consumption!.toStringAsFixed(2)} ${utility.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            if (utility.costPerUnit != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  'Cost per unit: ${Formatters.formatCurrency(utility.costPerUnit!)}/${utility.unit ?? ''}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Formatters.formatCurrency(utility.amount),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due: ${Formatters.formatDate(utility.dueDate)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                if (utility.status == 'PENDING')
                  ElevatedButton(
                    onPressed: () => _markAsPaid(utility),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Mark Paid'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

