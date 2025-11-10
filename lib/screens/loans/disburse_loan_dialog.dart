import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

class DisburseLoanDialog extends StatefulWidget {
  final Loan loan;

  const DisburseLoanDialog({
    super.key,
    required this.loan,
  });

  @override
  State<DisburseLoanDialog> createState() => _DisburseLoanDialogState();
}

class _DisburseLoanDialogState extends State<DisburseLoanDialog> {
  String _disbursementMethod = 'BANK_TRANSFER';
  String? _selectedBankAccountId;
  final _referenceController = TextEditingController();
  List<BankAccount> _bankAccounts = [];
  bool _isLoading = false;
  bool _isLoadingAccounts = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBankAccounts();
  }

  Future<void> _loadBankAccounts() async {
    setState(() {
      _isLoadingAccounts = true;
      _errorMessage = null;
    });

    try {
      final accounts = await DataService().getBankAccounts(isActive: true);
      setState(() {
        _bankAccounts = accounts.where((acc) => acc.isActive).toList();
        _isLoadingAccounts = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load bank accounts: ${e.toString()}';
        _isLoadingAccounts = false;
      });
    }
  }

  bool get _shouldShowBankAccountField {
    return _disbursementMethod == 'BANK_TRANSFER' || _disbursementMethod == 'CASH';
  }

  BankAccount? get _selectedBankAccount {
    if (_selectedBankAccountId == null) return null;
    try {
      return _bankAccounts.firstWhere(
        (acc) => acc.id == _selectedBankAccountId,
      );
    } catch (e) {
      return null;
    }
  }

  double get _projectedNewBalance {
    final account = _selectedBankAccount;
    if (account == null) return 0.0;
    return account.currentBalance + widget.loan.principal;
  }

  Future<void> _handleDisburse() async {
    if (_isLoading) return;

    // Bank account is optional - no validation needed
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Disbursement'),
        content: _buildConfirmationContent(),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final currentUser = AuthService.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final result = await DataService().disburseLoan(
        loanId: widget.loan.id,
        disbursedBy: currentUser.id,
        disbursementMethod: _disbursementMethod,
        reference: _referenceController.text.isNotEmpty
            ? _referenceController.text
            : null,
        bankAccountId: _shouldShowBankAccountField && _selectedBankAccountId != null
            ? _selectedBankAccountId
            : null,
      );

      if (mounted) {
        if (result['success'] == true) {
          final data = result['data'] as Map<String, dynamic>;
          final bankAccountCredited = data['bankAccountCredited'] == true;
          final disbursedAmount = data['disbursedAmount'] as num?;

          String message = 'Loan disbursed successfully!';
          if (bankAccountCredited && disbursedAmount != null) {
            final account = _selectedBankAccount;
            final accountName = account?.accountName ?? 'selected account';
            message =
                'Loan disbursed and ${Formatters.formatCurrency(disbursedAmount.toDouble())} credited to $accountName!';
          } else if (_disbursementMethod == 'CASH') {
            message = 'Loan disbursed as cash. ${_selectedBankAccountId == null ? 'User will pick up cash in person.' : ''}';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppTheme.successColor,
              duration: const Duration(seconds: 4),
            ),
          );

          Navigator.of(context).pop(true); // Return true to indicate success
        } else {
          setState(() {
            _errorMessage = result['message'] as String? ?? 'Failed to disburse loan';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'An error occurred: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Widget _buildConfirmationContent() {
    final account = _selectedBankAccount;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Disburse loan of ${Formatters.formatCurrency(widget.loan.principal)}?',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text('Method: ${_disbursementMethod.replaceAll('_', ' ')}'),
        if (account != null) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          const Text(
            'Bank Account Crediting:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Account: ${account.accountName}'),
          Text(
            'Current Balance: ${Formatters.formatCurrency(account.currentBalance)}',
          ),
          Text(
            'New Balance: ${Formatters.formatCurrency(_projectedNewBalance)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.successColor,
            ),
          ),
        ] else if (_shouldShowBankAccountField) ...[
          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            _disbursementMethod == 'CASH'
                ? 'Cash disbursement - No bank account selected. User will pick up cash in person.'
                : 'Bank transfer - No bank account selected for crediting.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 720),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Disburse Loan',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Loan Amount Display
                    Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Loan Amount:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    Formatters.formatCurrency(widget.loan.principal),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Disbursement Method
            const Text(
              'Disbursement Method *',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _disbursementMethod,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'BANK_TRANSFER',
                  child: Text('Bank Transfer'),
                ),
                DropdownMenuItem(
                  value: 'CASH',
                  child: Text('Cash'),
                ),
                DropdownMenuItem(
                  value: 'CHECK',
                  child: Text('Check'),
                ),
                DropdownMenuItem(
                  value: 'CASH_PICKUP',
                  child: Text('Cash Pickup'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _disbursementMethod = value;
                    // Clear bank account selection if method doesn't support it
                    if (!_shouldShowBankAccountField) {
                      _selectedBankAccountId = null;
                    }
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            // Bank Account Selection (conditional)
            if (_shouldShowBankAccountField) ...[
              const Text(
                'Credit to Bank Account',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Optional',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              if (_isLoadingAccounts)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_bankAccounts.isEmpty)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: const Text(
                    'No active bank accounts found. Add a bank account first.',
                    style: TextStyle(color: Colors.orange),
                  ),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedBankAccountId,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  ),
                  hint: const Text('-- Select Bank Account --'),
                  items: _bankAccounts.map((account) {
                    return DropdownMenuItem<String>(
                      value: account.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            account.accountName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (account.financialInstitution != null)
                            Text(
                              '${account.financialInstitution} • Balance: ${Formatters.formatCurrency(account.currentBalance)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBankAccountId = value;
                    });
                  },
                ),
              const SizedBox(height: 12),
              if (_selectedBankAccount != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Balance Preview',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current: ${Formatters.formatCurrency(_selectedBankAccount!.currentBalance)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'After Credit: ${Formatters.formatCurrency(_projectedNewBalance)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.successColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Special info box for CASH method
              if (_disbursementMethod == 'CASH') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Cash Disbursement',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.only(left: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '• If you select a bank account, the loan amount will be credited to that account',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '• If no bank account is selected, the loan will be disbursed as cash (no automatic crediting)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              // General info for BANK_TRANSFER
              if (_disbursementMethod == 'BANK_TRANSFER') ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'If selected, the loan amount will be automatically credited to this account.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              const SizedBox(height: 16),
            ],
            // Reference Number
            const Text(
              'Reference Number (Optional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'e.g., DISB-20241201-001',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.errorColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                  ],
                ),
              ),
            ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleDisburse,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _referenceController.dispose();
    super.dispose();
  }
}

