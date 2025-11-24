import 'package:flutter/material.dart';
import '../../models/bank_account.dart';
import '../../models/bill.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/theme.dart';
import '../../utils/double_entry_validation.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/bottom_nav_bar.dart';

class AddTransactionScreen extends StatefulWidget {
  final Map<String, dynamic>? prefillData;
  
  const AddTransactionScreen({super.key, this.prefillData});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _merchantController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _referenceNumberController = TextEditingController();

  BankAccount? _selectedAccount;
  List<BankAccount> _accounts = [];
  String _transactionType = 'DEBIT';
  String? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  bool _isRecurring = false;
  String? _recurringFrequency;
  bool _isLoading = false;
  bool _loadingAccounts = true;
  bool _loadingReferenceData = false;

  // Reference data for smart linking
  List<Bill> _bills = [];
  List<Loan> _loans = [];
  List<BankAccount> _savingsAccounts = [];
  Bill? _selectedBill;
  Loan? _selectedLoan;
  BankAccount? _selectedSavingsAccount;

  // Category lists
  final List<String> _debitCategories = [
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
    // Utilities & Bills (Bill Categories)
    'UTILITIES',
    'RENT',
    'INSURANCE',
    'SUBSCRIPTION',
    'PHONE',
    'INTERNET',
    'ELECTRICITY',
    'WATER',
    'GAS_UTILITY',
    // Loan Categories
    'LOAN_PAYMENT',
    'REPAYMENT',
    'DEBT_PAYMENT',
    'INSTALLMENT',
    'MORTGAGE_PAYMENT',
    // Savings Categories
    'SAVINGS',
    'DEPOSIT',
    'INVESTMENT',
    'EMERGENCY_FUND',
    // Miscellaneous
    'OTHER',
    'BILLS',
    'DONATIONS',
    'FEES',
  ];

