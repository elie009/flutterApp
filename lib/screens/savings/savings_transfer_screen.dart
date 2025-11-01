import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';

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
        title: const Text('Transfer Money'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_errorMessage!),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _savingsAccount == null
                  ? const Center(child: Text('Savings account not found'))
                  : SingleChildScrollView(
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
                                                children: [
                                                  Icon(
                                                    Icons.arrow_downward,
                                                    color: _isDeposit
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Deposit',
                                                    style: TextStyle(
                                                      color: _isDeposit
                                                          ? Colors.white
                                                          : Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Bank → Savings',
                                                    style: TextStyle(
                                                      color: _isDeposit
                                                          ? Colors.white70
                                                          : Colors.grey,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
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
                                                    ? AppTheme.primaryColor
                                                    : Colors.grey[200],
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: Column(
                                                children: [
                                                  Icon(
                                                    Icons.arrow_upward,
                                                    color: !_isDeposit
                                                        ? Colors.white
                                                        : Colors.grey,
                                                  ),
                                                  const SizedBox(height: 8),
                                                  Text(
                                                    'Withdraw',
                                                    style: TextStyle(
                                                      color: !_isDeposit
                                                          ? Colors.white
                                                          : Colors.grey,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    'Savings → Bank',
                                                    style: TextStyle(
                                                      color: !_isDeposit
                                                          ? Colors.white70
                                                          : Colors.grey,
                                                      fontSize: 12,
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
                            // Savings Account Info
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Savings Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _savingsAccount!.accountName,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Current Balance:'),
                                        Text(
                                          Formatters.formatCurrency(
                                              _savingsAccount!.currentBalance),
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppTheme.primaryColor,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (!_isDeposit &&
                                        _savingsAccount!.currentBalance < 0.01)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.red.withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Row(
                                            children: [
                                              Icon(Icons.warning,
                                                  color: Colors.red, size: 16),
                                              SizedBox(width: 8),
                                              Text(
                                                'Insufficient balance',
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Bank Account Selection
                            DropdownButtonFormField<BankAccount>(
                              value: _selectedBankAccount,
                              decoration: const InputDecoration(
                                labelText: 'Bank Account *',
                                prefixIcon: Icon(Icons.account_balance),
                              ),
                              items: _bankAccounts.map((account) {
                                return DropdownMenuItem<BankAccount>(
                                  value: account,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(account.accountName),
                                      Text(
                                        Formatters.formatCurrency(
                                            account.currentBalance),
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
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
                            ),
                            const SizedBox(height: 16),
                            // Amount
                            TextFormField(
                              controller: _amountController,
                              decoration: const InputDecoration(
                                labelText: 'Amount *',
                                hintText: '0.00',
                                prefixIcon: Icon(Icons.attach_money),
                              ),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter an amount';
                                }
                                final amount = double.tryParse(value);
                                if (amount == null || amount <= 0) {
                                  return 'Please enter a valid amount';
                                }
                                if (!_isDeposit &&
                                    _savingsAccount != null &&
                                    amount > _savingsAccount!.currentBalance) {
                                  return 'Insufficient balance';
                                }
                                if (_selectedBankAccount != null &&
                                    _isDeposit &&
                                    amount >
                                        _selectedBankAccount!.currentBalance) {
                                  return 'Insufficient bank balance';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            // Description
                            TextFormField(
                              controller: _descriptionController,
                              decoration: const InputDecoration(
                                labelText: 'Description (Optional)',
                                hintText: 'Add a note about this transfer',
                                prefixIcon: Icon(Icons.description),
                              ),
                              maxLines: 2,
                            ),
                            const SizedBox(height: 32),
                            // Transfer Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed:
                                    _isTransferring ? null : _performTransfer,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16),
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
    );
  }
}

