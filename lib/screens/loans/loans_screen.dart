import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/loan.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_widget.dart' as app_error;
import '../../widgets/loading_indicator.dart';
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
    Color(0xFF00D09E),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
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

            // Back button with icon
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () => NavigationHelper.navigateBack(context),
                child: Container(
                  width: 32,
                  height: 32,
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back,
                      color: Color(0xFFF1FFF3),
                      size: 19,
                    ),
                  ),
                ),
              ),
            ),

            // Title "Loans"
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Center(
                child: Text(
                  'Loans',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Loans',
                    fontWeight: FontWeight.bold,
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

            // White bottom section with dynamic content
            Positioned(
              left: 0,
              right: 0,
              top: 176,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
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
                                  color: const Color(0xFF00D09E),
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
                                      final monthLabel = _getMonthLabel(
                                          displayDate);
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
                                                  color: Color(0xFF093030),
                                                  fontSize: 15,
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 16),
                                            child: GestureDetector(
                                              onTap: () =>
                                                  NavigationHelper.navigateTo(
                                                context,
                                                'loan-detail',
                                                params: {'id': loan.id},
                                              ),
                                              behavior:
                                                  HitTestBehavior.opaque,
                                              child: Row(
                                                children: [
                                                  Container(
                                                    width: 57,
                                                    height: 53,
                                                    decoration: BoxDecoration(
                                                      color: _loanIconColor(
                                                          index),
                                                      borderRadius:
                                                          BorderRadius
                                                              .circular(22),
                                                    ),
                                                    child: const Center(
                                                      child: Icon(
                                                        Icons
                                                            .account_balance_wallet_outlined,
                                                        color: Colors.white,
                                                        size: 26,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          loan.purpose
                                                                  ?.isNotEmpty ==
                                                                  true
                                                              ? loan.purpose!
                                                              : 'Loan',
                                                          style: const TextStyle(
                                                            color: Color(
                                                                0xFF052224),
                                                            fontSize: 15,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          _formatLoanDate(
                                                              displayDate),
                                                          style: const TextStyle(
                                                            color: Color(
                                                                0xFF0068FF),
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Poppins',
                                                            fontWeight:
                                                                FontWeight
                                                                    .w600,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Text(
                                                    '-${Formatters.formatCurrency(loan.monthlyPayment, symbol: '\$')}',
                                                    style: const TextStyle(
                                                      color: Color(0xFF0068FF),
                                                      fontSize: 15,
                                                      fontFamily: 'Poppins',
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
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
            ),

            // Floating Add Loan button (bottom right)
            Positioned(
              right: 28,
              bottom: 16,
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
                  width: 65,
                  height: 65,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF00D09E), // green border
                      width: 2.5,
                    ),
                    borderRadius: BorderRadius.circular(12), // square with rounded corners
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x2900D09E),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.add,
                      color: const Color(0xFF00D09E),
                      size: 36,
                    ),
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
            backgroundColor: Color(0xFF00D09E),
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
                                side: const BorderSide(color: Color(0xFF00D09E)),
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
                                backgroundColor: const Color(0xFF00D09E),
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

