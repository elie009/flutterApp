import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/income_source.dart';
import '../../services/data_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';

class AddEditIncomeSourceScreen extends StatefulWidget {
  final IncomeSource? incomeSource;

  const AddEditIncomeSourceScreen({
    super.key,
    this.incomeSource,
  });

  @override
  State<AddEditIncomeSourceScreen> createState() => _AddEditIncomeSourceScreenState();
}

class _AddEditIncomeSourceScreenState extends State<AddEditIncomeSourceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _companyController = TextEditingController();
  final _amountController = TextEditingController();
  String _selectedFrequency = 'MONTHLY';
  bool _isLoading = false;

  final List<String> _frequencies = ['MONTHLY', 'WEEKLY', 'BIWEEKLY', 'YEARLY'];

  @override
  void initState() {
    super.initState();
    if (widget.incomeSource != null) {
      _nameController.text = widget.incomeSource!.name;
      _companyController.text = widget.incomeSource!.company ?? '';
      _amountController.text = widget.incomeSource!.monthlyAmount.toString();
      _selectedFrequency = widget.incomeSource!.frequency;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _saveIncomeSource() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      
      // Calculate monthly amount based on frequency
      double monthlyAmount = amount;
      switch (_selectedFrequency) {
        case 'WEEKLY':
          monthlyAmount = amount * 4.33; // Average weeks per month
          break;
        case 'BIWEEKLY':
          monthlyAmount = amount * 2.17; // Average biweeks per month
          break;
        case 'YEARLY':
          monthlyAmount = amount / 12;
          break;
        case 'MONTHLY':
        default:
          monthlyAmount = amount;
      }

      final incomeSource = IncomeSource(
        id: widget.incomeSource?.id ?? '',
        name: _nameController.text.trim(),
        amount: amount,
        frequency: _selectedFrequency,
        currency: 'PHP',
        monthlyAmount: monthlyAmount,
        isActive: true,
        company: _companyController.text.trim().isEmpty
            ? null
            : _companyController.text.trim(),
      );

      final result = widget.incomeSource == null
          ? await DataService().createIncomeSource(incomeSource)
          : await DataService().updateIncomeSource(widget.incomeSource!.id, incomeSource);
      
      final success = result != null;

      if (success && mounted) {
        NavigationHelper.showSnackBar(
          context,
          widget.incomeSource == null
              ? 'Income source added successfully'
              : 'Income source updated successfully',
          backgroundColor: AppTheme.successColor,
        );
        context.pop(true);
      } else if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Failed to save income source',
          backgroundColor: AppTheme.errorColor,
        );
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.incomeSource == null ? 'Add Income Source' : 'Edit Income Source'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Income Source Name *',
                  hintText: 'e.g., Salary, Freelance',
                  prefixIcon: Icon(Icons.work),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter income source name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _companyController,
                decoration: const InputDecoration(
                  labelText: 'Company (Optional)',
                  hintText: 'e.g., ABC Corp',
                  prefixIcon: Icon(Icons.business),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount *',
                  hintText: '0.00',
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter amount';
                  }
                  if (double.tryParse(value) == null || double.parse(value) <= 0) {
                    return 'Please enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency *',
                  prefixIcon: Icon(Icons.calendar_today),
                ),
                items: _frequencies.map((frequency) {
                  return DropdownMenuItem(
                    value: frequency,
                    child: Text(frequency),
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
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveIncomeSource,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(widget.incomeSource == null ? 'Add Income Source' : 'Update Income Source'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

