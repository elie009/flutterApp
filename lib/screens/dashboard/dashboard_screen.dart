import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/data_service.dart';
import '../../services/storage_service.dart';
import '../../config/app_config.dart';
import '../../models/transaction.dart';
import '../../models/bank_account.dart';
import '../../models/dashboard_summary.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String _selectedPeriod = 'Daily';
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

  // Design colors from reference (light green dashboard)
  static const _lightGreen = Color(0xFFb3ee9a);
  static const _lightGreenBg = Color(0xFFE8F5E9);
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF666666);
  static const _textLightGray = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _lightGreen))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Fixed header (stays visible when scrolling)
                _buildHeader(context),
                // Scrollable content below header
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      debugPrint('🔄 Dashboard: Pull to refresh triggered');
                      await _loadData(showLoading: false, forceRefresh: true);
                    },
                    color: _lightGreen,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildCircularBalance(),
                          _buildQuickAccessButtons(),
                          _buildYourCardsSection(),
                          const SizedBox(height: 24),
                          _buildPeriodSwitcher(),
                          _buildRecentTransactionsSection(context),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 0),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: const BoxDecoration(
        color: _lightGreen,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start, // Allows children to start at top, but we can shift notifications down
            children: [
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _headerDark,
                ),
              ),
              // Move notification bell a bit lower - tap to open notifications screen
              GestureDetector(
                onTap: () => context.push('/notifications'),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0), // Adjust this value to move it further down
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.notifications_outlined, color: _headerDark, size: 22),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                            border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Text(
            'Welcome back!',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _headerDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBalance() {
    final currencySymbol = AppConfig.currencySymbol;
    return GestureDetector(
      onTap: () => _showAddTransactionModal(context),
      child: Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 20),
        child: Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _lightGreenBg, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _lightGreen.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$currencySymbol${NumberFormat('#,##0').format(_totalBalance)}',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _lightGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Across All Accounts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _textLightGray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+ Tap to add transaction',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF388E3C), // Replaces _darkGreen
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAccessButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildQuickAccessButton(
            icon: Icons.account_balance_outlined,
            label: 'SAVINGS',
            onTap: () => context.push('/savings'),
          ),
          _buildQuickAccessButton(
            icon: Icons.attach_money_rounded,
            label: 'LOANS',
            onTap: () => context.push('/loans'),
          ),
          _buildQuickAccessButton(
            icon: Icons.description_outlined,
            label: 'BILLS',
            onTap: () => context.push('/bills'),
          ),
          _buildQuickAccessButton(
            icon: Icons.bar_chart_rounded,
            label: 'REPORTS',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccessButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: _lightGreenBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _headerDark, size: 26),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _headerDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYourCardsSection() {
    final hasMultiple = _bankAccounts.length > 1;
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Your Cards',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _headerDark,
                ),
              ),
              const Spacer(),
              if (hasMultiple) ...[
                GestureDetector(
                  onTap: () {
                    if (_currentPage > 0) {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _lightGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_left_rounded, color: _headerDark, size: 24),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    if (_currentPage < _bankAccounts.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _lightGreenBg,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chevron_right_rounded, color: _headerDark, size: 24),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          _buildBankCardsCarousel(),
        ],
      ),
    );
  }

  /// Build carousel of bank cards
  Widget _buildBankCardsCarousel() {
    final accounts = _bankAccounts.isEmpty ? [null] : _bankAccounts;
    return Column(
      children: [
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _pageController,
            itemCount: accounts.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              final account = accounts[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: GestureDetector(
                  onTap: () => context.push('/banks'),
                  child: _buildBankCard(account: account, width: 320),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            accounts.length,
            (index) => Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _currentPage == index ? _lightGreen : _textLightGray,
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
                  // Top section: CHECKING pill left, card icon right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Card type pill (light grey)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          account?.accountType.toUpperCase() ?? 'CHECKING',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      // Light green card icon
                      Icon(Icons.credit_card_rounded, color: _lightGreen, size: 28),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  // Card number: .... .... .... 0655
                  Text(
                    '....  ....  ....  ${_getLastFourDigits(account ?? _createDummyAccount())}',
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Bottom: BANK BPI (left), BALANCE P22,250 (right)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'BANK ${(account?.accountName ?? 'BPI').toUpperCase()}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'BALANCE ${AppConfig.currencySymbol}${NumberFormat('#,##0').format(account?.balance ?? 22250.0)}',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _lightGreenBg, width: 1),
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
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? _lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          period,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : _textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 20, right: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Recent Transactions',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: _headerDark,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/transactions'),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _lightGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionsList(),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_recentTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Text(
            'No recent transactions',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              color: _textGray,
            ),
          ),
        ),
      );
    }
    return Column(
      children: _recentTransactions.take(5).map((t) => _buildTransactionItem(t)).toList(),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isIncome = transaction.isIncome;
    final currencySymbol = AppConfig.currencySymbol;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE5E5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.bolt_rounded,
              color: Colors.red.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _headerDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  DateFormat('HH:mm - MMMM dd').format(transaction.transactionDate),
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: _textLightGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isIncome ? '' : '-'}$currencySymbol${NumberFormat('#,##0.00').format(transaction.amount.abs())}',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isIncome ? const Color(0xFF4CAF50) : Colors.red.shade700,
            ),
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
                      // TODO: Navigate to quick add
                    },
                  ),
                  _buildModalOption(
                    icon: Icons.auto_awesome_outlined,
                    title: 'Transaction Analyzer',
                    description: 'AI-Powered Text Analysis To Extract Transaction Details',
                    onTap: () {
                      Navigator.of(context).pop();
                      // TODO: Navigate to transaction analyzer
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
            color: const Color(0xFFb3ee9a).withOpacity(0.3),
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
                color: const Color(0xFFb3ee9a).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: const Color(0xFFb3ee9a),
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
            return _FullFormModalContent(scrollController: scrollController);
          },
        );
      },
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

  const _FullFormModalContent({required this.scrollController});

  @override
  State<_FullFormModalContent> createState() => _FullFormModalContentState();
}

