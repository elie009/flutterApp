import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../models/savings_account.dart';
import '../../services/data_service.dart';
import '../../utils/formatters.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<Map<String, dynamic>> _monthlyData = [];
  List<SavingsAccount> _savingsAccounts = [];
  bool _savingsLoading = true;
  String? _savingsError;
  int _selectedYear = DateTime.now().year;

  /// Years for dropdown: current year and 4 years below (5 options).
  static List<int> get _yearOptions {
    final current = DateTime.now().year;
    return List.generate(5, (i) => current - i);
  }

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadSavings();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      List<Map<String, dynamic>> monthlyData = [];
      try {
        final cashFlow = await DataService().getMonthlyCashFlow(year: _selectedYear);
        final list = cashFlow['monthlyData'] as List<dynamic>? ?? [];
        monthlyData = list
            .map((e) => Map<String, dynamic>.from(e as Map<dynamic, dynamic>))
            .toList();
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceFirst('Exception: ', '');
          });
        }
      }

      if (!mounted) return;
      setState(() {
        _monthlyData = monthlyData;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _monthlyData = [];
        _isLoading = false;
      });
    } finally {
      if (mounted && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _loadSavings() async {
    if (!mounted) return;
    setState(() {
      _savingsLoading = true;
      _savingsError = null;
    });
    try {
      final accounts = await DataService().getSavingsAccounts();
      if (!mounted) return;
      setState(() {
        _savingsAccounts = accounts;
        _savingsLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _savingsError = e.toString().replaceFirst('Exception: ', '');
        _savingsAccounts = [];
        _savingsLoading = false;
      });
    } finally {
      if (mounted && _savingsLoading) {
        setState(() => _savingsLoading = false);
      }
    }
  }

  double get _totalIncome {
    double sum = 0;
    for (final m in _monthlyData) {
      sum += (m['incoming'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  double get _totalExpense {
    double sum = 0;
    for (final m in _monthlyData) {
      sum += (m['outgoing'] as num?)?.toDouble() ?? 0;
    }
    return sum;
  }

  /// Build chart data for 12 months (Jan–Dec). Uses month 1–12 from API or fills gaps.
  List<Map<String, dynamic>> get _chartMonths {
    const abbr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final byMonth = <int, Map<String, dynamic>>{};
    for (final m in _monthlyData) {
      final month = (m['month'] as num?)?.toInt() ?? 0;
      if (month >= 1 && month <= 12) {
        byMonth[month] = {
          'label': m['monthAbbreviation'] as String? ?? abbr[month - 1],
          'incoming': (m['incoming'] as num?)?.toDouble() ?? 0.0,
          'outgoing': (m['outgoing'] as num?)?.toDouble() ?? 0.0,
        };
      }
    }
    return List.generate(12, (i) {
      final month = i + 1;
      final data = byMonth[month];
      return {
        'label': data?['label'] ?? abbr[i],
        'incoming': (data?['incoming'] as double?) ?? 0.0,
        'outgoing': (data?['outgoing'] as double?) ?? 0.0,
      };
    });
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () {
        context.push('/notifications');
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 15.0), // Add space on the right side
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Center(
                child: Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF333333),
                  size: 24,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildYearDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: Row(
        children: [
          const Text(
            'Year: ',
            style: TextStyle(
              color: Color(0xFF093030),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w500,
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _selectedYear,
              isExpanded: false,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF093030)),
              dropdownColor: Colors.white,
              style: const TextStyle(
                color: Color(0xFF093030),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
              items: _yearOptions.map((int year) {
                return DropdownMenuItem<int>(
                  value: year,
                  child: Text('$year'),
                );
              }).toList(),
              onChanged: (int? year) {
                if (year != null && year != _selectedYear) {
                  setState(() => _selectedYear = year);
                  _loadData();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: 430,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
        ),
        child: Stack(
          children: [
            // Geometric background in header area
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 115,
              child: ClipRRect(
              
             
              ),
            ),
            // Header content: back (left), title (center), notification (right) — like Loans screen
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 115,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Back button (same width as notification so title stays centered)
                          SizedBox(
                            width: 44,
                            height: 44,
                            child: GestureDetector(
                              onTap: () => NavigationHelper.navigateBack(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.4),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.chevron_left,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'Analysis',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF093030), // dark green
                                fontSize: 22,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                          _buildNotificationButton(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // White content section - fills space above bottom nav; scroll only "My targets" items
            Positioned(
              left: 0,
              top: 115,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(37, 24, 37, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Year dropdown
                    _buildYearDropdown(),
                    const SizedBox(height: 16),
                    // Income and Expenses Bar Chart (from API)
                    SizedBox(
                      height: 200,
                      child: _buildCashFlowChart(),
                    ),
                    const SizedBox(height: 24),
                    // Summary Cards
                    SizedBox(
                      height: 80,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1FFF3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Color(0xFF093030),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.formatCurrency(_totalIncome, symbol: AppConfig.currencySymbol),
                                    style: const TextStyle(
                                      color: AppTheme.primaryColor,
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1FFF3),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Expenses',
                                    style: TextStyle(
                                      color: Color(0xFF093030),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    Formatters.formatCurrency(_totalExpense, symbol: AppConfig.currencySymbol),
                                    style: const TextStyle(
                                      color: Color(0xFF0068FF),
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // My targets section - title fixed
                    const Text(
                      'My targets',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 18,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Target items from savings API - scroll only this list
                    Expanded(
                      child: _buildMyTargetsContent(),
                    ),
                  ],
                ),
              ),
            ),

          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 1),
    );
  }

  static const int _numMonths = 12;
  // Design: Expense (dark blue), Net (medium blue), Income (light blue)
  static const Color _expenseDarkBlue = Color(0xFF1E3A5F);
  static const Color _netBlue = Color(0xFF5B9BD5);
  static const Color _incomeLightBlue = Color(0xFF87CEEB);

  Widget _legendDot(Color color) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  static String _formatAxisK(double value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(0)}K';
    return value.toStringAsFixed(0);
  }

  Widget _buildCashFlowChart() {
    if (_errorMessage != null && !_isLoading) {
      return Container(
        height: 120,
        decoration: BoxDecoration(
          color: const Color(0xFFF1FFF3),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    if (_isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: const Color(0xFFF1FFF3),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
            ),
          ),
        ),
      );
    }
    final months = _chartMonths;
    double maxVal = 1.0;
    for (final m in months) {
      final inc = (m['incoming'] as double?) ?? 0.0;
      final out = (m['outgoing'] as double?) ?? 0.0;
      if (inc > maxVal) maxVal = inc;
      if (out > maxVal) maxVal = out;
    }
    if (maxVal <= 0) maxVal = 1.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final chartWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0
            ? constraints.maxWidth
            : 358.0;
        const paddingH = 16.0;
        const yAxisWidth = 36.0;
        const gapBetweenBars = 4.0;
        final contentWidth = chartWidth - paddingH * 2 - yAxisWidth - 4;
        final barGroupWidth = contentWidth / _numMonths;
        final barWidth = ((barGroupWidth - gapBetweenBars) / 2).clamp(4.0, 24.0);
        const chartAreaHeight = 100.0;

        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF1FFF3),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _legendDot(_expenseDarkBlue),
                    const SizedBox(width: 6),
                    const Text('Expense', style: TextStyle(fontSize: 11, color: Color(0xFF093030), fontFamily: 'Poppins')),
                    const SizedBox(width: 10),
                    _legendDot(_netBlue),
                    const SizedBox(width: 6),
                    const Text('Net', style: TextStyle(fontSize: 11, color: Color(0xFF093030), fontFamily: 'Poppins')),
                    const SizedBox(width: 10),
                    _legendDot(_incomeLightBlue),
                    const SizedBox(width: 6),
                    const Text('Income', style: TextStyle(fontSize: 11, color: Color(0xFF093030), fontFamily: 'Poppins')),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: SizedBox(
                  height: chartAreaHeight + 22,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Y-axis labels and grid
                      SizedBox(
                        width: yAxisWidth,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(_formatAxisK(maxVal), style: const TextStyle(fontSize: 9, color: Color(0xFF093030), fontFamily: 'Poppins')),
                            Text(_formatAxisK(maxVal * 0.75), style: const TextStyle(fontSize: 9, color: Color(0xFF093030), fontFamily: 'Poppins')),
                            Text(_formatAxisK(maxVal * 0.5), style: const TextStyle(fontSize: 9, color: Color(0xFF093030), fontFamily: 'Poppins')),
                            Text(_formatAxisK(maxVal * 0.25), style: const TextStyle(fontSize: 9, color: Color(0xFF093030), fontFamily: 'Poppins')),
                            Text('0K', style: const TextStyle(fontSize: 9, color: Color(0xFF093030), fontFamily: 'Poppins')),
                          ],
                        ),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: SizedBox(
                          height: chartAreaHeight + 22,
                          child: Stack(
                          children: [
                            // Dotted grid lines at 25%, 50%, 75% of chart height
                            ...List.generate(3, (i) {
                              final frac = (i + 1) / 4;
                              return Positioned(
                                left: 0,
                                right: 0,
                                bottom: chartAreaHeight * (1 - frac) + 22,
                                height: 1,
                                child: CustomPaint(
                                  painter: _DottedLinePainter(color: Colors.grey.shade400),
                                ),
                              );
                            }),
                            // Bars
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              height: chartAreaHeight + 22,
                              child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: months.asMap().entries.map((entry) {
                              final m = entry.value;
                              final label = m['label'] as String? ?? '';
                              final inc = (m['incoming'] as double?) ?? 0.0;
                              final out = (m['outgoing'] as double?) ?? 0.0;
                              final net = (inc - out).clamp(0.0, double.infinity);
                              final incH = maxVal > 0 ? (inc / maxVal) * chartAreaHeight : 0.0;
                              final outH = maxVal > 0 ? (out / maxVal) * chartAreaHeight : 0.0;
                              final netH = maxVal > 0 ? (net / maxVal) * chartAreaHeight : 0.0;
                              return Expanded(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        _buildStackedBar(outH, netH, barWidth),
                                        SizedBox(width: gapBetweenBars),
                                        _buildSingleBar(incH, barWidth, _incomeLightBlue),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      label,
                                      style: const TextStyle(
                                        color: Color(0xFF093030),
                                        fontSize: 9,
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.w400,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStackedBar(double expenseHeight, double netHeight, double width) {
    final total = expenseHeight + netHeight;
    if (total <= 0) {
      return SizedBox(width: width, height: 0);
    }
    return SizedBox(
      width: width,
      height: total,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (netHeight > 0)
            Container(
              height: netHeight,
              width: width,
              decoration: const BoxDecoration(
                color: _netBlue,
                borderRadius: BorderRadius.vertical(top: Radius.circular(3)),
              ),
            ),
          if (expenseHeight > 0)
            Container(
              height: expenseHeight,
              width: width,
              decoration: BoxDecoration(
                color: _expenseDarkBlue,
                borderRadius: BorderRadius.vertical(
                  bottom: const Radius.circular(3),
                  top: netHeight > 0 ? Radius.zero : const Radius.circular(3),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSingleBar(double height, double width, Color color) {
    final safeHeight = height.clamp(0.0, 200.0);
    return Container(
      width: width,
      height: safeHeight,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildMyTargetsContent() {
    if (_savingsLoading) {
      return const Center(
        child: SizedBox(
          width: 32,
          height: 32,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      );
    }
    if (_savingsError != null) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _savingsError!,
              style: const TextStyle(color: Colors.red, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loadSavings,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_savingsAccounts.isEmpty) {
      return Center(
        child: Text(
          'No savings goals yet',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
            fontFamily: 'Poppins',
          ),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 48),
      children: [
        for (int i = 0; i < _savingsAccounts.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _buildTargetItem(
            _savingsAccounts[i].accountName,
            (_savingsAccounts[i].progressPercentage / 100).clamp(0.0, 1.0),
            Formatters.formatCurrency(_savingsAccounts[i].targetAmount, symbol: AppConfig.currencySymbol),
          ),
        ],
      ],
    );
  }

  Widget _buildTargetItem(String title, double progress, String amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1FFF3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  amount,
                  style: const TextStyle(
                    color: Color(0xFF0068FF),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0F7E0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
              strokeWidth: 6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DottedLinePainter extends CustomPainter {
  final Color color;

  _DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..strokeWidth = 1;
    const dashWidth = 3.0;
    const gap = 3.0;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(Offset(x, size.height / 2), Offset((x + dashWidth).clamp(0.0, size.width), size.height / 2), paint);
      x += dashWidth + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}