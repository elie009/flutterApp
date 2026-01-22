import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/data_service.dart';
import '../../models/transaction.dart';
import '../../models/bank_account.dart';

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

  Future<void> _loadData({bool showLoading = true}) async {
    if (showLoading) {
      setState(() => _isLoading = true);
    }
    try {
      // Load dashboard data
      debugPrint('📊 Dashboard: Loading data...');
      final summary = await DataService().getDashboardSummary();
      debugPrint('📊 Dashboard: Got summary with totalBalance: ${summary.totalBalance}');
      
      // Load accounts (handle errors gracefully) - fetch only active accounts
      List<BankAccount> accounts = [];
      try {
        accounts = await DataService().getBankAccounts(isActive: true);
        debugPrint('📊 Dashboard: Loaded ${accounts.length} active bank accounts');
      } catch (e) {
        debugPrint('⚠️ Dashboard: Error loading bank accounts (ignoring): $e');
        // Continue without accounts
      }
      
      // Load transactions (handle errors gracefully)
      List<Transaction> transactions = [];
      try {
        transactions = await DataService().getTransactions(limit: 5);
        debugPrint('📊 Dashboard: Loaded ${transactions.length} transactions');
      } catch (e) {
        debugPrint('⚠️ Dashboard: Error loading transactions (ignoring): $e');
        // Continue without transactions
      }

      setState(() {
        _totalBalance = summary.totalBalance; // Use API value
        _totalExpense = _calculateExpense(transactions);
        _recentTransactions = transactions;
        _bankAccounts = accounts; // Store all accounts for carousel
        _isLoading = false;
      });
      debugPrint('✅ Dashboard: State updated with _totalBalance: $_totalBalance');
    } catch (e, stackTrace) {
      debugPrint('❌ Dashboard: Error loading data: $e');
      debugPrint('❌ Dashboard: Stack trace: $stackTrace');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  debugPrint('🔄 Dashboard: Pull to refresh triggered');
                  await _loadData(showLoading: false);
                },
                color: const Color(0xFF00D09E),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(), // Enable scrolling even when content is small
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
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8E8E8),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                size: 20,
                                color: Color(0xFF333333),
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
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 0),
    );
  }

  Widget _buildCircularBalance() {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00D09E).withOpacity(0.28),
            spreadRadius: 2,
            blurRadius: 16
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
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildActionButton('SAVINGS', const Color(0xFF00D09E)),
          _buildActionButton('LOANS', const Color(0xFF00D09E)),
          _buildActionButton('BILLS', const Color(0xFF00D09E)),
          _buildActionButton('REPORTS', const Color(0xFF00D09E)),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, Color primaryColor) {
    return Container(
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