class _FullFormModalContentState extends State<_FullFormModalContent> {
  // Form state variables
  String? selectedBankAccount = 'All Accounts';
  bool isRecurring = false;
  String? selectedTransactionType = 'All Types';
  String? selectedCategory = 'All Categories';
  String? selectedTransactionPurpose = 'Transaction Purpose';
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
    amountController = TextEditingController(text: '0.00');
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
                        child: _buildDropdownField(
                          label: 'Bank Account',
                          value: selectedBankAccount,
                          items: ['All Accounts', 'Main Account', 'Savings', 'Credit Card'],
                          onChanged: (value) {
                            setState(() {
                              selectedBankAccount = value;
                            });
                          },
                        ),
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
                              activeColor: const Color(0xFFb3ee9a),
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
                          items: ['All Types', 'Credit', 'Debit', 'Transfer'],
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
                          label: 'Categories',
                          value: selectedCategory,
                          items: ['All Categories', 'Food', 'Transport', 'Shopping', 'Bills'],
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
                          label: 'Transaction Purpose',
                          value: selectedTransactionPurpose,
                          items: ['Transaction Purpose', 'Purchase', 'Payment', 'Transfer', 'Refund'],
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
                          label: 'Amount',
                          controller: amountController,
                          keyboardType: TextInputType.number,
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
                    label: 'Description',
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
                  // Row 5: Transaction Date and Split Transaction
                  Row(
                    children: [
                      Expanded(
                        child: _buildDateField(
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
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Implement split transaction
                          },
                          child: Container(
                            height: 56,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFb3ee9a).withOpacity(0.3),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                // Icon removed as instructed
                                const Text(
                                  'Split Transaction',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w400,
                                    color: Color(0xFF052224),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Create Transaction Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement create transaction
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction created successfully')),
                        );
                      },
                      icon: const Icon(Icons.send, color: Colors.white),
                      label: const Text(
                        'Create Transaction',
                        style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFb3ee9a),
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
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
              color: const Color(0xFFb3ee9a).withOpacity(0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
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
                color: Color(0xFFb3ee9a),
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
              color: const Color(0xFFb3ee9a).withOpacity(0.3),
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
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                color: const Color(0xFFb3ee9a).withOpacity(0.3),
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
                  color: Color(0xFFb3ee9a),
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
