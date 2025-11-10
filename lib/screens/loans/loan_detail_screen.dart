import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'disburse_loan_dialog.dart';

class LoanDetailScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  Loan? _loan;
  bool _isLoading = true;
  bool _isUpdating = false;
  String? _errorMessage;
  bool _manualMode = false;
  static const List<String> _loanStatusOptions = [
    'PENDING',
    'APPROVED',
    'REJECTED',
    'DISBURSED',
    'ACTIVE',
    'COMPLETED',
    'CANCELLED',
    'DEFAULTED',
  ];
  String? _selectedStatus;
  final _paymentAmountController = TextEditingController();
  final _interestRateController = TextEditingController();
  final _monthlyPaymentController = TextEditingController();
  final _remainingBalanceController = TextEditingController();
  final _purposeController = TextEditingController();
  final _additionalInfoController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLoan();
  }

  Future<void> _loadLoan() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final loan = await DataService().getLoan(widget.loanId);
      setState(() {
        _loan = loan;
        _isLoading = false;
        _paymentAmountController.text =
            loan.monthlyPayment.toStringAsFixed(2);
        _interestRateController.text = loan.interestRate.toStringAsFixed(2);
        _monthlyPaymentController.text = loan.monthlyPayment.toStringAsFixed(2);
        _remainingBalanceController.text = loan.remainingBalance.toStringAsFixed(2);
        _purposeController.text = loan.purpose ?? '';
        _additionalInfoController.text = '';
        _selectedStatus = loan.status;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _makePayment() async {
    final amount = double.tryParse(_paymentAmountController.text);
    if (amount == null || amount <= 0) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter a valid amount',
        backgroundColor: AppTheme.errorColor,
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Make Payment'),
        content: Text(
          'Make payment of ${Formatters.formatCurrency(amount)}?',
        ),
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
      final success = await DataService().makeLoanPayment(
        loanId: widget.loanId,
        amount: amount,
        method: 'BANK_TRANSFER',
      );

      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Payment processed successfully',
          backgroundColor: AppTheme.successColor,
        );
        _loadLoan();
      } else if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Payment failed',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  Future<void> _updateLoan() async {
    if (_loan == null) return;

    setState(() {
      _isUpdating = true;
    });

    try {
      final interestRate = double.tryParse(_interestRateController.text);
      final updatedLoan = await DataService().updateLoan(
        loanId: widget.loanId,
        purpose: _purposeController.text.isNotEmpty ? _purposeController.text : null,
        additionalInfo: _additionalInfoController.text.isNotEmpty ? _additionalInfoController.text : null,
        status: _selectedStatus,
        interestRate: interestRate,
        monthlyPayment: _manualMode ? double.tryParse(_monthlyPaymentController.text) : null,
        remainingBalance: _manualMode ? double.tryParse(_remainingBalanceController.text) : null,
      );

      setState(() {
        _loan = updatedLoan;
        _isUpdating = false;
        _manualMode = false;
      });

      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Loan updated successfully',
          backgroundColor: AppTheme.successColor,
        );
        _loadLoan();
      }
    } catch (e) {
      setState(() {
        _isUpdating = false;
      });
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Failed to update loan: ${e.toString()}',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  Future<void> _showDisburseDialog() async {
    if (_loan == null) return;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => DisburseLoanDialog(loan: _loan!),
    );

    // If disbursement was successful, reload the loan
    if (result == true && mounted) {
      _loadLoan();
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
                'Loan Details',
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
                ? const LoadingIndicator(message: 'Loading loan details...')
                : _errorMessage != null
                    ? ErrorDisplay(
                        message: _errorMessage!,
                        onRetry: _loadLoan,
                      )
                    : _loan == null
                        ? const Center(
                            child: Text('Loan not found'),
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
                                  Text(
                                    _loan!.purpose ?? 'Loan',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Remaining Balance',
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      Text(
                                        Formatters.formatCurrency(
                                          _loan!.remainingBalance,
                                        ),
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
                                    'Principal',
                                    Formatters.formatCurrency(_loan!.principal),
                                  ),
                                  const Divider(),
                                  _buildDetailRow(
                                    'Interest Rate',
                                    '${_loan!.interestRate}%',
                                  ),
                                  const Divider(),
                                  _buildDetailRow(
                                    'Term',
                                    '${_loan!.term} months',
                                  ),
                                  const Divider(),
                                  _buildDetailRow(
                                    'Monthly Payment',
                                    Formatters.formatCurrency(
                                      _loan!.monthlyPayment,
                                    ),
                                  ),
                                  const Divider(),
                                  _buildDetailRow(
                                    'Status',
                                    _loan!.status,
                                  ),
                                  if (_loan!.nextDueDate != null) ...[
                                    const Divider(),
                                    _buildDetailRow(
                                      'Next Due Date',
                                      Formatters.formatDate(_loan!.nextDueDate!),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Manage Loan',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CheckboxListTile(
                                          value: _manualMode,
                                          onChanged: (value) {
                                            setState(() {
                                              _manualMode = value ?? false;
                                            });
                                          },
                                          title: const Text(
                                            'Manual Override Mode',
                                            style: TextStyle(fontSize: 14),
                                          ),
                                          contentPadding: EdgeInsets.zero,
                                          controlAffinity: ListTileControlAffinity.leading,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _manualMode
                                        ? 'Manual mode is ON. You can override all values.'
                                        : 'When manual mode is OFF, only interest rate can be changed and backend will calculate everything.',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _interestRateController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Interest Rate (%)',
                                      border: OutlineInputBorder(),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  DropdownButtonFormField<String>(
                                    value: _selectedStatus,
                                    decoration: const InputDecoration(
                                      labelText: 'Loan Status',
                                      border: OutlineInputBorder(),
                                    ),
                                    items: [
                                      ..._loanStatusOptions,
                                      if (_selectedStatus != null &&
                                          !_loanStatusOptions.contains(_selectedStatus))
                                        _selectedStatus!,
                                    ]
                                        .map(
                                          (status) => DropdownMenuItem<String>(
                                            value: status,
                                            child: Text(status),
                                          ),
                                        )
                                        .toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedStatus = value;
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _monthlyPaymentController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Monthly Payment',
                                      border: const OutlineInputBorder(),
                                      helperText: _manualMode ? null : 'Auto-calculated by backend',
                                    ),
                                    enabled: _manualMode,
                                  ),
                                  const SizedBox(height: 16),
                                  TextField(
                                    controller: _remainingBalanceController,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                      labelText: 'Remaining Balance',
                                      border: const OutlineInputBorder(),
                                      helperText: _manualMode ? null : 'Auto-calculated by backend',
                                    ),
                                    enabled: _manualMode,
                                  ),
                                  const SizedBox(height: 16),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: _isUpdating ? null : _updateLoan,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.primaryColor,
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: _isUpdating
                                          ? const SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Text(
                                              'Update Loan',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Disburse Loan Button (for PENDING or APPROVED loans)
                          if (_loan!.status == 'PENDING' || _loan!.status == 'APPROVED') ...[
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Disburse Loan',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Disburse the loan amount. You can optionally credit it directly to a bank account.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _showDisburseDialog,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.primaryColor,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Disburse Loan',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          // Make Payment Section (for ACTIVE loans)
                          if (_loan!.isActive) ...[
                            const SizedBox(height: 16),
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Make Payment',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _paymentAmountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      decoration: const InputDecoration(
                                        labelText: 'Payment Amount',
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _makePayment,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppTheme.successColor,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                        ),
                                        child: const Text(
                                          'Process Payment',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _interestRateController.dispose();
    _monthlyPaymentController.dispose();
    _remainingBalanceController.dispose();
    _purposeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}

