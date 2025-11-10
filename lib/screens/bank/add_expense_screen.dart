import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/bottom_nav_bar.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  BankAccount? _selectedAccount;
  List<BankAccount> _accounts = [];
  String _selectedCategory = 'FOOD';
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String? _recurringFrequency;
  bool _isLoading = false;
  bool _loadingAccounts = true;

  final List<String> _categories = [
    // Food & Dining
    'FOOD',
    'GROCERIES',
    'RESTAURANTS',
    'COFFEE',
    'FAST_FOOD',
    // Transportation
    'TRANSPORTATION',
    'GAS',
    'PUBLIC_TRANSPORT',
    'TAXI',
    'RIDESHARE',
    'PARKING',
    'CAR_MAINTENANCE',
    // Entertainment
    'ENTERTAINMENT',
    'MOVIES',
    'GAMES',
    'SPORTS',
    'HOBBIES',
    // Shopping
    'SHOPPING',
    'CLOTHING',
    'ELECTRONICS',
    'BOOKS',
    'PERSONAL_CARE',
    // Health & Medical
    'HEALTHCARE',
    'MEDICINE',
    'FITNESS',
    'DOCTOR',
    // Education
    'EDUCATION',
    'COURSES',
    'BOOKS_EDUCATION',
    // Travel
    'TRAVEL',
    'HOTEL',
    'FLIGHTS',
    'VACATION',
    // Utilities & Bills
    'UTILITIES',
    'INTERNET',
    'PHONE',
    'ELECTRICITY',
    'WATER',
    'GAS_UTILITY',
    // Housing
    'HOUSING',
    'RENT',
    'MORTGAGE',
    'HOME_IMPROVEMENT',
    // Insurance
    'INSURANCE',
    'CAR_INSURANCE',
    'HEALTH_INSURANCE',
    'LIFE_INSURANCE',
    // Miscellaneous
    'OTHER',
    'BILLS',
    'DONATIONS',
    'FEES',
    'SUBSCRIPTIONS',
  ];

  final List<String> _recurringFrequencies = [
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'YEARLY',
  ];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadAccounts() async {
    try {
      final accounts = await DataService().getBankAccounts(isActive: true);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          if (accounts.isNotEmpty) {
            _selectedAccount = accounts.first;
          }
          _loadingAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingAccounts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load accounts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
      ),
      body: _loadingAccounts
          ? const LoadingIndicator(message: 'Loading accounts...')
          : _accounts.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                      const Icon(
                        Icons.account_balance_wallet,
                        size: 64,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No active accounts found',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Please create a bank account first',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Go Back'),
                      ),
                      ],
                    ),
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Account Selection
                      DropdownButtonFormField<BankAccount>(
                        value: _selectedAccount,
                        decoration: const InputDecoration(
                          labelText: 'Account *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        items: _accounts.map((account) {
                          return DropdownMenuItem<BankAccount>(
                            value: account,
                            child: Text(
                              account.accountName,
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedAccount = value;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an account';
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
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter amount';
                          }
                          final amount = double.tryParse(value);
                          if (amount == null || amount <= 0) {
                            return 'Please enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category),
                        ),
                        items: _categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(_formatCategoryName(category)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'e.g., Lunch at restaurant',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.description),
                        ),
                        maxLines: 2,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Transaction Date
                      InkWell(
                        onTap: _selectDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            Formatters.formatDate(_selectedDate),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Merchant
                      TextFormField(
                        controller: _merchantController,
                        decoration: const InputDecoration(
                          labelText: 'Merchant',
                          hintText: 'e.g., McDonald\'s',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.store),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Location
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'e.g., Downtown Mall',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Notes
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          labelText: 'Notes',
                          hintText: 'Additional notes',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.note),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Recurring Expense
                      CheckboxListTile(
                        title: const Text('Recurring Expense'),
                        value: _isRecurring,
                        onChanged: (value) {
                          setState(() {
                            _isRecurring = value ?? false;
                            if (!_isRecurring) {
                              _recurringFrequency = null;
                            } else if (_recurringFrequency == null) {
                              _recurringFrequency = 'MONTHLY';
                            }
                          });
                        },
                      ),
                      if (_isRecurring) ...[
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _recurringFrequency ?? 'MONTHLY',
                          decoration: const InputDecoration(
                            labelText: 'Frequency',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.repeat),
                          ),
                          items: _recurringFrequencies.map((frequency) {
                            return DropdownMenuItem<String>(
                              value: frequency,
                              child: Text(frequency),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _recurringFrequency = value;
                            });
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveExpense,
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
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Expense',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }

  String _formatCategoryName(String category) {
    return category
        .split('_')
        .map((word) =>
            word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  Future<void> _saveExpense() async {
    if (!_formKey.currentState!.validate() || _selectedAccount == null) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final expenseData = {
        'bankAccountId': _selectedAccount!.id,
        'amount': double.parse(_amountController.text),
        'category': _selectedCategory,
        'description': _descriptionController.text.trim(),
        'transactionDate': _selectedDate.toIso8601String(),
        'currency': _selectedAccount!.currency,
        if (_merchantController.text.isNotEmpty)
          'merchant': _merchantController.text.trim(),
        if (_locationController.text.isNotEmpty)
          'location': _locationController.text.trim(),
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
        'isRecurring': _isRecurring,
        if (_isRecurring && _recurringFrequency != null)
          'recurringFrequency': _recurringFrequency,
      };

      await DataService().createExpense(expenseData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expense added successfully'),
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

