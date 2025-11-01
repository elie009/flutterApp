import 'package:flutter/material.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/error_widget.dart';
import '../../utils/theme.dart';

class LoanDetailScreen extends StatefulWidget {
  final String loanId;

  const LoanDetailScreen({super.key, required this.loanId});

  @override
  State<LoanDetailScreen> createState() => _LoanDetailScreenState();
}

class _LoanDetailScreenState extends State<LoanDetailScreen> {
  Loan? _loan;
  bool _isLoading = true;
  String? _errorMessage;
  final _paymentAmountController = TextEditingController();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Loan Details'),
      ),
      body: _isLoading
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
                                        prefixText: '₱',
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
    super.dispose();
  }
}