  final List<String> _recurringFrequencies = [
    'DAILY',
    'WEEKLY',
    'MONTHLY',
    'QUARTERLY',
    'YEARLY',
  ];

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _merchantController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _referenceNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _loadingAccounts = true;
    });

    try {
      final accounts = await DataService().getBankAccounts(isActive: true);
      if (mounted) {
        setState(() {
          _accounts = accounts;
          if (accounts.isNotEmpty) {
            // Use prefill account ID if provided, otherwise use first account
            if (widget.prefillData != null && widget.prefillData!['bankAccountId'] != null) {
              _selectedAccount = accounts.firstWhere(
                (acc) => acc.id == widget.prefillData!['bankAccountId'],
                orElse: () => accounts.first,
              );
            } else {
              _selectedAccount = accounts.first;
            }
          }
          _loadingAccounts = false;
        });
        
        // Prefill form fields if data is provided
        if (widget.prefillData != null) {
          _prefillFormData(widget.prefillData!);
        }
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

  void _prefillFormData(Map<String, dynamic> data) {
    setState(() {
      if (data['amount'] != null) {
        _amountController.text = data['amount'].toString();
      }
      if (data['transactionType'] != null) {
        _transactionType = data['transactionType'].toString().toUpperCase();
      }
      if (data['category'] != null) {
        _selectedCategory = data['category'].toString();
        _loadReferenceData();
      }
      if (data['description'] != null) {
        _descriptionController.text = data['description'].toString();
      }
      if (data['merchant'] != null) {
        _merchantController.text = data['merchant'].toString();
      }
      if (data['location'] != null) {
        _locationController.text = data['location'].toString();
      }
      if (data['notes'] != null) {
        _notesController.text = data['notes'].toString();
      }
      if (data['referenceNumber'] != null) {
        _referenceNumberController.text = data['referenceNumber'].toString();
      }
      if (data['transactionDate'] != null) {
        try {
          _selectedDate = DateTime.parse(data['transactionDate'].toString());
        } catch (e) {
          // Keep default date if parsing fails
        }
      }
      if (data['isRecurring'] != null) {
        _isRecurring = data['isRecurring'] == true || data['isRecurring'] == 'true';
      }
      if (data['recurringFrequency'] != null) {
        _recurringFrequency = data['recurringFrequency'].toString().toUpperCase();
      }
    });
  }

  Future<void> _loadReferenceData() async {
    if (_isBillCategory(_selectedCategory)) {
      setState(() {
        _loadingReferenceData = true;
      });
      try {
        final billsData = await DataService().getBills(status: 'PENDING');
        setState(() {
          _bills = billsData['bills'] as List<Bill>? ?? [];
          _loadingReferenceData = false;
        });
      } catch (e) {
        setState(() {
          _loadingReferenceData = false;
        });
      }
    } else if (_isLoanCategory(_selectedCategory)) {
      setState(() {
        _loadingReferenceData = true;
      });
      try {
        final loans = await DataService().getUserLoans(status: 'ACTIVE');
        setState(() {
          _loans = loans;
          _loadingReferenceData = false;
        });
      } catch (e) {
        setState(() {
          _loadingReferenceData = false;
        });
      }
    } else if (_isSavingsCategory(_selectedCategory)) {
      setState(() {
        _loadingReferenceData = true;
      });
      try {
        final accounts = await DataService().getBankAccounts(isActive: true);
        setState(() {
          _savingsAccounts = accounts;
          _loadingReferenceData = false;
        });
      } catch (e) {
        setState(() {
          _loadingReferenceData = false;
        });
      }
    }
  }

  bool _isBillCategory(String? category) {
    if (category == null) return false;
    final categoryLower = category.toLowerCase();
    final billKeywords = ['utility', 'rent', 'insurance', 'subscription', 'phone', 'internet', 'electricity', 'water', 'gas', 'cable'];
    return billKeywords.any((keyword) => categoryLower.contains(keyword));
  }

  bool _isSavingsCategory(String? category) {
    if (category == null) return false;
    final categoryLower = category.toLowerCase();
    final savingsKeywords = ['savings', 'deposit', 'investment', 'fund', 'goal', 'emergency'];
    return savingsKeywords.any((keyword) => categoryLower.contains(keyword));
  }

  bool _isLoanCategory(String? category) {
    if (category == null) return false;
    final categoryLower = category.toLowerCase();
    final loanKeywords = ['loan', 'repayment', 'debt', 'installment', 'mortgage'];
    return loanKeywords.any((keyword) => categoryLower.contains(keyword));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
    );
    if (time != null) {
      setState(() {
        _selectedDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
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
                      // Bank Account Selection
                      DropdownButtonFormField<BankAccount>(
                        value: _selectedAccount,
                        decoration: const InputDecoration(
                          labelText: 'Bank Account *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.account_balance_wallet),
                        ),
                        items: _accounts.map((account) {
                          return DropdownMenuItem<BankAccount>(
                            value: account,
                            child: Text(account.accountName),
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

                      // Transaction Type
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _transactionType = 'DEBIT';
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _transactionType == 'DEBIT'
                                        ? Colors.red[400]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_downward,
                                        size: 20,
                                        color: _transactionType == 'DEBIT'
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Debit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: _transactionType == 'DEBIT'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _transactionType == 'DEBIT'
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _transactionType = 'CREDIT';
                                    _selectedCategory = null;
                                    _selectedBill = null;
                                    _selectedLoan = null;
                                    _selectedSavingsAccount = null;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _transactionType == 'CREDIT'
                                        ? Colors.green[400]
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.arrow_upward,
                                        size: 20,
                                        color: _transactionType == 'CREDIT'
                                            ? Colors.white
                                            : Colors.grey[700],
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Credit',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: _transactionType == 'CREDIT'
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: _transactionType == 'CREDIT'
                                              ? Colors.white
                                              : Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
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
                            return 'Amount must be greater than 0';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Category (Only for DEBIT)
                      if (_transactionType == 'DEBIT')
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: const InputDecoration(
                            labelText: 'Category *',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.label),
                          ),
                          hint: const Text('Select category'),
                          items: _debitCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(_formatCategoryName(category)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedCategory = value;
                              _selectedBill = null;
                              _selectedLoan = null;
                              _selectedSavingsAccount = null;
                            });
                            if (value != null) {
                              _loadReferenceData();
                            }
                          },
                          validator: (value) {
                            if (_transactionType == 'DEBIT' && value == null) {
                              return 'Please select a category';
                            }
                            return null;
                          },
                        ),
                      if (_transactionType == 'DEBIT') const SizedBox(height: 16),

                      // Bill Selector (Conditional)
                      if (_transactionType == 'DEBIT' &&
                          _isBillCategory(_selectedCategory))
                        _loadingReferenceData
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _bills.isEmpty
                                ? const Text(
                                    'No pending bills found',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : DropdownButtonFormField<Bill>(
                                    value: _selectedBill,
                                    decoration: const InputDecoration(
                                      labelText: 'Bill *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.receipt_long),
                                    ),
                                    hint: const Text('Select bill'),
                                    items: _bills.map((bill) {
                                      return DropdownMenuItem<Bill>(
                                        value: bill,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(bill.billName),
                                            Text(
                                              Formatters.formatCurrency(
                                                bill.amount,
                                              ),
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
                                        _selectedBill = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_isBillCategory(_selectedCategory) &&
                                          value == null) {
                                        return 'Please select a bill';
                                      }
                                      return null;
                                    },
                                  ),
                      if (_transactionType == 'DEBIT' &&
                          _isBillCategory(_selectedCategory))
                        const SizedBox(height: 16),

                      // Loan Selector (Conditional)
                      if (_transactionType == 'DEBIT' &&
                          _isLoanCategory(_selectedCategory))
                        _loadingReferenceData
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _loans.isEmpty
                                ? const Text(
                                    'No active loans found',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : DropdownButtonFormField<Loan>(
                                    value: _selectedLoan,
                                    decoration: const InputDecoration(
                                      labelText: 'Loan *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.account_balance),
                                    ),
                                    hint: const Text('Select loan'),
                                    items: _loans.map((loan) {
                                      return DropdownMenuItem<Loan>(
                                        value: loan,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(loan.purpose ?? 'Loan'),
                                            Text(
                                              'Balance: ${Formatters.formatCurrency(loan.remainingBalance)}',
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
                                        _selectedLoan = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_isLoanCategory(_selectedCategory) &&
                                          value == null) {
                                        return 'Please select a loan';
                                      }
                                      return null;
                                    },
                                  ),
                      if (_transactionType == 'DEBIT' &&
                          _isLoanCategory(_selectedCategory))
                        const SizedBox(height: 16),

                      // Savings Account Selector (Conditional)
                      if (_transactionType == 'DEBIT' &&
                          _isSavingsCategory(_selectedCategory))
                        _loadingReferenceData
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _savingsAccounts.isEmpty
                                ? const Text(
                                    'No savings accounts found',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : DropdownButtonFormField<BankAccount>(
                                    value: _selectedSavingsAccount,
                                    decoration: const InputDecoration(
                                      labelText: 'Savings Account *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.savings),
                                    ),
                                    hint: const Text('Select savings account'),
                                    items: _savingsAccounts.map((account) {
                                      return DropdownMenuItem<BankAccount>(
                                        value: account,
                                        child: Text(account.accountName),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedSavingsAccount = value;
                                      });
                                    },
                                    validator: (value) {
                                      if (_isSavingsCategory(_selectedCategory) &&
                                          value == null) {
                                        return 'Please select a savings account';
                                      }
                                      return null;
                                    },
                                  ),
                      if (_transactionType == 'DEBIT' &&
                          _isSavingsCategory(_selectedCategory))
                        const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description *',
                          hintText: 'Enter transaction description',
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

                      // Date and Time
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
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
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: _selectTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: 'Time *',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                child: Text(
                                  '${_selectedDate.hour.toString().padLeft(2, '0')}:${_selectedDate.minute.toString().padLeft(2, '0')}',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Optional Fields Section
                      ExpansionTile(
                        title: const Text('Optional Fields'),
                        children: [
                          // Merchant
                          TextFormField(
                            controller: _merchantController,
                            decoration: const InputDecoration(
                              labelText: 'Merchant',
                              hintText: 'e.g., Store Name',
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
                              hintText: 'e.g., City, State',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.location_on),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Reference Number
                          TextFormField(
                            controller: _referenceNumberController,
                            decoration: const InputDecoration(
                              labelText: 'Reference Number',
                              hintText: 'Transaction reference',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.numbers),
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
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Recurring Transaction
                      CheckboxListTile(
                        title: const Text('Recurring Transaction'),
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
                            labelText: 'Frequency *',
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
                          validator: (value) {
                            if (_isRecurring && value == null) {
                              return 'Please select frequency';
                            }
                            return null;
                          },
                        ),
                      ],

                      const SizedBox(height: 32),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _saveTransaction,
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
                            : Text(
                                'Create Transaction',
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

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate() || _selectedAccount == null) {
      return;
    }

    // Recurring frequency validation
    if (_isRecurring && _recurringFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Recurring frequency is required when transaction is recurring'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Comprehensive validation with double-entry accounting
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final validationErrors = validateTransactionWithDoubleEntry(
      bankAccountId: _selectedAccount!.id,
      amount: amount,
      description: _descriptionController.text.trim(),
      category: _selectedCategory,
      billId: _selectedBill?.id,
      savingsAccountId: _selectedSavingsAccount?.id,
      loanId: _selectedLoan?.id,
      toBankAccountId: null, // TODO: Add support for bank transfers in Flutter
      transactionType: _transactionType,
    );

    if (validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationErrors.join('. ')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final transactionData = <String, dynamic>{
        'bankAccountId': _selectedAccount!.id,
        'amount': double.parse(_amountController.text),
        'transactionType': _transactionType,
        'description': _descriptionController.text.trim(),
        'transactionDate': _selectedDate.toIso8601String(),
        'currency': _selectedAccount!.currency,
        if (_transactionType == 'DEBIT' && _selectedCategory != null)
          'category': _selectedCategory,
        if (_merchantController.text.isNotEmpty)
          'merchant': _merchantController.text.trim(),
        if (_locationController.text.isNotEmpty)
          'location': _locationController.text.trim(),
        if (_notesController.text.isNotEmpty)
          'notes': _notesController.text.trim(),
        if (_referenceNumberController.text.isNotEmpty)
          'referenceNumber': _referenceNumberController.text.trim(),
        'isRecurring': _isRecurring,
        if (_isRecurring && _recurringFrequency != null)
          'recurringFrequency': _recurringFrequency!.toLowerCase(),
        if (_selectedBill != null) 'billId': _selectedBill!.id,
        if (_selectedLoan != null) 'loanId': _selectedLoan!.id,
        if (_selectedSavingsAccount != null)
          'savingsAccountId': _selectedSavingsAccount!.id,
      };

      await DataService().createTransaction(transactionData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully'),
            backgroundColor: Colors.green,
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

