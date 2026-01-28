import 'package:flutter/material.dart';
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
                  await NavigationHelper.navigateToWithResult<bool>(
                    context,
                    'add-loan',
                  );
                  if (mounted) _loadLoans();
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

