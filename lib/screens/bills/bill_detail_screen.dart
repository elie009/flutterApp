import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/bill.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class BillDetailScreen extends StatefulWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  Bill? _bill;
  List<Bill> _childBills = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBill();
  }

  Future<void> _loadBill() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final bill = await DataService().getBill(widget.billId);
      
      // Load all bills to find child bills
      final billsResult = await DataService().getBills(page: 1, limit: 100);
      final allBills = billsResult['bills'] as List<Bill>;
      
      // Find child bills (bills with parentBillId matching this bill's id)
      final childBills = allBills
          .where((b) => b.parentBillId == bill.id)
          .toList();
      
      // Sort child bills by due date
      childBills.sort((a, b) => a.dueDate.compareTo(b.dueDate));
      
      setState(() {
        _bill = bill;
        _childBills = childBills;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsPaid() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text('Mark "${_bill?.billName}" as paid?'),
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

    if (confirmed == true && _bill != null) {
      final success = await DataService().markBillAsPaid(_bill!.id);
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Bill marked as paid',
          backgroundColor: AppTheme.successColor,
        );
        _loadBill();
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
                'Bill Details',
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
          ? _buildSkeletonLoader()
          : _errorMessage != null
              ? ErrorDisplay(
                  message: _errorMessage!,
                  onRetry: _loadBill,
                )
              : _bill == null
                  ? const Center(
                      child: Text('Bill not found'),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          _bill!.billName,
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _bill!.isOverdue
                                              ? AppTheme.errorColor
                                              : _bill!.isPaid
                                                  ? AppTheme.successColor
                                                  : AppTheme.warningColor,
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          _bill!.status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Amount',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        Formatters.formatCurrency(_bill!.amount),
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    'Due Date',
                                    Formatters.formatDate(_bill!.dueDate),
                                  ),
                                  const Divider(),
                                  if (_bill!.provider != null)
                                    _buildDetailRow(
                                      'Provider',
                                      _bill!.provider!,
                                    ),
                                  if (_bill!.provider != null)
                                    const Divider(),
                                  if (_bill!.billType != null)
                                    _buildDetailRow(
                                      'Type',
                                      _bill!.billType!,
                                    ),
                                  if (_bill!.billType != null)
                                    const Divider(),
                                  if (_bill!.frequency != null)
                                    _buildDetailRow(
                                      'Frequency',
                                      _bill!.frequency!,
                                    ),
                                  if (_bill!.frequency != null)
                                    const Divider(),
                                  if (_bill!.notes != null)
                                    _buildDetailRow(
                                      'Notes',
                                      _bill!.notes!,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          if (_childBills.isNotEmpty) ...[
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Scheduled Bills',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    ...(_childBills.map((bill) => Padding(
                                          padding: const EdgeInsets.only(bottom: 12),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      bill.billName,
                                                      style: const TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Due: ${Formatters.formatDate(bill.dueDate)}',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: bill.isOverdue
                                                            ? AppTheme.errorColor
                                                            : Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    Formatters.formatCurrency(
                                                        bill.amount),
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: bill.isOverdue
                                                          ? AppTheme.errorColor
                                                          : bill.isPaid
                                                              ? AppTheme
                                                                  .successColor
                                                              : AppTheme
                                                                  .warningColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
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
                                            ],
                                          ),
                                        ))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          if (!_bill!.isPaid) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _markAsPaid,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text(
                                  'Mark as Paid',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: _buildSkeletonBox(width: double.infinity, height: 24)),
                      const SizedBox(width: 12),
                      _buildSkeletonBox(width: 80, height: 32, borderRadius: BorderRadius.circular(16)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSkeletonBox(width: 60, height: 14),
                      _buildSkeletonBox(width: 100, height: 28),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Details card skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRowSkeleton(),
                  const SizedBox(height: 8),
                  _buildDivider(),
                  const SizedBox(height: 8),
                  _buildDetailRowSkeleton(),
                  const SizedBox(height: 8),
                  _buildDivider(),
                  const SizedBox(height: 8),
                  _buildDetailRowSkeleton(),
                  const SizedBox(height: 8),
                  _buildDivider(),
                  const SizedBox(height: 8),
                  _buildDetailRowSkeleton(),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Scheduled bills skeleton
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(width: 140, height: 20),
                  const SizedBox(height: 16),
                  ...List.generate(3, (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSkeletonBox(width: 100, height: 16),
                                  const SizedBox(height: 8),
                                  _buildSkeletonBox(width: 80, height: 12),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _buildSkeletonBox(width: 80, height: 16),
                                const SizedBox(height: 8),
                                _buildSkeletonBox(width: 60, height: 24, borderRadius: BorderRadius.circular(8)),
                              ],
                            ),
                          ],
                        ),
                      )),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Button skeleton
          _buildSkeletonBox(width: double.infinity, height: 56, borderRadius: BorderRadius.circular(12)),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }

  Widget _buildDetailRowSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSkeletonBox(width: 80, height: 14),
        _buildSkeletonBox(width: 100, height: 14),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

