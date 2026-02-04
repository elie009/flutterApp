import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/data_service.dart';
import '../../models/transaction.dart';
import '../../models/bank_account.dart';
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

  // Filter state for API (GET api/BankAccounts/transactions)
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;
  int _filterLimit = 50;
  String? _filterBankAccountId;
  String? _filterAccountType;
  List<BankAccount> _bankAccounts = [];

  @override
  void initState() {
    super.initState();
    // Default to current month
    final now = DateTime.now();
    _filterDateFrom = DateTime(now.year, now.month, 1);
    _filterDateTo = DateTime(now.year, now.month + 1, 0); // last day of current month
    _loadBankAccounts();
    _loadData();
  }

  Future<void> _loadBankAccounts() async {
    try {
      final accounts = await _dataService.getBankAccounts(isActive: true);
      if (mounted) setState(() => _bankAccounts = accounts);
    } catch (_) {}
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _dataService.getDashboardSummary();

      final startDateStr = _filterDateFrom != null
          ? "${_filterDateFrom!.year.toString().padLeft(4, '0')}-${_filterDateFrom!.month.toString().padLeft(2, '0')}-${_filterDateFrom!.day.toString().padLeft(2, '0')}"
          : null;
      final endDateStr = _filterDateTo != null
          ? "${_filterDateTo!.year.toString().padLeft(4, '0')}-${_filterDateTo!.month.toString().padLeft(2, '0')}-${_filterDateTo!.day.toString().padLeft(2, '0')}"
          : null;

      final transactions = await _dataService.getTransactions(
        page: 1,
        limit: _filterLimit,
        bankAccountId: _filterBankAccountId,
        accountType: _filterAccountType,
        startDate: startDateStr,
        endDate: endDateStr,
      );

      double income = 0.0;
      double expense = 0.0;
      for (var transaction in transactions) {
        if (transaction.transactionType.toLowerCase() == 'credit') {
          income += transaction.amount;
        } else if (transaction.transactionType.toLowerCase() == 'debit') {
          expense += transaction.amount;
        }
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

  static const _primaryGreen = Color(0xFFb3ee9a);
  static const _headerDark = Color(0xFF093030);
  static const _debitRed = Color(0xFFD32F2F);
  static const _debitBg = Color(0xFFFFEBE7);
  static const _creditBg = Color(0xFFE8F5E9);
  static const _textGray = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 2),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header: light green with subtle pattern
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 24,
                right: 24,
                bottom: 20,
              ),
              decoration: const BoxDecoration(color: _primaryGreen),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Transactions',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: _primaryGreen, width: 1.5),
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: _headerDark,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Three summary cards
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showSummaryModal(context, _headerDark),
                      child: _buildSummaryCard(
                        label: 'Total Balance',
                        amount: _totalBalance,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showSummaryModal(context, _primaryGreen),
                      child: _buildSummaryCard(
                        label: 'Total Income',
                        amount: _totalIncome,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _showSummaryModal(context, _debitRed),
                      child: _buildSummaryCard(
                        label: 'Total Expense',
                        amount: _totalExpense,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Transaction list
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    )
                  : _buildTransactionsList(),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () => _showAddTransactionModal(context),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSummaryCard({required String label, required double amount}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: _primaryGreen, size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _textGray,
                    fontSize: 11,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _formatCurrency(amount),
            style: const TextStyle(
              color: Color(0xFF052224),
              fontSize: 16,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
      color: _primaryGreen,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
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
    final isCredit = transaction.isIncome;
    final amount = transaction.amount;
    final dateStr = DateFormat('MMM d, yyyy').format(transaction.transactionDate);
    final typeStr = isCredit ? 'Credit' : 'Debit';
    final categoryStr = transaction.category ?? 'Uncategorized';
    final accentColor = isCredit ? _primaryGreen : _debitRed;
    final bgColor = isCredit ? _creditBg : _debitBg;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: name + arrow, amount
          Row(
            children: [
              Icon(
                isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                size: 18,
                color: accentColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
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
              ),
              Text(
                '${isCredit ? '' : '-'}${_formatCurrency(amount.abs())}',
                style: TextStyle(
                  color: isCredit ? _primaryGreen : const Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Row 2: date
          Text(
            dateStr,
            style: const TextStyle(
              color: _textGray,
              fontSize: 12,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          // Two columns: Category / Type (left), Account / Split (right)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailLabel('Category'),
                    Text(
                      categoryStr,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailLabel('Type'),
                    Row(
                      children: [
                        Icon(
                          isCredit ? Icons.arrow_upward : Icons.arrow_downward,
                          size: 14,
                          color: accentColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          typeStr,
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 13,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _detailLabel('Account'),
                    const Text(
                      '—',
                      style: TextStyle(
                        color: Color(0xFF052224),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _detailLabel('Split'),
                    const Text(
                      '1',
                      style: TextStyle(
                        color: Color(0xFF052224),
                        fontSize: 13,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: const TextStyle(
          color: _textGray,
          fontSize: 11,
          fontFamily: 'Poppins',
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
  String _formatCurrency(double amount) {
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '${AppConfig.currencySymbol}${formatter.format(amount)}';
  }

  void _showSummaryModal(BuildContext context, Color iconColor) {
    DateTime? dateFrom = _filterDateFrom;
    DateTime? dateTo = _filterDateTo;
    String? bankAccountId = _filterBankAccountId;
    String? accountType = _filterAccountType;
    final limitController = TextEditingController(text: _filterLimit.toString());

    // Account type options: display label -> API value (null = All)
    const accountTypeOptions = [
      ('All', null),
      ('Checking', 'checking'),
      ('Savings', 'savings'),
      ('Credit Card', 'credit_card'),
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext modalContext) {
        return DraggableScrollableSheet(
          minChildSize: 0.3,
          initialChildSize: 0.5,
          maxChildSize: 0.7,
          expand: false,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                Future<void> pickDate(bool isFrom) async {
                  final now = DateTime.now();
                  final picked = await showDatePicker(
                    context: modalContext,
                    initialDate: isFrom ? (dateFrom ?? now) : (dateTo ?? now),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    if (isFrom) {
                      dateFrom = picked;
                      if (dateTo != null && dateTo!.isBefore(dateFrom!)) dateTo = dateFrom;
                    } else {
                      dateTo = picked;
                      if (dateFrom != null && dateTo!.isBefore(dateFrom!)) dateFrom = dateTo;
                    }
                    setModalState(() {});
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
                                  child: Icon(Icons.search, color: iconColor, size: 24),
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
                                  onPressed: () => Navigator.of(modalContext).pop(),
                                  icon: const Icon(Icons.close, color: Color(0xFF052224)),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => pickDate(true),
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
                                          text: dateFrom != null
                                              ? "${dateFrom!.year.toString().padLeft(4, '0')}-${dateFrom!.month.toString().padLeft(2, '0')}-${dateFrom!.day.toString().padLeft(2, '0')}"
                                              : "",
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => pickDate(false),
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
                                          text: dateTo != null
                                              ? "${dateTo!.year.toString().padLeft(4, '0')}-${dateTo!.month.toString().padLeft(2, '0')}-${dateTo!.day.toString().padLeft(2, '0')}"
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
                                    controller: limitController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Limit',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String?>(
                                    value: accountType,
                                    items: accountTypeOptions
                                        .map((e) => DropdownMenuItem<String?>(
                                              value: e.$2,
                                              child: Text(e.$1, style: const TextStyle(fontFamily: 'Poppins')),
                                            ))
                                        .toList(),
                                    onChanged: (val) {
                                      accountType = val;
                                      setModalState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Account Type',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: DropdownButtonFormField<String?>(
                                    value: bankAccountId,
                                    items: [
                                      const DropdownMenuItem<String?>(value: null, child: Text('All', style: TextStyle(fontFamily: 'Poppins'))),
                                      ..._bankAccounts.map((a) => DropdownMenuItem<String?>(
                                            value: a.id,
                                            child: Text(a.accountName, style: const TextStyle(fontFamily: 'Poppins'), overflow: TextOverflow.ellipsis),
                                          )),
                                    ],
                                    onChanged: (val) {
                                      bankAccountId = val;
                                      setModalState(() {});
                                    },
                                    decoration: InputDecoration(
                                      labelText: 'Bank Account',
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.search, color: Colors.white),
                                onPressed: () {
                                  final limit = int.tryParse(limitController.text) ?? _filterLimit;
                                  setState(() {
                                    _filterDateFrom = dateFrom;
                                    _filterDateTo = dateTo;
                                    _filterLimit = limit.clamp(1, 500);
                                    _filterBankAccountId = bankAccountId;
                                    _filterAccountType = accountType;
                                  });
                                  Navigator.of(modalContext).pop();
                                  _loadData();
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
                                  backgroundColor: const Color(0xFFb3ee9a),
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
