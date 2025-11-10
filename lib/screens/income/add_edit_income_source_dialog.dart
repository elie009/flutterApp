import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/income_source.dart';
import '../../services/data_service.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../config/app_config.dart';

class AddEditIncomeSourceDialog extends StatefulWidget {
  final IncomeSource? incomeSource;

  const AddEditIncomeSourceDialog({super.key, this.incomeSource});

  @override
  State<AddEditIncomeSourceDialog> createState() => _AddEditIncomeSourceDialogState();
}

class _CurrencyOption {
  final String code;
  final String label;
  final String symbol;

  const _CurrencyOption({
    required this.code,
    required this.label,
    required this.symbol,
  });
}

class _AddEditIncomeSourceDialogState extends State<AddEditIncomeSourceDialog> {
  static const List<_CurrencyOption> _currencyOptions = [
    _CurrencyOption(code: 'USD', label: 'USD - US Dollar (\$)', symbol: '\$'),
    _CurrencyOption(code: 'AED', label: 'AED - UAE Dirham (\u{062F}.\u{0625})', symbol: '\u{062F}.\u{0625}'),
    _CurrencyOption(code: 'AUD', label: 'AUD - Australian Dollar (A\$)', symbol: 'A\$'),
    _CurrencyOption(code: 'BRL', label: 'BRL - Brazilian Real (R\$)', symbol: 'R\$'),
    _CurrencyOption(code: 'CAD', label: 'CAD - Canadian Dollar (C\$)', symbol: 'C\$'),
    _CurrencyOption(code: 'CHF', label: 'CHF - Swiss Franc (CHF)', symbol: 'CHF'),
    _CurrencyOption(code: 'CNY', label: 'CNY - Chinese Yuan (\u{00A5})', symbol: '\u{00A5}'),
    _CurrencyOption(code: 'CZK', label: 'CZK - Czech Koruna (K\u{010D})', symbol: 'K\u{010D}'),
    _CurrencyOption(code: 'DKK', label: 'DKK - Danish Krone (kr)', symbol: 'kr'),
    _CurrencyOption(code: 'EUR', label: 'EUR - Euro (\u{20AC})', symbol: '\u{20AC}'),
    _CurrencyOption(code: 'GBP', label: 'GBP - British Pound (\u{00A3})', symbol: '\u{00A3}'),
    _CurrencyOption(code: 'HKD', label: 'HKD - Hong Kong Dollar (HK\$)', symbol: 'HK\$'),
    _CurrencyOption(code: 'HUF', label: 'HUF - Hungarian Forint (Ft)', symbol: 'Ft'),
    _CurrencyOption(code: 'IDR', label: 'IDR - Indonesian Rupiah (Rp)', symbol: 'Rp'),
    _CurrencyOption(code: 'INR', label: 'INR - Indian Rupee (\u{20B9})', symbol: '\u{20B9}'),
    _CurrencyOption(code: 'JPY', label: 'JPY - Japanese Yen (\u{00A5})', symbol: '\u{00A5}'),
    _CurrencyOption(code: 'KRW', label: 'KRW - South Korean Won (\u{20A9})', symbol: '\u{20A9}'),
    _CurrencyOption(code: 'MYR', label: 'MYR - Malaysian Ringgit (RM)', symbol: 'RM'),
    _CurrencyOption(code: 'MXN', label: 'MXN - Mexican Peso (\$)', symbol: '\$'),
    _CurrencyOption(code: 'NOK', label: 'NOK - Norwegian Krone (kr)', symbol: 'kr'),
    _CurrencyOption(code: 'NZD', label: 'NZD - New Zealand Dollar (NZ\$)', symbol: 'NZ\$'),
    _CurrencyOption(code: 'PHP', label: 'PHP - Philippine Peso (\u{20B1})', symbol: '\u{20B1}'),
    _CurrencyOption(code: 'PLN', label: 'PLN - Polish Zloty (z\u{0142})', symbol: 'z\u{0142}'),
    _CurrencyOption(code: 'RUB', label: 'RUB - Russian Ruble (\u{20BD})', symbol: '\u{20BD}'),
    _CurrencyOption(code: 'SAR', label: 'SAR - Saudi Riyal (\u{FDFC})', symbol: '\u{FDFC}'),
    _CurrencyOption(code: 'SEK', label: 'SEK - Swedish Krona (kr)', symbol: 'kr'),
    _CurrencyOption(code: 'SGD', label: 'SGD - Singapore Dollar (S\$)', symbol: 'S\$'),
    _CurrencyOption(code: 'THB', label: 'THB - Thai Baht (\u{0E3F})', symbol: '\u{0E3F}'),
    _CurrencyOption(code: 'TRY', label: 'TRY - Turkish Lira (\u{20BA})', symbol: '\u{20BA}'),
    _CurrencyOption(code: 'ZAR', label: 'ZAR - South African Rand (R)', symbol: 'R'),
  ];
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedFrequency = 'MONTHLY';
  String _selectedCategory = 'PRIMARY';
  String _currency = '';
  bool _isActive = true;
  bool _isLoading = false;

