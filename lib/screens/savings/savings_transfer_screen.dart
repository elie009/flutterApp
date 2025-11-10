import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class SavingsTransferScreen extends StatefulWidget {
  final String savingsAccountId;

  const SavingsTransferScreen({
    super.key,
    required this.savingsAccountId,
  });

  @override
  State<SavingsTransferScreen> createState() => _SavingsTransferScreenState();
}

class _SavingsTransferScreenState extends State<SavingsTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  SavingsAccount? _savingsAccount;
  List<BankAccount> _bankAccounts = [];
  BankAccount? _selectedBankAccount;
  bool _isDeposit = true; // true = deposit to savings, false = withdraw from savings
  bool _isLoading = true;
  bool _isTransferring = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final savingsAccount = await DataService().getSavingsAccount(widget.savingsAccountId);
      final bankAccounts = await DataService().getBankAccounts(isActive: true);

      setState(() {
        _savingsAccount = savingsAccount;
        _bankAccounts = bankAccounts.where((a) => a.isActive).toList();
        if (_bankAccounts.isNotEmpty) {
          _selectedBankAccount = _bankAccounts.first;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _performTransfer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    setState(() {
      _isTransferring = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final description = _descriptionController.text.trim().isEmpty
          ? (_isDeposit
              ? 'Transfer to ${_savingsAccount!.accountName}'
              : 'Withdrawal from ${_savingsAccount!.accountName}')
          : _descriptionController.text.trim();

      bool success;
      if (_isDeposit) {
        // Transfer from bank to savings
        success = await DataService().transferBankToSavings(
          bankAccountId: _selectedBankAccount!.id,
          savingsAccountId: widget.savingsAccountId,
          amount: amount,
          description: description,
        );
      } else {
        // Transfer from savings to bank
        success = await DataService().transferSavingsToBank(
          savingsAccountId: widget.savingsAccountId,
          bankAccountId: _selectedBankAccount!.id,
          amount: amount,
          description: description,
        );
      }

      if (mounted) {
        if (success) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isDeposit
                  ? 'Money transferred to savings'
                  : 'Money withdrawn from savings'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transfer failed')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTransferring = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Savings Transfer'),
      ),
      backgroundColor: const Color(0xFFE8F5E9),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red[400],
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.red[400]),
                        ),
                      ],
                    ),
                  ),
                )
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Transfer Type Toggle
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Transfer Type',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isDeposit = true;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: _isDeposit
                                                  ? AppTheme.primaryColor
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: const [
                                                Icon(Icons.arrow_downward,
                                                    color: Colors.white),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Deposit to Savings',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _isDeposit = false;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: !_isDeposit
                                                  ? AppTheme.errorColor
                                                  : Colors.grey[200],
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Column(
                                              children: const [
                                                Icon(Icons.arrow_upward,
                                                    color: Colors.white),
                                                SizedBox(height: 8),
                                                Text(
                                                  'Withdraw from Savings',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          if (_savingsAccount != null)
                            _buildAccountSummaryCard(_savingsAccount!),
                          const SizedBox(height: 16),
                          if (_bankAccounts.isNotEmpty)
                            _buildBankAccountSelector(),
                          const SizedBox(height: 16),
                          _buildAmountField(),
                          const SizedBox(height: 16),
                          _buildDescriptionField(),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed:
                                  _isTransferring ? null : _performTransfer,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: _isTransferring
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
                                      _isDeposit
                                          ? 'Transfer to Savings'
                                          : 'Withdraw from Savings',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  Widget _buildAccountSummaryCard(SavingsAccount account) {
    final progress = account.targetAmount > 0
        ? (account.currentBalance / account.targetAmount).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  account.accountName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  Formatters.formatCurrency(account.currentBalance),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (account.targetAmount > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progress'),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Target: ${Formatters.formatCurrency(account.targetAmount)} by ${Formatters.formatDate(account.targetDate)}',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankAccountSelector() {
    return DropdownButtonFormField<BankAccount>(
      value: _selectedBankAccount,
      decoration: const InputDecoration(
        labelText: 'Linked Bank Account *',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.account_balance_wallet),
      ),
      items: _bankAccounts.map((account) {
        return DropdownMenuItem<BankAccount>(
          value: account,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                account.accountName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${account.financialInstitution ?? 'Personal'} • Balance: ${Formatters.formatCurrency(account.currentBalance)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (account) {
        setState(() {
          _selectedBankAccount = account;
        });
      },
      validator: (value) {
        if (value == null) {
          return 'Please select a bank account';
        }
        return null;
      },
    );
  }

  Widget _buildAmountField() {
    return TextFormField(
      controller: _amountController,
      decoration: const InputDecoration(
        labelText: 'Amount *',
        hintText: '0.00',
        prefixIcon: Icon(Icons.attach_money),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter an amount';
        }
        final amount = double.tryParse(value);
        if (amount == null || amount <= 0) {
          return 'Please enter a valid amount';
        }
        if (!_isDeposit && _savingsAccount != null &&
            amount > _savingsAccount!.currentBalance) {
          return 'Insufficient balance';
        }
        if (_selectedBankAccount != null && _isDeposit &&
            amount > _selectedBankAccount!.currentBalance) {
          return 'Insufficient bank balance';
        }
        return null;
      },
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description (Optional)',
        hintText: 'Add a note about this transfer',
        prefixIcon: Icon(Icons.description),
      ),
      maxLines: 2,
    );
  }
}


