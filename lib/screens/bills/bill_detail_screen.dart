import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/bill.dart';
import '../../models/bill_forecast.dart';
import '../../models/bill_variance.dart';
import '../../models/bank_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/double_entry_validation.dart';

class BillDetailScreen extends StatefulWidget {
  final String billId;

  const BillDetailScreen({super.key, required this.billId});

  @override
  State<BillDetailScreen> createState() => _BillDetailScreenState();
}

class _BillDetailScreenState extends State<BillDetailScreen> {
  Bill? _bill;
  List<Bill> _childBills = [];
  BillForecast? _forecast;
  BillVariance? _variance;
  bool _isLoading = true;
  bool _isLoadingForecast = false;
  bool _isLoadingVariance = false;
  String? _errorMessage;
  List<BankAccount> _bankAccounts = [];
  bool _isLoadingAccounts = false;

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

      // Load forecast and variance if provider and billType are available
      if (bill.provider != null && bill.billType != null) {
        _loadForecast(bill.provider!, bill.billType!);
        _loadVariance(bill.id);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadForecast(String provider, String billType) async {
    setState(() {
      _isLoadingForecast = true;
    });

    try {
      final forecast = await DataService().getBillForecast(
        provider: provider,
        billType: billType,
        method: 'weighted',
      );

      if (mounted) {
        setState(() {
          _forecast = forecast;
          _isLoadingForecast = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingForecast = false;
        });
      }
    }
  }

  Future<void> _loadVariance(String billId) async {
    setState(() {
      _isLoadingVariance = true;
    });

    try {
      final variance = await DataService().getBillVariance(billId);

      if (mounted) {
        setState(() {
          _variance = variance;
          _isLoadingVariance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingVariance = false;
        });
      }
    }
  }

  Future<void> _loadBankAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
    });

    try {
      final accounts = await DataService().getBankAccounts(isActive: true);
      setState(() {
        _bankAccounts = accounts;
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAccounts = false;
      });
    }
  }

  List<BankAccount> _getAvailableAccounts() {
    if (_bill == null) return [];
    final billAmount = _bill!.amount;
    return _bankAccounts.where((account) {
      return account.isActive && account.currentBalance >= billAmount;
    }).toList();
  }

  Future<void> _markAsPaid() async {
    if (_bill == null) return;

    // Load bank accounts if not already loaded
    if (_bankAccounts.isEmpty) {
      await _loadBankAccounts();
    }

    final availableAccounts = _getAvailableAccounts();
    
    if (availableAccounts.isEmpty) {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'No bank accounts with sufficient balance. Bill amount: ${Formatters.formatCurrency(_bill!.amount)}',
          backgroundColor: AppTheme.errorColor,
        );
      }
      return;
    }

    // Show bank account selection dialog
    String? selectedAccountId;
    String? notes;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Mark Bill as Paid'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bill: ${_bill?.billName}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Amount: ${Formatters.formatCurrency(_bill?.amount ?? 0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Bank Account (Double-entry: Debit Expense, Credit Bank Account)',
                      style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 8),
                    if (_isLoadingAccounts)
                      const Center(child: CircularProgressIndicator())
                    else
                      DropdownButtonFormField<String>(
                        value: selectedAccountId,
                        decoration: const InputDecoration(
                          labelText: 'Bank Account',
                          border: OutlineInputBorder(),
                        ),
                        items: availableAccounts.map((account) {
                          return DropdownMenuItem<String>(
                            value: account.id,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(account.accountName),
                                ),
                                Text(
                                  Formatters.formatCurrency(account.currentBalance),
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setDialogState(() {
                            selectedAccountId = value;
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        notes = value.isEmpty ? null : value;
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: selectedAccountId == null
                      ? null
                      : () {
                          // Double-entry validation
                          final selectedAccount = availableAccounts.firstWhere(
                            (acc) => acc.id == selectedAccountId,
                          );

                          if (selectedAccount.currentBalance < _bill!.amount) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Insufficient balance. Required: ${Formatters.formatCurrency(_bill!.amount)}, Available: ${Formatters.formatCurrency(selectedAccount.currentBalance)}',
                                ),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                            return;
                          }

                          // Validate double-entry: Debit = Credit = Bill Amount
                          final validation = validateDoubleEntry(
                            transactionType: 'DEBIT',
                            amount: _bill!.amount,
                            bankAccountId: selectedAccountId!,
                            billId: _bill!.id,
                            category: 'BILL_PAYMENT',
                          );

                          if (!validation.isValid) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Double-entry validation failed: ${validation.errors.join(", ")}',
                                ),
                                backgroundColor: AppTheme.errorColor,
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).pop(true);
                        },
                  child: const Text('Mark as Paid'),
                ),
              ],
            );
          },
        );
      },
    );

    if (confirmed == true && _bill != null && selectedAccountId != null) {
      final success = await DataService().markBillAsPaid(
        _bill!.id,
        notes: notes,
        bankAccountId: selectedAccountId,
      );
      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Bill marked as paid with double-entry accounting',
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
                          // Forecast Section
                          if (_bill!.provider != null && _bill!.billType != null) ...[
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.trending_up,
                                          color: AppTheme.primaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Next Month Forecast',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    if (_isLoadingForecast)
                                      const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: CircularProgressIndicator(),
                                        ),
                                      )
                                    else if (_forecast != null) ...[
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Estimated Amount',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Text(
                                            Formatters.formatCurrency(
                                                _forecast!.estimatedAmount),
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: AppTheme.primaryColor,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Method',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppTheme.primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _forecast!.methodDisplay,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Confidence',
                                            style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: _forecast!.confidence
                                                          .toLowerCase() ==
                                                      'high'
                                                  ? AppTheme.successColor
                                                      .withOpacity(0.2)
                                                  : _forecast!.confidence
                                                              .toLowerCase() ==
                                                          'medium'
                                                      ? AppTheme.warningColor
                                                          .withOpacity(0.2)
                                                      : AppTheme.errorColor
                                                          .withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              _forecast!.confidenceDisplay,
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: _forecast!.confidence
                                                            .toLowerCase() ==
                                                        'high'
                                                    ? AppTheme.successColor
                                                    : _forecast!.confidence
                                                                .toLowerCase() ==
                                                            'medium'
                                                        ? AppTheme.warningColor
                                                        : AppTheme.errorColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (_forecast!.recommendation.isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        const Divider(),
                                        const SizedBox(height: 8),
                                        Text(
                                          _forecast!.recommendation,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ],
                                    ]
                                    else
                                      const Text(
                                        'Forecast not available',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontSize: 14,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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

