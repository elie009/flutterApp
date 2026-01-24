import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/data_service.dart';
import '../../models/transaction.dart';
import '../../widgets/triangle_painter.dart';


class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  bool _isLoading = true;
  double _totalBalance = 0.0;
  double _totalIncome = 0.0;
  double _totalExpense = 0.0;
  List<Transaction> _transactions = [];
  final DataService _dataService = DataService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Load total balance
      final summary = await _dataService.getDashboardSummary();
      
      // Load all transactions
      final transactions = await _dataService.getTransactions(limit: 100);
      
      // Calculate totals based on transaction type
      double income = 0.0;
      double expense = 0.0;
      for (var transaction in transactions) {
        // Calculate Total Income from all CREDIT transactions
        if (transaction.transactionType.toLowerCase() == 'credit') {
          income += transaction.amount;
        }
        // Calculate Total Expense from all DEBIT transactions
        else if (transaction.transactionType.toLowerCase() == 'debit') {
          expense += transaction.amount;
        }
        // Note: 'transfer' transactions are excluded from income/expense calculations
      }
      
      debugPrint('📊 Transactions: Total CREDIT (Income): $income, Total DEBIT (Expense): $expense');

      setState(() {
        _totalBalance = summary.totalBalance;
        _totalIncome = income;
        _totalExpense = expense;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading transactions: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final designWidth = 412.0;
    final designHeight = 932.0;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Center(
        child: SizedBox(
          width: designWidth,
          height: designHeight,
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF00D09E),
            ),
            child: Stack(
              children: [

            // Small top-right triangle
            Positioned.fill(
              child: Transform.rotate(
                angle: 0.4,
                child: CustomPaint(
                  painter: TrianglePainter(),
                ),
              ),
            ),
          
            // Back button (left: 28, top: 59) - much larger, bold arrow in a thick circle background
            Positioned(
              left: 5,
              top: 51,
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 48,
                  height: 48,
                 
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFFF1FFF3),
                    size: 22, // bigger arrow
                    weight: 900, // make as bold as supported
                  ),
                ),
              ),
            ),
            
            // Title "Recent Transactions" (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 64,
              child: Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: 'Recent Transactions',
                        style: TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700, // Changed to bold
                          height: 1.10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Notification icon
            Positioned(
              left: 364,
              top: 51,
              child: Container(
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
            ),
            // Three summary cards side by side (Total Balance, Total Income, Total Expense)
            // Total Balance card (leftmost)
            // Center the three summary cards with a Row inside a Positioned
            Positioned(
              left: 0,
              right: 0,
              top: 115,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _showSummaryModal(context,  const Color(0xFF0E3E3E)),
                    child: _buildThreeCardSummary(
                      label: 'Total Balance',
                      amount: _totalBalance,
                      icon: Icons.check,
                      iconColor: const Color(0xFF0E3E3E),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _showSummaryModal(context, const Color(0xFF00D09E)),
                    child: _buildThreeCardSummary(
                      label: 'Total Income',
                      amount: _totalIncome,
                      icon: Icons.trending_up,
                      iconColor: const Color(0xFF00D09E),
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () => _showSummaryModal(context,const Color(0xFFFF4444)),
                    child: _buildThreeCardSummary(
                      label: 'Total Expense',
                      amount: _totalExpense,
                      icon: Icons.trending_down,
                      iconColor: const Color(0xFFFF4444),
                    ),
                  ),
                ],
              ),
            ),
            // White bottom section (top: 205)
            Positioned(
              left: 0,
              top: 205,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00D09E),
                        ),
                      )
                    : _buildTransactionsList(),
              ),
            ),

          // Floating action button at lower right corner
          Positioned(
            right: 28,
            bottom: 16,
            child: GestureDetector(
              onTap: () {
                _showAddTransactionModal(context);
              },
              child: Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09E),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x2900D09E),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
            ),
          ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 2),
    );
  }

  Widget _buildStatusBar() {
    final now = DateTime.now();
    final timeString = DateFormat('HH:mm').format(now);
    
    return Positioned(
      left: 0,
      top: 0,
      width: 430,
      height: 32,
      child: Stack(
        children: [
          // Time display (left: 37, top: 9)
          Positioned(
            left: 37,
            top: 9,
            child: Text(
              timeString,
              style: const TextStyle(
                fontSize: 13,
                fontFamily: 'League Spartan',
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
          
          // Status icons
          // Signal icon (left: 338, top: 9)
          Positioned(
            left: 338,
            top: 9,
            child: Container(
              width: 13,
              height: 11,
              color: Colors.white,
            ),
          ),
          // WiFi icon (left: 356, top: 11)
          Positioned(
            left: 356,
            top: 11,
            child: Container(
              width: 15,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(58),
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
          // Battery icon (left: 377, top: 12)
          Positioned(
            left: 377,
            top: 12,
            child: Container(
              width: 12,
              height: 7,
              color: Colors.white,
            ),
          ),
          // Battery frame (left: 376, top: 11)
          Positioned(
            left: 376,
            top: 11,
            child: Container(
              width: 17,
              height: 9,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCardPositioned({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
    required double iconTop,
    required double iconLeft,
    required double labelTop,
    required double labelLeft,
    required double amountTop,
    required double amountLeft,
  }) {
    return Container(
      width: 171,
      height: 101,
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(14.89),
      ),
      child: Stack(
        children: [
          // Icon
          Positioned(
            left: iconLeft,
            top: iconTop,
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),
          // Label
          Positioned(
            left: labelLeft,
            top: labelTop,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF093030),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Amount
          Positioned(
            left: amountLeft,
            top: amountTop,
            child: Text(
              _formatCurrency(amount),
              style: TextStyle(
                color: textColor,
                fontSize: 20,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSummaryCard({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      height: 101,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(14.89),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Icon at top center
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 25,
              ),
            ],
          ),
          // Label and amount at bottom
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatCurrency(amount),
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (_transactions.isEmpty) {
      return const Center(
        child: Text(
          'No transactions found',
          style: TextStyle(
            color: Color(0xFF093030),
            fontSize: 16,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }

    // Group transactions by month
    final Map<String, List<Transaction>> groupedTransactions = {};
    for (var transaction in _transactions) {
      final monthKey = DateFormat('MMMM yyyy').format(transaction.transactionDate);
      groupedTransactions.putIfAbsent(monthKey, () => []).add(transaction);
    }

    // Sort months in descending order
    final sortedMonths = groupedTransactions.keys.toList()
      ..sort((a, b) {
        final dateA = DateFormat('MMMM yyyy').parse(a);
        final dateB = DateFormat('MMMM yyyy').parse(b);
        return dateB.compareTo(dateA);
      });

    return RefreshIndicator(
      onRefresh: _loadData,
      color: const Color(0xFF00D09E),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(37, 30, 37, 100),
        itemCount: sortedMonths.length,
        itemBuilder: (context, monthIndex) {
          final month = sortedMonths[monthIndex];
          final monthTransactions = groupedTransactions[month]!;
          
          // Sort transactions within month by date (newest first)
          monthTransactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Month header
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: Text(
                  month,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              
              // Transactions for this month
              ...monthTransactions.asMap().entries.map((entry) {
                final index = entry.key;
                final transaction = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index < monthTransactions.length - 1 ? 22 : 0,
                  ),
                  child: _buildTransactionItem(transaction),
                );
              }),
              
              if (monthIndex < sortedMonths.length - 1) const SizedBox(height: 35),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTransactionItem(Transaction transaction) {
    final isPositive = transaction.isIncome;
    final amount = isPositive ? transaction.amount : -transaction.amount;
    final dateFormat = DateFormat('HH:mm - MMMM dd');
    final formattedDate = dateFormat.format(transaction.transactionDate);

    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon (circular with line-graph icon)
            _buildTransactionIcon(transaction, isPositive),
            
            const SizedBox(width: 16),
            
            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description (bold)
                  Text(
                    transaction.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Timestamp and category side by side
                  Row(
                    children: [
                      // Timestamp (blue)
                      Flexible(
                        child: Text(
                          formattedDate,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF0068FF),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      // Vertical separator
                      Container(
                        width: 1,
                        height: 12,
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        color: const Color(0xFF00D09E),
                      ),
                      // Category (teal/green)
                      Flexible(
                        child: Text(
                          transaction.category ?? 'Uncategorized',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF00D09E),
                            fontSize: 12,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(width: 8),
            
            // Amount (green for income, red for expense)
            Flexible(
              child: Text(
                '${isPositive ? '' : '-'}${_formatCurrencyEuropean(amount.abs())}',
                textAlign: TextAlign.end,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isPositive ? const Color(0xFF00D09E) : const Color(0xFFFF4444),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Separator line (light grey, full width)
        Container(
          height: 1,
          color: Colors.grey.withOpacity(0.2),
        ),
      ],
    );
  }

  Widget _buildTransactionIcon(Transaction transaction, bool isIncome) {
    // Blue for income, red for expenses
    final iconColor = isIncome 
        ? const Color(0xFF6DB6FE) 
        : const Color(0xFFFF4444);

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: iconColor,
        shape: BoxShape.circle,
      ),
      child: Icon(
        isIncome ? Icons.trending_up : Icons.trending_down,
        color: Colors.white,
        size: 24,
      ),
    );
  }
  
  Widget _buildThreeCardSummary({
    required String label,
    required double amount,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: 110,
      height: 60,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Amount (centered, first row)
          Text(
            _formatCurrencyEuropean(amount),
            style: const TextStyle(
              color: Color(0xFF052224),
              fontSize: 15,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // Icon and label row (icon left, label right) - no spacing between amount and this row
          Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 16,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  String _formatCurrencyEuropean(double amount) {
    // US format: 19,150.00 (comma as thousands separator, period as decimal separator)
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '\$' + formatter.format(amount);
  }

  String _formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 2,
    );
    return formatter.format(amount);
  }

  void _showSummaryModal(BuildContext context, Color iconColor) {
    // Modal local state holders
    DateTime? _dateFrom;
    DateTime? _dateTo;
    int? _limit;
    String? _selectedTransactionType;
    String? _selectedCategory;
    String? _selectedBankAccount;

    // Dummy dropdown lists (replace with your data)
    final List<String> transactionTypes = ['All', 'Income', 'Expense'];
    final List<String> categories = ['All', 'Food', 'Transport', 'Shopping'];
    final List<String> bankAccounts = ['All', 'Main', 'Savings', 'Credit Card'];

    // Controllers for Limit field
    final TextEditingController _limitController = TextEditingController();

    // To adjust the modal height, change the `height` of the Container below (or make it dynamic based on content).
    // Here are examples for: 
    // 1. Fixed height: set a specific fraction of screen height (e.g., 0.6 as before, or 0.8 for 80%).
    // 2. Dynamic height: let modal size itself to content, up to a max height.

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          // Reduced sizes by 10% (0.4 -> 0.3, 0.6 -> 0.5, 0.8 -> 0.7)
          minChildSize: 0.3, // Minimum height as fraction of screen
          initialChildSize: 0.5, // Initial height as fraction of screen
          maxChildSize: 0.7, // Maximum height as fraction of screen
          expand: false,
          builder: (context, scrollController) {
            Future<void> _pickDate(BuildContext ctx, bool isFrom) async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: ctx,
                initialDate: isFrom
                    ? (_dateFrom ?? now)
                    : (_dateTo ?? now),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                // ignore: invalid_use_of_visible_for_testing_member
                (context as Element).markNeedsBuild();
                // update state as needed (you can refactor to hold a local state if necessary)
                if (isFrom) {
                  _dateFrom = picked;
                  if (_dateTo != null && _dateTo!.isBefore(_dateFrom!)) {
                    _dateTo = _dateFrom;
                  }
                } else {
                  _dateTo = picked;
                  if (_dateFrom != null && _dateTo!.isBefore(_dateFrom!)) {
                    _dateFrom = _dateTo;
                  }
                }
              }
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: SingleChildScrollView(
                controller: scrollController,
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          margin: const EdgeInsets.only(top: 12, bottom: 20),
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      // Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: iconColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.search,
                                color: iconColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Filter Summary",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF052224),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.close, color: Color(0xFF052224)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date From, Date To, Limit (in a row)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(context, true),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'From',
                                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    controller: TextEditingController(
                                      text: _dateFrom != null
                                          ? "${_dateFrom!.year.toString().padLeft(4, '0')}-${_dateFrom!.month.toString().padLeft(2, '0')}-${_dateFrom!.day.toString().padLeft(2, '0')}"
                                          : "",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => _pickDate(context, false),
                                child: AbsorbPointer(
                                  child: TextFormField(
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      labelText: 'To',
                                      labelStyle: const TextStyle(fontFamily: 'Poppins'),
                                      suffixIcon: const Icon(Icons.calendar_today, size: 18),
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    controller: TextEditingController(
                                      text: _dateTo != null
                                          ? "${_dateTo!.year.toString().padLeft(4, '0')}-${_dateTo!.month.toString().padLeft(2, '0')}-${_dateTo!.day.toString().padLeft(2, '0')}"
                                          : "",
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                style: const TextStyle(fontFamily: 'Poppins'),
                                controller: _limitController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'Limit',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                onChanged: (val) {
                                  // Not stateful here -- if you want the limit stored, refactor this function or use a callback.
                                  _limit = int.tryParse(val);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Transaction Type, Category
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedTransactionType ?? transactionTypes[0],
                                items: transactionTypes
                                    .map((type) => DropdownMenuItem(
                                          value: type,
                                          child: Text(type, style: const TextStyle(fontFamily: 'Poppins')),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  _selectedTransactionType = val;
                                  (context as Element).markNeedsBuild();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Transaction Type',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _selectedCategory ?? categories[0],
                                items: categories
                                    .map((cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat, style: const TextStyle(fontFamily: 'Poppins')),
                                        ))
                                    .toList(),
                                onChanged: (val) {
                                  _selectedCategory = val;
                                  (context as Element).markNeedsBuild();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Bank Accounts
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: DropdownButtonFormField<String>(
                          value: _selectedBankAccount ?? bankAccounts[0],
                          items: bankAccounts
                              .map((acc) => DropdownMenuItem(
                                    value: acc,
                                    child: Text(acc, style: const TextStyle(fontFamily: 'Poppins')),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            _selectedBankAccount = val;
                            (context as Element).markNeedsBuild();
                          },
                          decoration: InputDecoration(
                            labelText: 'Bank Accounts',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Search Button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            label: const Text(
                              'Search',
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00D09E),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF052224),
          ),
        ),
      ],
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
            return _FullFormModalContent(scrollController: scrollController);
          },
        );
      },
    );
  }
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
                                color: const Color(0xFF00D09E).withOpacity(0.3),
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
                        backgroundColor: const Color(0xFF00D09E),
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
              color: const Color(0xFF00D09E).withOpacity(0.3),
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
