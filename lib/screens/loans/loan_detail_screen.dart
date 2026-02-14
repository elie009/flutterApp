import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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
  bool _isEditing = false;
  bool _isSaving = false;
  final _paymentAmountController = TextEditingController();
  final _purposeController = TextEditingController();
  final _additionalInfoController = TextEditingController();
  String? _editStatus;

  @override
  void initState() {
    super.initState();
    _loadLoan();
  }

  /// Safe read of additionalInfo via JSON (avoids lookup error if old Loan model has no additionalInfo getter).
  static String? _getAdditionalInfo(Loan loan) {
    return loan.toJson()['additionalInfo'] as String?;
  }

  void _syncEditFieldsFromLoan() {
    if (_loan != null) {
      _purposeController.text = _loan!.purpose ?? '';
      _additionalInfoController.text = _getAdditionalInfo(_loan!) ?? '';
      _editStatus = _loan!.status;
    }
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
        _syncEditFieldsFromLoan();
      });
    } catch (e) {
      final msg = e.toString();
      setState(() {
        _errorMessage = msg.toLowerCase().contains('forbidden')
            ? 'You don\'t have access to this loan. Make sure you\'re on the latest app version, then pull to refresh or tap Retry.'
            : msg;
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEdits() async {
    if (_loan == null) return;
    setState(() => _isSaving = true);
    try {
      final updated = await DataService().updateLoan(
        widget.loanId,
        purpose: _purposeController.text.trim().isEmpty
            ? null
            : _purposeController.text.trim(),
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
        status: _editStatus,
      );
      if (mounted) {
        setState(() {
          _loan = updated;
          _isEditing = false;
          _isSaving = false;
        });
        NavigationHelper.showSnackBar(
          context,
          'Loan updated',
          backgroundColor: AppTheme.successColor,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        NavigationHelper.showSnackBar(
          context,
          e.toString().replaceFirst('Exception: ', ''),
          backgroundColor: AppTheme.errorColor,
        );
      }
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

  static const _statusOptions = ['PENDING', 'APPROVED', 'ACTIVE', 'COMPLETED'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Loan Details'),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primaryDark,
        elevation: 0,
        leadingWidth: 56,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _isSaving
              ? null
              : () {
                  if (_isEditing && _loan != null && !_isLoading && _errorMessage == null) {
                    setState(() => _isEditing = false);
                  } else {
                    // Navigate to loans list (loan-detail was opened with goNamed, so pop would fail)
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) context.pop();
                    });
                  }
                },
          tooltip: 'Back',
        ),
        actions: [
          if (_loan != null && !_isLoading && _errorMessage == null)
            _isEditing
                ? IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _isSaving
                        ? null
                        : () => setState(() => _isEditing = false),
                  )
                : IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => setState(() => _isEditing = true),
                  ),
        ],
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
                            color: Colors.white,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_isEditing) ...[
                                    const Text(
                                      'Purpose',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _purposeController,
                                      enabled: !_isSaving,
                                      style: const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Loan purpose/title',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Additional Info',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    TextField(
                                      controller: _additionalInfoController,
                                      enabled: !_isSaving,
                                      maxLines: 3,
                                      style: const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        hintText: 'Notes or description',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'Status',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    DropdownButtonFormField<String>(
                                      value: _editStatus,
                                      dropdownColor: Colors.white,
                                      style: const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                      ),
                                      items: _statusOptions
                                          .map((s) => DropdownMenuItem(
                                                value: s,
                                                child: Text(s, style: const TextStyle(color: Colors.black)),
                                              ))
                                          .toList(),
                                      onChanged: _isSaving
                                          ? null
                                          : (v) {
                                              if (v != null) {
                                                setState(() => _editStatus = v);
                                              }
                                            },
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        TextButton(
                                          onPressed: _isSaving
                                              ? null
                                              : () =>
                                                  setState(() => _isEditing = false),
                                          child: const Text('Cancel'),
                                        ),
                                        const SizedBox(width: 8),
                                        ElevatedButton(
                                          onPressed: _isSaving ? null : _saveEdits,
                                          child: _isSaving
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Text('Save'),
                                        ),
                                      ],
                                    ),
                                  ] else ...[
                                    Text(
                                      _loan!.purpose ?? 'Loan',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    if (_getAdditionalInfo(_loan!) != null &&
                                        _getAdditionalInfo(_loan!)!.isNotEmpty) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        _getAdditionalInfo(_loan!)!,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Remaining Balance',
                                          style: TextStyle(
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          Formatters.formatCurrency(
                                            _loan!.remainingBalance,
                                          ),
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Card(
                            color: Colors.white,
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
                              color: Colors.white,
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
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    TextField(
                                      controller: _paymentAmountController,
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      style: const TextStyle(color: Colors.black),
                                      decoration: const InputDecoration(
                                        filled: true,
                                        fillColor: Colors.white,
                                        labelText: 'Payment Amount',
                                        labelStyle: TextStyle(color: Colors.black87),
                                        prefixText: '₱',
                                        prefixStyle: TextStyle(color: Colors.black),
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
                                            color: Colors.black,
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
            color: Colors.black87,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _paymentAmountController.dispose();
    _purposeController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }
}

