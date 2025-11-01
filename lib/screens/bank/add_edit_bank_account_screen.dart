import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_indicator.dart';

class AddEditBankAccountScreen extends StatefulWidget {
  final BankAccount? account;

  const AddEditBankAccountScreen({
    super.key,
    this.account,
  });

  @override
  State<AddEditBankAccountScreen> createState() =>
      _AddEditBankAccountScreenState();
}

class _AddEditBankAccountScreenState extends State<AddEditBankAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountNameController = TextEditingController();
  final _initialBalanceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _financialInstitutionController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _routingNumberController = TextEditingController();
  final _ibanController = TextEditingController();
  final _swiftCodeController = TextEditingController();

  String _selectedAccountType = 'bank';
  String _selectedCurrency = 'USD';
  String _selectedSyncFrequency = 'MANUAL';
  bool _isLoading = false;

  final List<String> _accountTypes = [
    'bank',
    'wallet',
    'credit',
    'cash',
    'investment',
  ];

  final List<String> _currencies = ['USD', 'PHP', 'EUR', 'GBP'];
  final List<String> _syncFrequencies = [
    'MANUAL',
    'DAILY',
    'WEEKLY',
    'MONTHLY',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.account != null) {
      _loadAccountData();
    }
  }

  void _loadAccountData() {
    final account = widget.account!;
    _accountNameController.text = account.accountName;
    _initialBalanceController.text =
        account.currentBalance.toStringAsFixed(2);
    _descriptionController.text = account.description ?? '';
    _financialInstitutionController.text =
        account.financialInstitution ?? '';
    _accountNumberController.text = account.accountNumber ?? '';
    _routingNumberController.text = account.routingNumber ?? '';
    _ibanController.text = account.iban ?? '';
    _swiftCodeController.text = account.swiftCode ?? '';
    _selectedAccountType = account.accountType;
    _selectedCurrency = account.currency;
    _selectedSyncFrequency = account.syncFrequency;
  }

  @override
  void dispose() {
    _accountNameController.dispose();
    _initialBalanceController.dispose();
    _descriptionController.dispose();
    _financialInstitutionController.dispose();
    _accountNumberController.dispose();
    _routingNumberController.dispose();
    _ibanController.dispose();
    _swiftCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.account == null ? 'Add Account' : 'Edit Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Account Name
            TextFormField(
              controller: _accountNameController,
              decoration: const InputDecoration(
                labelText: 'Account Name *',
                hintText: 'e.g., My Checking Account',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter account name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Account Type
            DropdownButtonFormField<String>(
              value: _selectedAccountType,
              decoration: const InputDecoration(
                labelText: 'Account Type *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _accountTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAccountType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Initial Balance
            TextFormField(
              controller: _initialBalanceController,
              decoration: const InputDecoration(
                labelText: 'Initial Balance *',
                hintText: '0.00',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter initial balance';
                }
                final amount = double.tryParse(value);
                if (amount == null || amount < 0) {
                  return 'Please enter a valid amount';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Currency
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              decoration: const InputDecoration(
                labelText: 'Currency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_exchange),
              ),
              items: _currencies.map((currency) {
                return DropdownMenuItem(
                  value: currency,
                  child: Text(currency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCurrency = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Optional description',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Financial Institution
            TextFormField(
              controller: _financialInstitutionController,
              decoration: const InputDecoration(
                labelText: 'Bank/Institution',
                hintText: 'e.g., Chase Bank',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business),
              ),
            ),
            const SizedBox(height: 16),

            // Account Number
            TextFormField(
              controller: _accountNumberController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                hintText: '****1234 (masked)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
            ),
            const SizedBox(height: 16),

            // Routing Number
            TextFormField(
              controller: _routingNumberController,
              decoration: const InputDecoration(
                labelText: 'Routing Number',
                hintText: 'e.g., 021000021',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.route),
              ),
            ),
            const SizedBox(height: 16),

            // Sync Frequency
            DropdownButtonFormField<String>(
              value: _selectedSyncFrequency,
              decoration: const InputDecoration(
                labelText: 'Sync Frequency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.sync),
              ),
              items: _syncFrequencies.map((frequency) {
                return DropdownMenuItem(
                  value: frequency,
                  child: Text(frequency),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedSyncFrequency = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // International Fields
            const Divider(),
            const Text(
              'International Banking (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // IBAN
            TextFormField(
              controller: _ibanController,
              decoration: const InputDecoration(
                labelText: 'IBAN',
                hintText: 'International account number',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.language),
              ),
            ),
            const SizedBox(height: 16),

            // SWIFT Code
            TextFormField(
              controller: _swiftCodeController,
              decoration: const InputDecoration(
                labelText: 'SWIFT Code',
                hintText: 'e.g., CHASUS33',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.code),
              ),
            ),
            const SizedBox(height: 32),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveAccount,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppTheme.primaryColor,
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
                  : Text(
                      widget.account == null ? 'Create Account' : 'Update Account',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveAccount() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final accountData = {
        'accountName': _accountNameController.text.trim(),
        'accountType': _selectedAccountType,
        'initialBalance': double.parse(_initialBalanceController.text),
        'currency': _selectedCurrency,
        if (_descriptionController.text.isNotEmpty)
          'description': _descriptionController.text.trim(),
        if (_financialInstitutionController.text.isNotEmpty)
          'financialInstitution':
              _financialInstitutionController.text.trim(),
        if (_accountNumberController.text.isNotEmpty)
          'accountNumber': _accountNumberController.text.trim(),
        if (_routingNumberController.text.isNotEmpty)
          'routingNumber': _routingNumberController.text.trim(),
        'syncFrequency': _selectedSyncFrequency,
        if (_ibanController.text.isNotEmpty)
          'iban': _ibanController.text.trim(),
        if (_swiftCodeController.text.isNotEmpty)
          'swiftCode': _swiftCodeController.text.trim(),
      };

      if (widget.account == null) {
        await DataService().createBankAccount(accountData);
      } else {
        await DataService().updateBankAccount(
          widget.account!.id,
          accountData,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.account == null
                  ? 'Account created successfully'
                  : 'Account updated successfully',
            ),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

