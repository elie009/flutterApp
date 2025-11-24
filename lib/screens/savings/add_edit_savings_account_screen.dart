import 'package:flutter/material.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class AddEditSavingsAccountScreen extends StatefulWidget {
  final SavingsAccount? savingsAccount;

  const AddEditSavingsAccountScreen({
    super.key,
    this.savingsAccount,
  });

  @override
  State<AddEditSavingsAccountScreen> createState() => _AddEditSavingsAccountScreenState();
}

class _AddEditSavingsAccountScreenState extends State<AddEditSavingsAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _targetAmountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _goalController = TextEditingController();
  final _interestRateController = TextEditingController();

  String _selectedSavingsType = 'EMERGENCY';
  String _selectedAccountType = 'REGULAR';
  String _selectedCompoundingFrequency = 'MONTHLY';
  DateTime _selectedTargetDate = DateTime.now().add(const Duration(days: 365));
  String _currency = 'USD';
  bool _isSaving = false;

  final List<Map<String, dynamic>> _savingsTypes = [
    {'value': 'EMERGENCY', 'label': 'Emergency Fund'},
    {'value': 'VACATION', 'label': 'Vacation'},
    {'value': 'INVESTMENT', 'label': 'Investment'},
    {'value': 'RETIREMENT', 'label': 'Retirement'},
    {'value': 'EDUCATION', 'label': 'Education'},
    {'value': 'HOME_DOWN_PAYMENT', 'label': 'Home Down Payment'},
    {'value': 'CAR_PURCHASE', 'label': 'Car Purchase'},
    {'value': 'WEDDING', 'label': 'Wedding'},
    {'value': 'TRAVEL', 'label': 'Travel'},
    {'value': 'BUSINESS', 'label': 'Business'},
    {'value': 'HEALTH', 'label': 'Health'},
    {'value': 'TAX_SAVINGS', 'label': 'Tax Savings'},
    {'value': 'GENERAL', 'label': 'General'},
  ];

  final List<Map<String, dynamic>> _accountTypes = [
    {'value': 'REGULAR', 'label': 'Regular'},
    {'value': 'HIGH_YIELD', 'label': 'High-Yield'},
    {'value': 'CD', 'label': 'Certificate of Deposit (CD)'},
    {'value': 'MONEY_MARKET', 'label': 'Money Market'},
  ];

  final List<Map<String, dynamic>> _compoundingFrequencies = [
    {'value': 'DAILY', 'label': 'Daily'},
    {'value': 'MONTHLY', 'label': 'Monthly'},
    {'value': 'QUARTERLY', 'label': 'Quarterly'},
    {'value': 'ANNUALLY', 'label': 'Annually'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.savingsAccount != null) {
      _accountNameController.text = widget.savingsAccount!.accountName;
      _targetAmountController.text = widget.savingsAccount!.targetAmount.toStringAsFixed(2);
      _descriptionController.text = widget.savingsAccount!.description ?? '';
      _goalController.text = widget.savingsAccount!.goal ?? '';
      _selectedSavingsType = widget.savingsAccount!.savingsType;
      _selectedAccountType = widget.savingsAccount!.accountType ?? 'REGULAR';
      _interestRateController.text = widget.savingsAccount!.interestRate != null
          ? (widget.savingsAccount!.interestRate! * 100).toStringAsFixed(2)
          : '';
      _selectedCompoundingFrequency = widget.savingsAccount!.interestCompoundingFrequency ?? 'MONTHLY';
      _selectedTargetDate = widget.savingsAccount!.targetDate;
      _currency = widget.savingsAccount!.currency;
    }
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _targetAmountController.dispose();
    _descriptionController.dispose();
    _goalController.dispose();
    _interestRateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null && picked != _selectedTargetDate) {
      setState(() {
        _selectedTargetDate = picked;
      });
    }
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final accountData = {
        'accountName': _accountNameController.text.trim(),
        'savingsType': _selectedSavingsType,
        'accountType': _selectedAccountType,
        'interestRate': _interestRateController.text.trim().isNotEmpty
            ? double.parse(_interestRateController.text) / 100
            : null,
        'interestCompoundingFrequency': _interestRateController.text.trim().isNotEmpty
            ? _selectedCompoundingFrequency
            : null,
        'targetAmount': double.parse(_targetAmountController.text),
        'description': _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        'goal': _goalController.text.trim().isEmpty
            ? null
            : _goalController.text.trim(),
        'targetDate': _selectedTargetDate.toIso8601String(),
        'currency': _currency,
      };

      if (widget.savingsAccount != null) {
        await DataService().updateSavingsAccount(
          widget.savingsAccount!.id,
          accountData,
        );
      } else {
        await DataService().createSavingsAccount(accountData);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.savingsAccount != null
                ? 'Savings account updated'
                : 'Savings account created'),
          ),
        );
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.savingsAccount == null ? 'Add Savings Account' : 'Edit Savings Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Name *',
                hintText: 'e.g., Emergency Fund',
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter an account name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSavingsType,
              decoration: const InputDecoration(
                labelText: 'Savings Type *',
                prefixIcon: Icon(Icons.category),
              ),
              items: _savingsTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'] as String,
                  child: Text(type['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedSavingsType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedAccountType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                prefixIcon: Icon(Icons.account_balance),
                helperText: 'Optional: Type of savings account',
              ),
              items: _accountTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type['value'] as String,
                  child: Text(type['label'] as String),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedAccountType = value;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _interestRateController,
              decoration: const InputDecoration(
                labelText: 'Interest Rate (%)',
                hintText: 'e.g., 4.5 for 4.5%',
                prefixIcon: Icon(Icons.percent),
                helperText: 'Optional: Annual interest rate',
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value != null && value.trim().isNotEmpty) {
                  final rate = double.tryParse(value);
                  if (rate == null || rate < 0 || rate > 100) {
                    return 'Please enter a valid rate between 0 and 100';
                  }
                }
                return null;
              },
            ),
            if (_interestRateController.text.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCompoundingFrequency,
                decoration: const InputDecoration(
                  labelText: 'Compounding Frequency',
                  prefixIcon: Icon(Icons.repeat),
                ),
                items: _compoundingFrequencies.map((freq) {
                  return DropdownMenuItem<String>(
                    value: freq['value'] as String,
                    child: Text(freq['label'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCompoundingFrequency = value;
                    });
                  }
                },
              ),
            ],
            const SizedBox(height: 16),
            TextFormField(
              controller: _targetAmountController,
              decoration: const InputDecoration(
                labelText: 'Target Amount *',
                hintText: '0.00',
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a target amount';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount <= 0) {
                  return 'Please enter a valid amount greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InkWell(
              onTap: _selectDate,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Target Date *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                child: Text(Formatters.formatDate(_selectedTargetDate)),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _goalController,
              decoration: const InputDecoration(
                labelText: 'Goal (Optional)',
                hintText: 'e.g., Build emergency fund for unexpected expenses',
                prefixIcon: Icon(Icons.flag),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'Additional details about this savings account',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveAccount,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        widget.savingsAccount != null
                            ? 'Update Savings Account'
                            : 'Create Savings Account',
                        style: const TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}


