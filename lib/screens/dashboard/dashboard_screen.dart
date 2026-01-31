import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';
import '../../models/transaction.dart';
import '../../models/bank_account.dart';
import '../../models/dashboard_summary.dart';
import '../../widgets/triangle_painter.dart';
import '../bills/bills_screen.dart';
import '../loans/loans_screen.dart';
import '../../models/bill.dart';
import '../../models/loan.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Monthly';
  bool _isLoading = true;
  double _totalBalance = 0.0; // Will be updated from API
  double _totalExpense = -1187.40;
  List<Transaction> _recentTransactions = [];
  List<BankAccount> _bankAccounts = []; // Changed to list for carousel
  final PageController _pageController = PageController(viewportFraction: 0.9);
  int _currentPage = 0; // Track current page for indicators

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // Session storage key for dashboard data
  static const String _sessionStorageKey = 'dashboard_session_data';

  // Load data: restore from session first, then fetch fresh data
  Future<void> _loadData({bool showLoading = true, bool forceRefresh = false}) async {
    // Try to restore from session storage first (unless force refresh)
    if (!forceRefresh) {
      final sessionData = _restoreFromSession();
      if (sessionData != null) {
        debugPrint('📊 Dashboard: Restored data from session storage');
        setState(() {
          _totalBalance = sessionData['totalBalance'] ?? 0.0;
          _totalExpense = sessionData['totalExpense'] ?? 0.0;
          _recentTransactions = sessionData['transactions'] ?? [];
          _bankAccounts = sessionData['bankAccounts'] ?? [];
          _isLoading = false;
        });
        // Fetch fresh data in the background and update session
        _fetchAndStoreData(showLoading: false);
        return;
      }
    }

    // No session data or force refresh - fetch from API
    await _fetchAndStoreData(showLoading: showLoading);
  }

  // Restore dashboard data from session storage
  Map<String, dynamic>? _restoreFromSession() {
    try {
      final sessionJson = StorageService.getCache(_sessionStorageKey);
      if (sessionJson == null) {
        debugPrint('📊 Dashboard: No session data found');
        return null;
      }

      final sessionData = jsonDecode(sessionJson) as Map<String, dynamic>;
      
      // Parse dashboard summary
      DashboardSummary? summary;
      if (sessionData['summary'] != null) {
        summary = DashboardSummary.fromJson(sessionData['summary'] as Map<String, dynamic>);
      }

      // Parse bank accounts
      List<BankAccount> accounts = [];
      if (sessionData['bankAccounts'] != null) {
        final accountsJson = sessionData['bankAccounts'] as List<dynamic>;
        accounts = accountsJson
            .map((e) => BankAccount.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Parse transactions
      List<Transaction> transactions = [];
      if (sessionData['transactions'] != null) {
        final transactionsJson = sessionData['transactions'] as List<dynamic>;
        transactions = transactionsJson
            .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (summary != null && summary.recentTransactions.isNotEmpty) {
        // Fallback to transactions from summary
        transactions = summary.recentTransactions;
      }

      final totalBalance = summary?.totalBalance ?? sessionData['totalBalance'] as double? ?? 0.0;

      debugPrint('📊 Dashboard: Restored - Balance: $totalBalance, Accounts: ${accounts.length}, Transactions: ${transactions.length}');
      
      return {
        'totalBalance': totalBalance,
        'totalExpense': _calculateExpense(transactions),
        'transactions': transactions,
        'bankAccounts': accounts,
      };
    } catch (e) {
      debugPrint('⚠️ Dashboard: Error restoring session data: $e');
      return null;
    }
  }

  // Store dashboard data in session storage
  Future<void> _storeInSession({
    required DashboardSummary summary,
    required List<BankAccount> accounts,
    required List<Transaction> transactions,
  }) async {
    try {
      final sessionData = {
        'summary': summary.toJson(),
        'bankAccounts': accounts.map((e) => e.toJson()).toList(),
        'transactions': transactions.map((e) => e.toJson()).toList(),
        'totalBalance': summary.totalBalance,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await StorageService.saveCache(
        _sessionStorageKey,
        jsonEncode(sessionData),
      );
      debugPrint('✅ Dashboard: Stored data in session storage');
    } catch (e) {
      debugPrint('⚠️ Dashboard: Error storing session data: $e');
    }
  }

  // Fetch fresh data from API and store in session
  Future<void> _fetchAndStoreData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      debugPrint('📊 Dashboard: Fetching fresh data from API...');
      
      // Fetch dashboard summary
      final summary = await DataService().getDashboardSummary();
      debugPrint('📊 Dashboard: Got summary with totalBalance: ${summary.totalBalance}');
      
      // Fetch bank accounts (handle errors gracefully)
      List<BankAccount> accounts = [];
      try {
        accounts = await DataService().getBankAccounts(isActive: true);
        debugPrint('📊 Dashboard: Loaded ${accounts.length} active bank accounts');
      } catch (e) {
        debugPrint('⚠️ Dashboard: Error loading bank accounts: $e');
        // Try to restore from session if API fails
        final sessionData = _restoreFromSession();
        if (sessionData != null && sessionData['bankAccounts'] != null) {
          accounts = sessionData['bankAccounts'] as List<BankAccount>;
          debugPrint('📊 Dashboard: Using bank accounts from session');
        }
      }
      
      // Fetch transactions (handle errors gracefully)
      List<Transaction> transactions = [];
      try {
        transactions = await DataService().getTransactions(limit: 5);
        debugPrint('📊 Dashboard: Loaded ${transactions.length} transactions');
      } catch (e) {
        debugPrint('⚠️ Dashboard: Error loading transactions: $e');
        // Try to use transactions from summary or session
        if (summary.recentTransactions.isNotEmpty) {
          transactions = summary.recentTransactions;
          debugPrint('📊 Dashboard: Using transactions from summary');
        } else {
          final sessionData = _restoreFromSession();
          if (sessionData != null && sessionData['transactions'] != null) {
            transactions = sessionData['transactions'] as List<Transaction>;
            debugPrint('📊 Dashboard: Using transactions from session');
          }
        }
      }

      // Store in session storage
      await _storeInSession(
        summary: summary,
        accounts: accounts,
        transactions: transactions,
      );

      // Update UI
      setState(() {
        _totalBalance = summary.totalBalance;
        _totalExpense = _calculateExpense(transactions);
        _recentTransactions = transactions;
        _bankAccounts = accounts;
        _isLoading = false;
      });
      debugPrint('✅ Dashboard: State updated with _totalBalance: $_totalBalance');
    } catch (e, stackTrace) {
      debugPrint('❌ Dashboard: Error loading data: $e');
      debugPrint('❌ Dashboard: Stack trace: $stackTrace');
      
      // If API fails completely, try to restore from session
      final sessionData = _restoreFromSession();
      if (sessionData != null) {
        debugPrint('📊 Dashboard: Restoring from session after API error');
        setState(() {
          _totalBalance = sessionData['totalBalance'] ?? 0.0;
          _totalExpense = sessionData['totalExpense'] ?? 0.0;
          _recentTransactions = sessionData['transactions'] ?? [];
          _bankAccounts = sessionData['bankAccounts'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading data: $e')),
          );
        }
      }
    }
  }

  double _calculateExpense(List<Transaction> transactions) {
    double total = 0;
    for (var t in transactions) {
      if (t.isExpense) {
        total += t.amount;
      }
    }
    return -total;
  }

  /// Get last 4 digits from IBAN (preferred) or accountNumber (fallback)
  String _getLastFourDigits(BankAccount account) {
    // Prefer IBAN, fallback to accountNumber
    final number = account.iban ?? account.accountNumber;
    if (number != null && number.length >= 4) {
      return number.substring(number.length - 4);
    }
    return "0000";
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 100),
      // Move SafeArea inside the Stack, so the colored background reaches the topmost edge
      body: Stack(
        children: [
          // The colored background area - goes edge to edge (including behind status bar)
          Container(
            width: 430,
            height: 932,
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
              // You can add other decorations here if necessary
            ),
            child: Stack(
              children: [
                  // Small top-right triangle (moved here from inside Stack)
                              Positioned.fill(
                                child: Transform.rotate(
                                  angle: 0.4,
                                  child: CustomPaint(
                                    painter: TrianglePainter(),
                                  ),
                                ),
                              ),
                              

                           // White bottom section
                          Positioned(
                            left: 0,
                            top: 191,
                            width: 413,
                            height: 751,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Color(0xFFFFFFFF),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(70),
                                  topRight: Radius.circular(70),
                                ),
                              ),
                            ),
                          ),

              ],
            ),
          ),
          // The UI is wrapped in SafeArea so its content respects system UI (not the background)
          SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Stack(
                    children: [
                     

 
           

                      RefreshIndicator(
                        onRefresh: () async {
                          debugPrint('🔄 Dashboard: Pull to refresh triggered');
                          await _loadData(showLoading: false, forceRefresh: true);
                        },
                        color: const Color(0xFF00D09E),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: Column(
                            children: [
                              const SizedBox(height: 15),
                              // Notification Icon
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 30,
                                      height: 30,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDFF7E2),
                                        borderRadius: BorderRadius.all(Radius.circular(25.71)),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.notifications,
                                          color: Color(0xFF093030),
                                          size: 21,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Circular Total Balance
                              _buildCircularBalance(),

                              const SizedBox(height: 20),

                              // Action Buttons
                              _buildActionButtons(),

                              const SizedBox(height: 15),

                              // Bank Cards Carousel
                              _buildBankCardsCarousel(),

                              const SizedBox(height: 15),

                              // Period Switcher
                              _buildPeriodSwitcher(),

                              const SizedBox(height: 15),

                              // Transactions List
                              _buildTransactionsList(),

                              const SizedBox(height: 100), // Space for bottom nav
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
     
    );
  }

  Widget _buildCircularBalance() {
    return GestureDetector(
      onTap: () {
        _showAddTransactionModal(context);
      },
      child: Container(
        width: 170,
        height: 170,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF00D09E).withOpacity(0.28),
              spreadRadius: 2,
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 16,
                  color: Color(0xFF666666),
                ),
                SizedBox(width: 5),
                Text(
                  'Total Balance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF666666),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat('#,##0.00').format(_totalBalance),
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF00D09E),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Total Across All Accounts',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF999999),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('SAVINGS', const Color(0xFF00D09E)),
          _buildActionButton(
            'LOANS',
            const Color(0xFF00D09E),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LoansScreen()),
              );
            },
          ),
          _buildActionButton(
            'BILLS',
            const Color(0xFF00D09E),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BillsScreen()),
              );
            },
          ),
          _buildActionButton('REPORTS', const Color(0xFF00D09E)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color primaryColor, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: primaryColor, // Use the primary color for the border
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: primaryColor, // Use primary color for the text
          ),
        ),
      ),
    );
  }

  /// Build carousel of bank cards
  Widget _buildBankCardsCarousel() {
    if (_bankAccounts.isEmpty) {
      // Show default card when no accounts
      return _buildBankCard(account: null, width: 320);
    }

    return Column(
      children: [
        SizedBox(
          height: 190, // Increased height for ATM card design
          child: PageView.builder(
            controller: _pageController,
            itemCount: _bankAccounts.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _buildBankCard(account: _bankAccounts[index], width: 300),
              );
            },
          ),
        ),
        // Page indicators
        if (_bankAccounts.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _bankAccounts.length,
                (index) => Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentPage == index
                        ? const Color(0xFF00D09E)
                        : const Color(0xFFCCCCCC),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Build a virtual ATM card design
  /// To adjust the width of the bank card, pass a width value when calling this method.
  /// Example usage: _buildBankCard(account: account, width: 350)
  Widget _buildBankCard({required BankAccount? account, double? width}) {
    // Card dimensions: Standard ATM card ratio (85.6mm x 53.98mm ≈ 1.59:1)
    // Reduced height by 10% for more compact design
    final cardWidth = width ?? 340.0;
    final cardHeight = (cardWidth / 1.59) * 0.9; // Reduced by 10%
    
    // Determine card gradient based on account type
    List<Color> cardColors;
    if (account == null) {
      cardColors = [
        const Color(0xFF1A1A2E),
        const Color(0xFF16213E),
        const Color(0xFF0F3460),
      ];
    } else {
      switch (account.accountType.toLowerCase()) {
        case 'checking':
          cardColors = [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ];
          break;
        case 'savings':
          cardColors = [
            const Color(0xFF0F4C75),
            const Color(0xFF3282B8),
            const Color(0xFFBBE1FA),
          ];
          break;
        case 'credit_card':
          cardColors = [
            const Color(0xFF2D1B69),
            const Color(0xFF8B5CF6),
            const Color(0xFFA78BFA),
          ];
          break;
        default:
          cardColors = [
            const Color(0xFF1A1A2E),
            const Color(0xFF16213E),
            const Color(0xFF0F3460),
          ];
      }
    }

    return Container(
      width: cardWidth,
      height: cardHeight,
      margin: const EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: cardColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: cardColors.first.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Background pattern
            Positioned.fill(
              child: CustomPaint(
                painter: _CardPatternPainter(),
              ),
            ),
            // Card content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top section: Chip and Bank logo area
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // EMV Chip
                      Container(
                        width: 40,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          children: [
                            // Chip lines
                            Positioned(
                              left: 6,
                              top: 6,
                              child: Container(
                                width: 28,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.amber.shade900,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                            // Chip shine
                            Positioned(
                              left: 8,
                              top: 8,
                              child: Container(
                                width: 12,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Card type indicator
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          account?.accountType.toUpperCase() ?? 'CHECKING',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Card number section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CARD NUMBER',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 8,
                          fontWeight: FontWeight.w400,
                          color: Colors.white70,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_formatCardNumber(_getLastFourDigits(account ?? _createDummyAccount()))}',
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bottom section: Account name and balance
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Account name
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'CARDHOLDER',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 8,
                                fontWeight: FontWeight.w400,
                                color: Colors.white70,
                                letterSpacing: 1.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              account?.accountName.toUpperCase() ?? 'AMERICAN BANK',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      // Balance
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'BALANCE',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 8,
                              fontWeight: FontWeight.w400,
                              color: Colors.white70,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            NumberFormat('#,##0.00').format(account?.balance ?? 40000.00),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format card number with spaces (e.g., "1234 5678 9012 3456")
  String _formatCardNumber(String lastFour) {
    return '****  ****  ****  $lastFour';
  }

  /// Create dummy account for default card
  BankAccount _createDummyAccount() {
    return const BankAccount(
      id: 'dummy',
      accountName: 'Default',
      accountType: 'checking',
      balance: 0,
      initialBalance: 0,
      currency: 'USD',
      isActive: true,
    );
  }

  Widget _buildPeriodSwitcher() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 50,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(child: _buildPeriodButton('Daily')),
          Expanded(child: _buildPeriodButton('Weekly')),
          Expanded(child: _buildPeriodButton('Monthly')),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00D09E) : Colors.transparent,
          borderRadius: BorderRadius.circular(21),
        ),
        alignment: Alignment.center,
        child: Text(
          period,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF666666),
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_recentTransactions.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Text(
          'No recent transactions',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 15,
            color: Color(0xFF052224),
          ),
        ),
      );
    }

    return Column(
      children: _recentTransactions.take(3).map((transaction) {
        return _buildTransactionItem(transaction);
      }).toList(),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.isIncome;
    final color = isIncome ? const Color(0xFF64B5F6) : const Color(0xFFFF8A65);
    IconData icon;
    
    // Determine icon based on transaction type/category
    if (transaction.category?.toLowerCase().contains('salary') ?? false) {
      icon = Icons.attach_money;
    } else if (transaction.category?.toLowerCase().contains('groceries') ?? false) {
      icon = Icons.shopping_cart_outlined;
    } else if (transaction.category?.toLowerCase().contains('rent') ?? false) {
      icon = Icons.home_outlined;
    } else {
      icon = isIncome ? Icons.trending_up : Icons.trending_down;
    }
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Transaction Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF333333),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm - MMMM dd').format(transaction.transactionDate),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF999999),
                  ),
                ),
              ],
            ),
          ),
          
          // Amount and Category
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '' : '-'}\$${NumberFormat('#,##0.00').format(transaction.amount.abs())}',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isIncome ? const Color(0xFF4CAF50) : const Color(0xFF333333),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                transaction.category ?? '',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

   void _showAddTransactionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Title
              const Text(
                'Add Transaction',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF052224),
                ),
              ),
              const SizedBox(height: 24),
              // 2x2 Grid of options
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _buildModalOption(
                    icon: Icons.description_outlined,
                    title: 'Full Form',
                    description: 'Complete Transaction Form With All Fields And Options',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showFullFormModal(context);
                    },
                  ),
                  _buildModalOption(
                    icon: Icons.rocket_launch_outlined,
                    title: 'Quick Add',
                    description: 'Fast Entry With Essential Fields Only',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showQuickAddModal(context);
                    },
                  ),
                  _buildModalOption(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Transaction Analyzer',
                    description: 'AI-Powered Text Analysis To Extract Transaction Details',
                    onTap: () {
                      Navigator.of(context).pop();
                      _showTransactionAnalyzerModal(context);
                    },
                  ),
                  _buildModalOption(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Upload Receipt',
                    description: 'AI-Powered Text Analysis To Extract Transaction Details',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to upload receipt
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF00D09E).withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF00D09E).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF00D09E),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF052224),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w400,
                color: Colors.grey[600],
                height: 1.3,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  void _showFullFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return _FullFormModalContent(
              scrollController: scrollController,
              bankAccounts: _bankAccounts,
              onTransactionCreated: () {
                // Refresh dashboard data after transaction is created
                _loadData(showLoading: false, forceRefresh: true);
              },
            );
          },
        );
      },
    );
  }

  void _showQuickAddModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.8,
          builder: (BuildContext context, ScrollController scrollController) {
            return _QuickAddModalContent(
              scrollController: scrollController,
              bankAccounts: _bankAccounts,
              onTransactionCreated: () {
                // Refresh dashboard data after transaction is created
                _loadData(showLoading: false, forceRefresh: true);
              },
            );
          },
        );
      },
    );
  }

  void _showTransactionAnalyzerModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          builder: (BuildContext context, ScrollController scrollController) {
            return _TransactionAnalyzerModalContent(
              scrollController: scrollController,
              bankAccounts: _bankAccounts,
              onAnalyzed: () {
                _loadData(showLoading: false, forceRefresh: true);
              },
            );
          },
        );
      },
    );
  }

}

