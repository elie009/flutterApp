import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../config/app_config.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as app_error;
import '../../widgets/loading_indicator.dart';
import '../../utils/theme.dart';
import '../../widgets/triangle_painter.dart';
class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
  List<Loan> _loans = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLoans();
  }

  Future<void> _loadLoans() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final loans = await DataService().getUserLoans(page: 1, limit: 50);
      if (mounted) {
        setState(() {
          _loans = loans;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  static const _iconColors = [
    Color(0xFF6CB5FD),
    Color(0xFF3299FF),
    AppTheme.primaryColor,
  ];

  Color _loanIconColor(int index) =>
      _iconColors[index % _iconColors.length];

  String _getMonthLabel(DateTime date) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[date.month - 1];
  }

  String _formatLoanDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  static const _lightGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header: light green with subtle pattern
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                right: 16,
                bottom: 20,
              ),
              decoration: const BoxDecoration(
                color: _lightGreen,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => NavigationHelper.navigateBack(context),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        
                        child: const Text(
                          'Loans',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 22,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: _headerDark,
                              size: 22,
                            ),
                          ),
                          Positioned(
                            top: 6,
                            right: 6,
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Colors.white, width: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // White content area
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: _isLoading
                    ? const LoadingIndicator(message: 'Loading loans...')
                    : _errorMessage != null
                        ? app_error.ErrorDisplay(
                            message: _errorMessage!,
                            onRetry: _loadLoans,
                          )
                        : _loans.isEmpty
                            ? EmptyState(
                                icon: Icons.account_balance_wallet_outlined,
                                title: 'No loans yet',
                                message:
                                    'Your loans will appear here. Tap + to apply for a loan.',
                                actionLabel: 'Refresh',
                                onAction: _loadLoans,
                              )
                            : RefreshIndicator(
                                onRefresh: _loadLoans,
                                color: _lightGreen,
                                child: ListView.builder(
                                  padding: const EdgeInsets.only(
                                    left: 24,
                                    right: 24,
                                    top: 24,
                                    bottom: 100,
                                  ),
                                  itemCount: _loans.length,
                                  itemBuilder: (context, index) {
                                    final loan = _loans[index];
                                    final displayDate = loan.nextDueDate ??
                                        loan.appliedAt;
                                    final monthLabel =
                                        _getMonthLabel(displayDate);
                                    final showMonthHeader = index == 0 ||
                                        _getMonthLabel(_loans[index - 1]
                                                .nextDueDate ??
                                            _loans[index - 1].appliedAt) !=
                                            monthLabel;
                                    return Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (showMonthHeader) ...[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 8),
                                            child: Text(
                                              monthLabel,
                                              style: const TextStyle(
                                                color: _headerDark,
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 12),
                                          child: _LoanCard(
                                            loan: loan,
                                            displayDate: displayDate,
                                            iconColor: _loanIconColor(index),
                                            formatDate: _formatLoanDate,
                                            onTap: () =>
                                                NavigationHelper.navigateTo(
                                              context,
                                              'loan-detail',
                                              params: {'id': loan.id},
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: GestureDetector(
          onTap: () async {
            final added = await showModalBottomSheet<bool>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (ctx) => _AddLoanModalContent(
                onSaved: () => Navigator.of(ctx).pop(true),
                onCancel: () => Navigator.of(ctx).pop(false),
              ),
            );
            if (mounted && added == true) _loadLoans();
          },
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _lightGreen,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _lightGreen.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

/// Card matching design: circular light blue icon, name, date, amount on right.
class _LoanCard extends StatelessWidget {
  const _LoanCard({
    required this.loan,
    required this.displayDate,
    required this.iconColor,
    required this.formatDate,
    required this.onTap,
  });

  final Loan loan;
  final DateTime displayDate;
  final Color iconColor;
  final String Function(DateTime) formatDate;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final purpose = loan.purpose?.isNotEmpty == true
        ? loan.purpose!
        : 'Loan';
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: Icon(
                  Icons.description_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purpose,
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatDate(displayDate),
                    style: const TextStyle(
                      color: Color(0xFF0068FF),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '-${Formatters.formatCurrency(loan.monthlyPayment, symbol: AppConfig.currencySymbol)}',
              style: const TextStyle(
                color: Color(0xFF4A5FBF),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Add Loan modal: form shown when FAB is tapped
class _AddLoanModalContent extends StatefulWidget {
  final VoidCallback onSaved;
  final VoidCallback onCancel;

  const _AddLoanModalContent({
    required this.onSaved,
    required this.onCancel,
  });

  @override
  State<_AddLoanModalContent> createState() => _AddLoanModalContentState();
}

class _AddLoanModalContentState extends State<_AddLoanModalContent> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Personal Loan';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;
  String? _errorMessage;

  static const _loanCategories = [
    'Personal Loan',
    'Home Loan',
    'Car Loan',
    'Student Loan',
    'Business Loan',
    'Credit Card',
    'Other',
  ];

  static String _categoryToLoanType(String category) {
    switch (category) {
      case 'Home Loan': return 'MORTGAGE';
      case 'Car Loan': return 'AUTO';
      case 'Student Loan': return 'STUDENT';
      case 'Business Loan': return 'BUSINESS';
      default: return 'PERSONAL';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveLoan() async {
    _errorMessage = null;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final amount = double.tryParse(_amountController.text.trim());
      if (amount == null || amount <= 0) {
        setState(() {
          _errorMessage = 'Please enter a valid amount';
          _isSaving = false;
        });
        return;
      }

      await DataService().applyForLoan(
        principal: amount,
        purpose: _titleController.text.trim(),
        termMonths: 12,
        loanType: _categoryToLoanType(_selectedCategory),
        additionalInfo: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Loan application submitted.'),
            backgroundColor: AppTheme.primaryColor,
          ),
        );
        widget.onSaved();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Text(
                'Add Loan',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date', style: _labelStyle),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _isSaving ? null : _selectDate,
                        child: Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            DateFormat('MMMM d, yyyy').format(_selectedDate),
                            style: const TextStyle(
                              color: Color(0xFF093030),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Category', style: _labelStyle),
                      const SizedBox(height: 8),
                      Container(
                        height: 48,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDFF7E2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCategory,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF093030)),
                            style: const TextStyle(
                              color: Color(0xFF093030),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                            ),
                            onChanged: _isSaving ? null : (v) {
                              if (v != null) setState(() => _selectedCategory = v);
                            },
                            items: _loanCategories.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text('Amount', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        readOnly: _isSaving,
                        decoration: _inputDecoration(hint: '\$0.00'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter an amount';
                          if (double.tryParse(v.trim()) == null || double.parse(v.trim()) <= 0) {
                            return 'Enter a valid amount';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Loan Title', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _titleController,
                        readOnly: _isSaving,
                        decoration: _inputDecoration(hint: 'Loan Title'),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Please enter a loan title';
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      const Text('Description', style: _labelStyle),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        readOnly: _isSaving,
                        decoration: _inputDecoration(hint: 'Enter loan description'),
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red, fontSize: 13),
                        ),
                      ],
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _isSaving ? null : widget.onCancel,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF093030),
                                side: const BorderSide(color: AppTheme.primaryColor),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: const Text('Cancel'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveLoan,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: const Color(0xFF093030),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF093030)),
                                    )
                                  : const Text('Save'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

const _labelStyle = TextStyle(
  color: Color(0xFF093030),
  fontSize: 15,
  fontFamily: 'Poppins',
  fontWeight: FontWeight.w500,
);

InputDecoration _inputDecoration({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF093030), fontSize: 15, fontFamily: 'Poppins'),
    filled: true,
    fillColor: const Color(0xFFDFF7E2),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
  );
}