  List<String> _availableCategories = [
    'PRIMARY',
    'PASSIVE',
    'BUSINESS',
    'SIDE_HUSTLE',
    'INVESTMENT',
    'RENTAL',
    'OTHER',
  ];
  List<String> _availableFrequencies = [
    'WEEKLY',
    'BI_WEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'ANNUALLY',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.incomeSource != null) {
      final source = widget.incomeSource!;
      _nameController.text = source.name;
      _amountController.text = source.amount.toStringAsFixed(2);
      _companyController.text = source.company ?? '';
      _descriptionController.text = source.description ?? '';
      _selectedFrequency = source.frequency;
      _selectedCategory = source.category ?? 'PRIMARY';
      _currency = source.currency.toUpperCase();
      _isActive = source.isActive;
    } else {
      // For new income source, use user's preferred currency if available
      final user = AuthService.getCurrentUser();
      if (user?.preferredCurrency != null) {
        _currency = user!.preferredCurrency!.toUpperCase();
      }
    }
    if (!_currencyOptions.any((option) => option.code == _currency)) {
      _currency = _currencyOptions.first.code;
    }
    _loadCategoriesAndFrequencies();
  }

  Future<void> _loadCategoriesAndFrequencies() async {
    try {
      final categories = await DataService().getAvailableCategories();
      final frequencies = await DataService().getAvailableFrequencies();
      setState(() {
        if (categories.isNotEmpty) _availableCategories = categories;
        if (frequencies.isNotEmpty) _availableFrequencies = frequencies;
      });
    } catch (e) {
      // Use defaults if API call fails
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatFrequency(String frequency) {
    switch (frequency) {
      case 'WEEKLY':
        return 'Weekly';
      case 'BI_WEEKLY':
        return 'Bi-Weekly';
      case 'MONTHLY':
        return 'Monthly';
      case 'QUARTERLY':
        return 'Quarterly';
      case 'ANNUALLY':
        return 'Annually';
      default:
        return frequency;
    }
  }

  String _formatCategory(String category) {
    switch (category) {
      case 'PRIMARY':
        return 'Primary';
      case 'PASSIVE':
        return 'Passive';
      case 'BUSINESS':
        return 'Business';
      case 'SIDE_HUSTLE':
        return 'Side Hustle';
      case 'INVESTMENT':
        return 'Investment';
      case 'RENTAL':
        return 'Rental';
      case 'OTHER':
        return 'Other';
      default:
        return category;
    }
  }

  String _getCurrencySymbol(String code) {
    final option = _currencyOptions.firstWhere(
      (item) => item.code == code,
      orElse: () => _currencyOptions.first,
    );
    return option.symbol;
  }

  Future<void> _saveIncomeSource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final incomeData = {
        'name': _nameController.text.trim(),
        'amount': double.parse(_amountController.text),
        'frequency': _selectedFrequency,
        'category': _selectedCategory,
        'currency': _currency,
        'isActive': _isActive,
        if (_companyController.text.isNotEmpty) 'company': _companyController.text.trim(),
        if (_descriptionController.text.isNotEmpty) 'description': _descriptionController.text.trim(),
      };

      IncomeSource? result;
      if (widget.incomeSource != null) {
        result = await DataService().updateIncomeSource(
          widget.incomeSource!.id,
          incomeData,
        );
      } else {
        result = await DataService().createIncomeSource(incomeData);
      }

      if (result != null && mounted) {
        Navigator.of(context).pop(result);
      }
    } catch (e) {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Error: ${e.toString()}',
          backgroundColor: AppTheme.errorColor,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth = screenWidth * 0.9 > 800 ? 800.0 : screenWidth * 0.9;
    
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: (screenWidth - dialogWidth) / 2,
        vertical: 40,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SizedBox(
        width: dialogWidth,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 700),
          child: Container(
            padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.incomeSource != null ? 'Edit Income Source' : 'Add Income Source',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Income Source Name *',
                          hintText: 'e.g., Software Developer Salary',
                          prefixIcon: Icon(Icons.label),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a name';
                          }
                          if (value.length > 100) {
                            return 'Name cannot exceed 100 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Amount
                      TextFormField(
                        controller: _amountController,
                        decoration: InputDecoration(
                          labelText: 'Amount *',
                          hintText: '0.00',
                          prefixText: _currency.isNotEmpty ? '${_getCurrencySymbol(_currency)} ' : null,
                          suffixText: _selectedFrequency != 'MONTHLY'
                              ? 'per ${_formatFrequency(_selectedFrequency).toLowerCase()}'
                              : null,
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Frequency
                      DropdownButtonFormField<String>(
                        value: _selectedFrequency,
                        decoration: const InputDecoration(
                          labelText: 'Frequency *',
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        items: _availableFrequencies.map((frequency) {
                          return DropdownMenuItem(
                            value: frequency,
                            child: Text(_formatFrequency(frequency)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedFrequency = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _availableCategories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_formatCategory(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedCategory = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      // Company
                      TextFormField(
                        controller: _companyController,
                        decoration: const InputDecoration(
                          labelText: 'Company (Optional)',
                          hintText: 'e.g., Tech Corp',
                          prefixIcon: Icon(Icons.business),
                        ),
                        maxLength: 200,
                      ),
                      const SizedBox(height: 16),
                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Additional notes...',
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 3,
                        maxLength: 500,
                      ),
                      const SizedBox(height: 16),
                      // Currency
                      DropdownButtonFormField<String>(
                        value: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency *',
                        ),
                        items: _currencyOptions
                            .map(
                              (option) => DropdownMenuItem(
                                value: option.code,
                                child: Text(option.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _currency = value;
                            });
                          }
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a currency';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // Active Status
                      SwitchListTile(
                        title: const Text('Active'),
                        subtitle: const Text('Inactive sources are excluded from calculations'),
                        value: _isActive,
                        onChanged: (value) {
                          setState(() {
                            _isActive = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancel',
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveIncomeSource,
                      style: ElevatedButton.styleFrom(
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
                          : Text(widget.incomeSource != null ? 'Update' : 'Create'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
          ),
        ),
      ),
    );
  }
}
