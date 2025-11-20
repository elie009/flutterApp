import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../models/bank_account.dart';
import '../../models/bank_transaction.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/theme.dart';
import '../../widgets/loading_indicator.dart';
import '../../widgets/bottom_nav_bar.dart';
import 'add_transaction_screen.dart';

class AnalyzerScreen extends StatefulWidget {
  const AnalyzerScreen({super.key});

  @override
  State<AnalyzerScreen> createState() => _AnalyzerScreenState();
}

class _AnalyzerScreenState extends State<AnalyzerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _transactionTextController = TextEditingController();
  
  BankAccount? _selectedAccount;
  List<BankAccount> _accounts = [];
  bool _isLoading = false;
  bool _loadingAccounts = true;
  bool _isAnalyzing = false;
  
  // Transaction Type
  String? _transactionType; // null = None, 'SAVINGS' = Savings
  List<SavingsAccount> _savingsAccounts = [];
  SavingsAccount? _selectedSavingsAccount;
  bool _loadingSavingsAccounts = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _transactionTextController.dispose();
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

  Future<void> _loadSavingsAccounts() async {
    if (_transactionType != 'SAVINGS') return;
    
    setState(() {
      _loadingSavingsAccounts = true;
    });

    try {
      final savingsAccounts = await DataService().getSavingsAccounts(isActive: true);
      if (mounted) {
        setState(() {
          _savingsAccounts = savingsAccounts;
          _loadingSavingsAccounts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _loadingSavingsAccounts = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load savings accounts: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _createSavingsTransaction(
    BankTransaction analyzedTransaction,
    String transactionText,
  ) async {
    if (_selectedSavingsAccount == null || _selectedAccount == null) {
      throw Exception('Savings account and bank account are required');
    }

    final transactionData = <String, dynamic>{
      'savingsAccountId': _selectedSavingsAccount!.id,
      'sourceBankAccountId': _selectedAccount!.id,
      'amount': analyzedTransaction.amount,
      'transactionType': 'DEPOSIT', // Always DEPOSIT for savings
      'description': analyzedTransaction.description.isNotEmpty
          ? analyzedTransaction.description
          : transactionText,
      'transactionDate': analyzedTransaction.transactionDate.toIso8601String(),
      'currency': _selectedSavingsAccount!.currency,
      'isRecurring': analyzedTransaction.isRecurring,
    };

    if (analyzedTransaction.category != null) {
      transactionData['category'] = analyzedTransaction.category;
    }
    if (analyzedTransaction.notes != null && analyzedTransaction.notes!.isNotEmpty) {
      transactionData['notes'] = analyzedTransaction.notes;
    }
    if (analyzedTransaction.recurringFrequency != null) {
      transactionData['recurringFrequency'] = analyzedTransaction.recurringFrequency!.toLowerCase();
    }

    await DataService().createSavingsTransaction(transactionData);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Savings transaction created successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _analyzeTransaction() async {
    final transactionText = _transactionTextController.text.trim();
    if (transactionText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter transaction text to analyze'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate savings account and bank account selection if Savings type is selected
    if (_transactionType == 'SAVINGS') {
      if (_selectedSavingsAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a savings account'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (_selectedAccount == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select a bank account for savings transaction'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final analyzedTransaction = await DataService().analyzeTransactionText(
        transactionText: transactionText,
        bankAccountId: _selectedAccount?.id,
      );

      if (mounted) {
        // If Savings type is selected, create savings transaction directly
        if (_transactionType == 'SAVINGS' && _selectedSavingsAccount != null) {
          await _createSavingsTransaction(analyzedTransaction, transactionText);
        } else {
          // If None is selected, navigate to Add Transaction screen for validation
          final prefillData = <String, dynamic>{
            'amount': analyzedTransaction.amount.toStringAsFixed(2),
            'transactionType': analyzedTransaction.transactionType.toUpperCase(),
            'description': analyzedTransaction.description.isNotEmpty
                ? analyzedTransaction.description
                : transactionText,
            'transactionDate': analyzedTransaction.transactionDate.toIso8601String(),
            'isRecurring': analyzedTransaction.isRecurring,
          };
          
          if (_selectedAccount != null) {
            prefillData['bankAccountId'] = _selectedAccount!.id;
          }
          
          if (analyzedTransaction.category != null) {
            prefillData['category'] = analyzedTransaction.category;
          }
          if (analyzedTransaction.merchant != null && analyzedTransaction.merchant!.isNotEmpty) {
            prefillData['merchant'] = analyzedTransaction.merchant;
          }
          if (analyzedTransaction.location != null && analyzedTransaction.location!.isNotEmpty) {
            prefillData['location'] = analyzedTransaction.location;
          }
          if (analyzedTransaction.notes != null && analyzedTransaction.notes!.isNotEmpty) {
            prefillData['notes'] = analyzedTransaction.notes;
          }
          if (analyzedTransaction.referenceNumber != null && analyzedTransaction.referenceNumber!.isNotEmpty) {
            prefillData['referenceNumber'] = analyzedTransaction.referenceNumber;
          }
          if (analyzedTransaction.recurringFrequency != null) {
            prefillData['recurringFrequency'] = analyzedTransaction.recurringFrequency;
          }
          
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                prefillData: prefillData,
              ),
            ),
          );

          if (result == true && mounted) {
            Navigator.pop(context, true);
          }
        }
      }
    } catch (e) {
      // Handle any errors during savings transaction creation
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating savings transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } on DioException catch (e) {
      // Extract error message from API response
      String errorMessage = 'Error analyzing transaction';
      
      if (e.response != null) {
        final responseData = e.response!.data;
        if (responseData is Map<String, dynamic>) {
          // Try to get the message from the response
          final message = responseData['message'] as String?;
          if (message != null && message.isNotEmpty) {
            errorMessage = message;
          } else {
            // Fallback to exception message
            errorMessage = e.message ?? 'Error analyzing transaction';
          }
        } else {
          errorMessage = e.message ?? 'Error analyzing transaction';
        }
      } else {
        errorMessage = e.message ?? 'Network error occurred';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      // Handle wrapped exceptions from ApiService
      String errorMessage = 'Error analyzing transaction';
      final errorString = e.toString();
      
      // Try to extract message from wrapped exception
      // ApiService wraps 400 errors as "Exception: Bad Request: {message}"
      // The format is: "Exception: Bad Request: {actual message}"
      if (errorString.contains('Bad Request:')) {
        // Extract message after "Bad Request: "
        final parts = errorString.split('Bad Request:');
        if (parts.length > 1) {
          errorMessage = parts[1].trim();
        } else {
          errorMessage = errorString;
        }
      } else if (errorString.startsWith('Exception: ')) {
        // Extract message after "Exception: "
        errorMessage = errorString.substring('Exception: '.length).trim();
      } else {
        errorMessage = errorString;
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Analyzer'),
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
                      // Transaction Type - Radio Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Transaction Type *',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Radio<String?>(
                                value: null,
                                groupValue: _transactionType,
                                onChanged: (value) {
                                  setState(() {
                                    _transactionType = value;
                                    _selectedSavingsAccount = null;
                                  });
                                },
                              ),
                              const Text('None'),
                              const SizedBox(width: 24),
                              Radio<String?>(
                                value: 'SAVINGS',
                                groupValue: _transactionType,
                                onChanged: (value) {
                                  setState(() {
                                    _transactionType = value;
                                    _selectedSavingsAccount = null;
                                    if (value == 'SAVINGS') {
                                      _loadSavingsAccounts();
                                    }
                                  });
                                },
                              ),
                              const Text('Savings'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Savings Account Selection (when Savings is selected)
                      if (_transactionType == 'SAVINGS') ...[
                        _loadingSavingsAccounts
                            ? const Padding(
                                padding: EdgeInsets.all(16),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : _savingsAccounts.isEmpty
                                ? const Text(
                                    'No active savings accounts found',
                                    style: TextStyle(color: Colors.grey),
                                  )
                                : DropdownButtonFormField<SavingsAccount>(
                                    value: _selectedSavingsAccount,
                                    decoration: const InputDecoration(
                                      labelText: 'Savings Account *',
                                      border: OutlineInputBorder(),
                                      prefixIcon: Icon(Icons.savings),
                                    ),
                                    items: _savingsAccounts.map((account) {
                                      return DropdownMenuItem<SavingsAccount>(
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
                                      if (_transactionType == 'SAVINGS' && value == null) {
                                        return 'Please select a savings account';
                                      }
                                      return null;
                                    },
                                  ),
                        const SizedBox(height: 16),
                      ],

                      // Bank Account Selection
                      DropdownButtonFormField<BankAccount>(
                        value: _selectedAccount,
                        decoration: InputDecoration(
                          labelText: _transactionType == 'SAVINGS' 
                              ? 'Bank Account *' 
                              : 'Bank Account (Optional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.account_balance_wallet),
                        ),
                        items: [
                          if (_transactionType != 'SAVINGS')
                            const DropdownMenuItem<BankAccount>(
                              value: null,
                              child: Text('None (Optional)'),
                            ),
                          ..._accounts.map((account) {
                            return DropdownMenuItem<BankAccount>(
                              value: account,
                              child: Text(account.accountName),
                            );
                          }),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _selectedAccount = value;
                          });
                        },
                        validator: (value) {
                          if (_transactionType == 'SAVINGS' && value == null) {
                            return 'Please select a bank account';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Transaction Text Input
                      TextFormField(
                        controller: _transactionTextController,
                        decoration: const InputDecoration(
                          labelText: 'Transaction Text *',
                          hintText: 'Enter transaction description or text to analyze\nExample: "Paid \$50 for groceries at Walmart"',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.text_fields),
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                        minLines: 8,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter transaction text';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter the transaction description or any text related to the transaction. The analyzer will extract amount, category, merchant, and other details.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Analyze Button
                      ElevatedButton(
                        onPressed: _isAnalyzing ? null : _analyzeTransaction,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: AppTheme.primaryColor,
                        ),
                        child: _isAnalyzing
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.auto_awesome, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Analyze Transaction',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 2),
    );
  }
}