// Transaction Analyzer modal: form for analyze-text API and response handling
class _TransactionAnalyzerModalContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<BankAccount> bankAccounts;
  final VoidCallback onAnalyzed;

  const _TransactionAnalyzerModalContent({
    required this.scrollController,
    required this.bankAccounts,
    required this.onAnalyzed,
  });

  @override
  State<_TransactionAnalyzerModalContent> createState() =>
      _TransactionAnalyzerModalContentState();
}

class _TransactionAnalyzerModalContentState
    extends State<_TransactionAnalyzerModalContent> {
  final DataService _dataService = DataService();
  final TextEditingController _transactionTextController =
      TextEditingController();
  final TextEditingController _savingsAccountIdController =
      TextEditingController();

  String? _selectedBankAccountId;
  String? _selectedBillId;
  String? _selectedLoanId;
  bool _isAnalyzing = false;
  String? _errorMessage;
  String? _successMessage;

  List<Bill> _bills = [];
  List<Loan> _loans = [];
  bool _loadingOptions = true;

  @override
  void initState() {
    super.initState();
    if (widget.bankAccounts.isNotEmpty) {
      _selectedBankAccountId = widget.bankAccounts.first.id;
    }
    _loadBillsAndLoans();
  }

  @override
  void dispose() {
    _transactionTextController.dispose();
    _savingsAccountIdController.dispose();
    super.dispose();
  }

  Future<void> _loadBillsAndLoans() async {
    try {
      final billsResult =
          await _dataService.getBills(status: 'PENDING', limit: 50);
      final bills = billsResult['bills'] as List<Bill>? ?? [];
      final loans = await _dataService.getUserLoans(status: 'ACTIVE', limit: 50);
      if (mounted) {
        setState(() {
          _bills = bills;
          _loans = loans;
          _loadingOptions = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loadingOptions = false;
        });
      }
    }
  }

  Future<void> _handleAnalyze() async {
    final text = _transactionTextController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter transaction text (e.g. SMS or notification).';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final transaction = await _dataService.analyzeTransactionText(
        transactionText: text,
        bankAccountId: _selectedBankAccountId?.isEmpty ?? true
            ? null
            : _selectedBankAccountId,
        billId:
            _selectedBillId?.isEmpty ?? true ? null : _selectedBillId,
        loanId:
            _selectedLoanId?.isEmpty ?? true ? null : _selectedLoanId,
        savingsAccountId: _savingsAccountIdController.text.trim().isEmpty
            ? null
            : _savingsAccountIdController.text.trim(),
      );

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _successMessage =
              'Transaction created: ${transaction.description} (\$${transaction.amount.toStringAsFixed(2)})';
          _errorMessage = null;
          _transactionTextController.clear();
        });
        Navigator.of(context).pop();
        widget.onAnalyzed();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_successMessage!),
            backgroundColor: const Color(0xFF00D09E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _successMessage = null;
        });
      }
    }
  }

  Widget _buildDropdown<T>({
    required String label,
    required String? value,
    required List<T> items,
    required String Function(T) getValue,
    required String Function(T) getDisplayText,
    required void Function(String?) onChanged,
    bool requiredField = false,
  }) {
    final effectiveItems = [if (!requiredField) null, ...items.map(getValue)];
    String display = (requiredField ? 'Select $label' : 'None');
    if (value != null && value.isNotEmpty) {
      for (final x in items) {
        if (getValue(x) == value) {
          display = getDisplayText(x);
          break;
        }
      }
      if (display == (requiredField ? 'Select $label' : 'None')) {
        display = value;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (requiredField ? ' *' : ' (Optional)'),
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value?.isEmpty ?? true ? null : value,
              isExpanded: true,
              items: effectiveItems.map((String? id) {
                String displayText = 'None';
                if (id != null && id.isNotEmpty) {
                  T? found;
                  for (final x in items) {
                    if (getValue(x) == id) {
                      found = x;
                      break;
                    }
                  }
                  displayText = found != null ? getDisplayText(found) : id;
                }
                return DropdownMenuItem<String?>(
                  value: id,
                  child: Text(
                    displayText,
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF052224),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Transaction Analyzer',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF052224),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Paste SMS or notification text to extract and create a transaction.',
              style: TextStyle(
                fontSize: 12,
                fontFamily: 'Poppins',
                color: Color(0xFF666666),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Transaction text (required)
                  const Text(
                    'Transaction text *',
                    style: TextStyle(
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF00D09E).withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _transactionTextController,
                      maxLines: 4,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF052224),
                      ),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText:
                            'e.g. You spent \$9.50 at AZDEHAR A. Balance: \$990.50',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bank account (optional)
                  _buildDropdown<BankAccount>(
                    label: 'Bank account',
                    value: _selectedBankAccountId,
                    items: widget.bankAccounts,
                    getValue: (a) => a.id,
                    getDisplayText: (a) => a.accountName,
                    onChanged: (v) =>
                        setState(() => _selectedBankAccountId = v),
                    requiredField: false,
                  ),
                  const SizedBox(height: 16),
                  if (_loadingOptions)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else ...[
                    _buildDropdown<Bill>(
                      label: 'Link to bill',
                      value: _selectedBillId,
                      items: _bills,
                      getValue: (b) => b.id,
                      getDisplayText: (b) => b.billName,
                      onChanged: (v) => setState(() => _selectedBillId = v),
                    ),
                    const SizedBox(height: 16),
                    _buildDropdown<Loan>(
                      label: 'Link to loan',
                      value: _selectedLoanId,
                      items: _loans,
                      getValue: (l) => l.id,
                      getDisplayText: (l) =>
                          l.purpose ?? 'Loan #${l.id.substring(0, 8)}',
                      onChanged: (v) => setState(() => _selectedLoanId = v),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Savings account ID (Optional)',
                          style: TextStyle(
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF666666),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF00D09E).withOpacity(0.3),
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _savingsAccountIdController,
                            style: const TextStyle(
                              fontSize: 14,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF052224),
                            ),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: 'Savings account ID',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (_errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline,
                              color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                color: Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _handleAnalyze,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Analyze & Create Transaction',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Quick Add Modal Content - Simplified form with essential fields only
class _QuickAddModalContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<BankAccount> bankAccounts;
  final VoidCallback onTransactionCreated;

  const _QuickAddModalContent({
    required this.scrollController,
    required this.bankAccounts,
    required this.onTransactionCreated,
  });

  @override
  State<_QuickAddModalContent> createState() => _QuickAddModalContentState();
}

class _QuickAddModalContentState extends State<_QuickAddModalContent> {
  final DataService _dataService = DataService();
  bool _isSubmitting = false;

  // Form state - only essential fields
  String? selectedBankAccountId;
  String selectedTransactionType = 'DEBIT';
  String? selectedCategory;
  DateTime selectedDate = DateTime.now();

  // Controllers
  late final TextEditingController amountController;
  late final TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    // Set default bank account if available
    if (widget.bankAccounts.isNotEmpty) {
      selectedBankAccountId = widget.bankAccounts.first.id;
    }
    amountController = TextEditingController();
    descriptionController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (selectedBankAccountId == null || selectedBankAccountId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _dataService.createTransaction(
        bankAccountId: selectedBankAccountId!,
        amount: amount,
        transactionType: selectedTransactionType,
        description: description,
        category: selectedCategory,
        transactionDate: selectedDate,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTransactionCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully'),
            backgroundColor: Color(0xFF00D09E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBankAccountDropdown() {
    if (widget.bankAccounts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Account *',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.withOpacity(0.5)),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'No bank accounts available',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildDropdownField(
      label: 'Bank Account *',
      value: selectedBankAccountId,
      items: widget.bankAccounts.map((acc) => acc.id).toList(),
      onChanged: (value) {
        setState(() {
          selectedBankAccountId = value;
        });
      },
      displayText: (value) {
        if (value == null) return 'Select Bank Account';
        final account = widget.bankAccounts.firstWhere((acc) => acc.id == value);
        return account.accountName;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String?> items,
    required Function(String?) onChanged,
    String Function(String?)? displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              items: items.map((String? item) {
                return DropdownMenuItem<String?>(
                  value: item,
                  child: Text(
                    displayText != null
                        ? displayText(item)
                        : (item ?? 'None'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF052224),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF052224),
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MM / dd / yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00D09E).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF052224),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00D09E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Quick Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF052224),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Bank Account
                  _buildBankAccountDropdown(),
                  const SizedBox(height: 16),
                  // Transaction Type and Category
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Type *',
                          value: selectedTransactionType,
                          items: ['CREDIT', 'DEBIT'],
                          onChanged: (value) {
                            setState(() {
                              selectedTransactionType = value ?? 'DEBIT';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Category (Optional)',
                          value: selectedCategory,
                          items: [
                            null,
                            'Food',
                            'Transport',
                            'Shopping',
                            'Bills',
                            'Entertainment',
                            'Healthcare',
                            'Education',
                            'Other',
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Amount and Date
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Amount *',
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                         
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateField(
                          label: 'Date',
                          date: selectedDate,
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Description
                  _buildTextField(
                    label: 'Description *',
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 32),
                  // Create Transaction Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'Creating...' : 'Create Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        disabledBackgroundColor: const Color(0xFF00D09E).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter for card background pattern (subtle circles only, no lines)
class _CardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..style = PaintingStyle.fill;

    // Draw very subtle circles in background (no lines)
    for (int i = 0; i < 3; i++) {
      canvas.drawCircle(
        Offset(size.width * (0.2 + i * 0.3), size.height * 0.3),
        size.width * 0.12,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// StatefulWidget for the full form modal content
class _FullFormModalContent extends StatefulWidget {
  final ScrollController scrollController;
  final List<BankAccount> bankAccounts;
  final VoidCallback onTransactionCreated;

  const _FullFormModalContent({
    required this.scrollController,
    required this.bankAccounts,
    required this.onTransactionCreated,
  });

  @override
  State<_FullFormModalContent> createState() => _FullFormModalContentState();
}

class _FullFormModalContentState extends State<_FullFormModalContent> {
  final DataService _dataService = DataService();
  bool _isSubmitting = false;

  // Form state variables
  String? selectedBankAccountId;
  bool isRecurring = false;
  String? selectedTransactionType = 'DEBIT';
  String? selectedCategory;
  String? selectedTransactionPurpose;
  String? selectedRecurringFrequency;
  DateTime selectedDate = DateTime.now();
  
  // Controllers
  late final TextEditingController amountController;
  late final TextEditingController referenceNumberController;
  late final TextEditingController merchantController;
  late final TextEditingController locationController;
  late final TextEditingController descriptionController;
  late final TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    // Set default bank account if available
    if (widget.bankAccounts.isNotEmpty) {
      selectedBankAccountId = widget.bankAccounts.first.id;
    }
    amountController = TextEditingController();
    referenceNumberController = TextEditingController();
    merchantController = TextEditingController();
    locationController = TextEditingController();
    descriptionController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    amountController.dispose();
    referenceNumberController.dispose();
    merchantController.dispose();
    locationController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Add Transaction',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFF052224),
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Form content
          Expanded(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Row 1: Bank Account and Recurring Transaction
                  Row(
                    children: [
                      Expanded(
                        child: _buildBankAccountDropdown(),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Recurring Transaction',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                color: Color(0xFF666666),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Switch(
                              value: isRecurring,
                              onChanged: (value) {
                                setState(() {
                                  isRecurring = value;
                                });
                              },
                              activeColor: const Color(0xFF00D09E),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 2: Transaction Type and Categories
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Transaction Type',
                          value: selectedTransactionType,
                          items: ['CREDIT', 'DEBIT'],
                          onChanged: (value) {
                            setState(() {
                              selectedTransactionType = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Category (Optional)',
                          value: selectedCategory,
                          items: [
                            null,
                            'Food',
                            'Transport',
                            'Shopping',
                            'Bills',
                            'Entertainment',
                            'Healthcare',
                            'Education',
                            'Other',
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 3: Transaction Purpose and Amount
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Transaction Purpose (Optional)',
                          value: selectedTransactionPurpose,
                          items: [
                            null,
                            'BILL',
                            'UTILITY',
                            'SAVINGS',
                            'LOAN',
                            'OTHER',
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedTransactionPurpose = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Amount *',
                          controller: amountController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Row 4: Reference Number and Merchant
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Reference Number',
                          controller: referenceNumberController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Merchant',
                          controller: merchantController,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Location (full width)
                  _buildTextField(
                    label: 'Location',
                    controller: locationController,
                  ),
                  const SizedBox(height: 16),
                  // Description (full width)
                  _buildTextField(
                    label: 'Description *',
                    controller: descriptionController,
                  ),
                  const SizedBox(height: 16),
                  // Notes (full width)
                  _buildTextField(
                    label: 'Notes',
                    controller: notesController,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 16),
                  // Recurring Frequency (if recurring is enabled)
                  if (isRecurring) ...[
                    const SizedBox(height: 16),
                    _buildDropdownField(
                      label: 'Recurring Frequency',
                      value: selectedRecurringFrequency,
                      items: [
                        null,
                        'DAILY',
                        'WEEKLY',
                        'MONTHLY',
                        'YEARLY',
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedRecurringFrequency = value;
                        });
                      },
                    ),
                  ],
                  const SizedBox(height: 16),
                  // Transaction Date
                  _buildDateField(
                    label: 'Transaction Date',
                    date: selectedDate,
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          selectedDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  // Create Transaction Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _handleSubmit,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Icon(Icons.send, color: Colors.white),
                      label: Text(
                        _isSubmitting ? 'Creating...' : 'Create Transaction',
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D09E),
                        disabledBackgroundColor: const Color(0xFF00D09E).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubmit() async {
    // Validation
    if (selectedBankAccountId == null || selectedBankAccountId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a bank account')),
      );
      return;
    }

    final amountText = amountController.text.trim();
    if (amountText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an amount')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount greater than 0')),
      );
      return;
    }

    final description = descriptionController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    if (isRecurring && (selectedRecurringFrequency == null || selectedRecurringFrequency!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a recurring frequency')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _dataService.createTransaction(
        bankAccountId: selectedBankAccountId!,
        amount: amount,
        transactionType: selectedTransactionType ?? 'DEBIT',
        description: description,
        category: selectedCategory,
        referenceNumber: referenceNumberController.text.trim().isEmpty
            ? null
            : referenceNumberController.text.trim(),
        merchant: merchantController.text.trim().isEmpty ? null : merchantController.text.trim(),
        location: locationController.text.trim().isEmpty ? null : locationController.text.trim(),
        notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
        transactionDate: selectedDate,
        isRecurring: isRecurring,
        recurringFrequency: selectedRecurringFrequency,
        transactionPurpose: selectedTransactionPurpose,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onTransactionCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Transaction created successfully'),
            backgroundColor: Color(0xFF00D09E),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create transaction: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildBankAccountDropdown() {
    if (widget.bankAccounts.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Account *',
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.red.withOpacity(0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: const Center(
              child: Text(
                'No bank accounts available',
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'Poppins',
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return _buildDropdownField(
      label: 'Bank Account *',
      value: selectedBankAccountId,
      items: widget.bankAccounts.map((acc) => acc.id).toList(),
      onChanged: (value) {
        setState(() {
          selectedBankAccountId = value;
        });
      },
      displayText: (value) {
        if (value == null) return 'Select Bank Account';
        final account = widget.bankAccounts.firstWhere((acc) => acc.id == value);
        return account.accountName;
      },
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String?> items,
    required Function(String?) onChanged,
    String Function(String?)? displayText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String?>(
              value: value,
              isExpanded: true,
              items: items.map((String? item) {
                return DropdownMenuItem<String?>(
                  value: item,
                  child: Text(
                    displayText != null
                        ? displayText(item)
                        : (item ?? 'None'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF052224),
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Color(0xFF00D09E),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: const Color(0xFF00D09E).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
              color: Color(0xFF052224),
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Colors.white,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime date,
    required VoidCallback onTap,
  }) {
    final dateFormat = DateFormat('MM / dd / yyyy');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Color(0xFF666666),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onTap,
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00D09E).withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dateFormat.format(date),
                    style: const TextStyle(
                      fontSize: 14,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF052224),
                    ),
                  ),
                ),
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00D09E),
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
