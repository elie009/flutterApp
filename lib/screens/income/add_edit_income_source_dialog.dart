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

class _AddEditIncomeSourceDialogState extends State<AddEditIncomeSourceDialog> {
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
      _currency = source.currency;
      _isActive = source.isActive;
    } else {
      // For new income source, use user's preferred currency if available
      final user = AuthService.getCurrentUser();
      if (user?.preferredCurrency != null) {
        _currency = user!.preferredCurrency!;
      }
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
                          prefixIcon: const Icon(Icons.attach_money),
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
                      TextFormField(
                        initialValue: _currency,
                        decoration: const InputDecoration(
                          labelText: 'Currency *',
                          prefixIcon: Icon(Icons.monetization_on),
                        ),
                        maxLength: 10,
                        onChanged: (value) {
                          _currency = value.trim();
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a currency';
                          }
                          if (value.length > 10) {
                            return 'Currency cannot exceed 10 characters';
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
