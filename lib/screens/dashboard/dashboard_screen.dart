import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import 'dart:math' as math;

// Custom painter for house roof
class _HousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFF1FFF3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.70;

    final path = Path()
      ..moveTo(size.width / 2, 0)
      ..lineTo(0, size.height)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom painter for circular progress arc
class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _CircularProgressPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    final startAngle = -90 * math.pi / 180; // Start from top
    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _CircularProgressPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data for savings goal progress
  double _savingsProgress = 0.0;
  bool _isLoadingProgress = true;

  @override
  void initState() {
    super.initState();
    _loadSavingsProgress();
  }

  // Endpoint-ready function to fetch savings progress
  Future<void> _loadSavingsProgress() async {
    setState(() {
      _isLoadingProgress = true;
    });

    try {
      // TODO: Replace with actual API call
      // final response = await http.get(Uri.parse('/api/user/savings-progress'));
      // final data = json.decode(response.body);
      // _savingsProgress = data['progress'] / 100.0; // Convert percentage to 0-1 range

      // Mock API call delay
      await Future.delayed(const Duration(seconds: 1));

      // Mock data - 75% progress
      setState(() {
        _savingsProgress = 0.75;
        _isLoadingProgress = false;
      });
    } catch (e) {
      // Handle error - fallback to 0 progress
      setState(() {
        _savingsProgress = 0.0;
        _isLoadingProgress = false;
      });
      debugPrint('Error loading savings progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White bottom section
            Positioned(
              left: 0,
              top: 292,
              right: 0,
              bottom: 0, // Will be above bottom navigation bar
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                ),
              ),
            ),

            // Green summary card
            Positioned(
              left: 37,
              top: 325,
              width: 357,
              height: 152,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  borderRadius: BorderRadius.circular(31),
                ),
              ),
            ),

            // Status bar
            Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 32,
              child: Stack(
                children: [
                  // Time
                  const Positioned(
                    left: 37,
                    top: 9,
                    child: Text(
                      '16:04',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Status icons
                  Positioned(
                    left: 338,
                    top: 9,
                    child: Container(
                      width: 13,
                      height: 11,
                      color: Colors.white,
                    ),
                  ),
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
                  Positioned(
                    left: 377,
                    top: 12,
                    child: Container(
                      width: 12,
                      height: 7,
                      color: Colors.white,
                    ),
                  ),
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
            ),

            // Back button (top left)
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () {
                  // Navigate back or to previous screen
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFF1FFF3),
                  size: 19,
                ),
              ),
            ),

            // Welcome message
            const Positioned(
              left: 38,
              top: 60,
              child: SizedBox(
                width: 278,
                child: Text(
                  'Hi, Welcome Back',
                  style: TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 38,
              top: 86,
              child: SizedBox(
                width: 169,
                child: Text(
                  'Good Morning',
                  style: TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 14,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Revenue and expense labels in card
            const Positioned(
              left: 240,
              top: 350,
              child: Text(
                'Revenue Last Week',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 240,
              top: 412,
              child: Text(
                'Food Last Week',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 240,
              top: 370,
              child: Text(
                '\4.000.00',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Positioned(
              left: 240,
              top: 432,
              child: Text(
                '-\100.00',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            // Balance display section
            const Positioned(
              left: 78,
              top: 136,
              child: Text(
                'Total Balance',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 60,
              top: 152,
              child: Text(
                '\7,783.00',
                style: TextStyle(
                  color: Color(0xFFF1FFF3),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),

            const Positioned(
              left: 268,
              top: 137,
              child: Text(
                'Total Expense',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 249,
              top: 152,
              child: Text(
                '-\1.187.40',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Progress bar
            Positioned(
              left: 50,
              top: 200,
              child: Container(
                width: 330,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFF052224),
                  borderRadius: BorderRadius.circular(13.50),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 99, // 30% of 330
                      height: 27,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1FFF3),
                        borderRadius: BorderRadius.circular(13.50),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        '30%',
                        style: TextStyle(
                          color: Color(0xFF052224),
                          fontSize: 12,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress bar filled part
            Positioned(
              left: 119,
              top: 200,
              child: Container(
                width: 261,
                height: 27,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.circular(13.50),
                ),
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 19),
                child: const Text(
                  '\$20,000.00',
                  style: TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 13,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 81,
              top: 237,
              child: Text(
                '30% of your expenses, looks good.',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Vertical separator line
            Positioned(
              left: 216,
              top: 178,
              child: Container(
                width: 42,
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDFF7E2),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Income indicator (up arrow)
            Positioned(
              left: 60,
              top: 139,
              child: Transform.rotate(
                angle: -90 * 3.14159 / 180, // -90 degrees (pointing up)
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF052224),
                ),
              ),
            ),

            // Expense indicator (down arrow)
            Positioned(
              left: 249,
              top: 139,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees (pointing down)
                child: const Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: Color(0xFF052224),
                ),
              ),
            ),

            // Checkmark icon
            Positioned(
              left: 60,
              top: 243,
              child: Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF052224),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.check,
                  size: 8,
                  color: Color(0xFF052224),
                ),
              ),
            ),

            // Segmented control (Daily/Weekly/Monthly)
            Positioned(
              left: 36,
              top: 503,
              width: 358,
              height: 60,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Daily
                    Container(
                      width: 95,
                      height: 31,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Daily',
                        style: TextStyle(
                          color: Color(0xFF052224),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // Weekly
                    Container(
                      width: 95,
                      height: 31,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Weekly',
                        style: TextStyle(
                          color: Color(0xFF052224),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),

                    // Monthly (selected)
                    Container(
                      width: 95,
                      height: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D09E),
                        borderRadius: BorderRadius.circular(19),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        'Monthly',
                        style: TextStyle(
                          color: Color(0xFF052224),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Transaction items
            // Salary transaction
            const Positioned(
              left: 110,
              top: 591,
              child: Text(
                'Salary',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 321,
              top: 609,
              child: Text(
                '\$4.000,00',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 237,
              top: 613,
              child: Text(
                'Monthly',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const Positioned(
              left: 110,
              top: 616.35,
              child: Text(
                '18:27 - April 30',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Separator lines for salary
            Positioned(
              left: 214.46,
              top: 599.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 307.88,
              top: 599.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            // Salary icon
            Positioned(
              left: 37,
              top: 587,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF6DB6FE),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      Positioned(
                        left: 7.5,
                        top: 7.5,
                        child: Container(
                          width: 26,
                          height: 23.48,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFF1FFF3),
                              width: 1.77,
                            ),
                            borderRadius: BorderRadius.circular(0.44),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 10,
                        top: 10,
                        child: Container(
                          width: 20,
                          height: 18,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFF1FFF3),
                              width: 1.77,
                            ),
                            borderRadius: BorderRadius.circular(0.44),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 12.5,
                        top: 12.5,
                        child: Container(
                          width: 14,
                          height: 12.5,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFF1FFF3),
                              width: 1.77,
                            ),
                            borderRadius: BorderRadius.circular(0.44),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Groceries transaction
            const Positioned(
              left: 110,
              top: 666,
              child: Text(
                'Groceries',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 331,
              top: 684,
              child: Text(
                '-\$100,00',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 242,
              top: 688,
              child: Text(
                'Pantry',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const Positioned(
              left: 110,
              top: 691.35,
              child: Text(
                '17:00 - April 24',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Separator lines for groceries
            Positioned(
              left: 214.46,
              top: 674.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 307.88,
              top: 674.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            // Groceries icon (shopping bag)
            Positioned(
              left: 37,
              top: 664,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF3299FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      // Bag body
                      Positioned(
                        left: 20,
                        top: 13,
                        child: Container(
                          width: 16.76,
                          height: 20,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFFF1FFF3),
                              width: 1.70,
                            ),
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(2),
                              bottomRight: Radius.circular(2),
                            ),
                          ),
                        ),
                      ),
                      // Bag handles
                      Positioned(
                        left: 18,
                        top: 13,
                        child: Container(
                          width: 3,
                          height: 7,
                          decoration: BoxDecoration(
                            border: Border(
                              left: BorderSide(
                                color: const Color(0xFFF1FFF3),
                                width: 1.70,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 35,
                        top: 13,
                        child: Container(
                          width: 3,
                          height: 7,
                          decoration: BoxDecoration(
                            border: Border(
                              right: BorderSide(
                                color: const Color(0xFFF1FFF3),
                                width: 1.70,
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

            // Rent transaction
            const Positioned(
              left: 110,
              top: 747,
              child: Text(
                'Rent',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 328,
              top: 763,
              child: Text(
                '-\$674,40',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 248,
              top: 767,
              child: Text(
                'Rent',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 13,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),

            const Positioned(
              left: 110,
              top: 772.35,
              child: Text(
                '8:30 - April 15',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Separator lines for rent
            Positioned(
              left: 214.46,
              top: 755.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 307.88,
              top: 755.10,
              child: Transform.rotate(
                angle: 90 * 3.14159 / 180, // 90 degrees in radians
                child: Container(
                  width: 35.49,
                  height: 0,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF00D09E),
                      width: 1.01,
                    ),
                  ),
                ),
              ),
            ),

            // Rent icon (house/key)
            Positioned(
              left: 37,
              top: 744,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF0068FF),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Center(
                  child: Stack(
                    children: [
                      // House shape with roof
                      Positioned(
                        left: 14,
                        top: 14,
                        child: Container(
                          width: 28.37,
                          height: 24.82,
                          child: Stack(
                            children: [
                              // Roof (triangle)
                              Positioned(
                                left: 0,
                                top: 0,
                                child: CustomPaint(
                                  size: const Size(28.37, 12),
                                  painter: _HousePainter(),
                                ),
                              ),
                              // House body
                              Positioned(
                                left: 0,
                                top: 12,
                                child: Container(
                                  width: 28.37,
                                  height: 12.82,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFF1FFF3),
                                      width: 1.70,
                                    ),
                                  ),
                                ),
                              ),
                              // Door
                              Positioned(
                                left: 9,
                                top: 16,
                                child: Container(
                                  width: 10,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xFFF1FFF3),
                                      width: 1.70,
                                    ),
                                  ),
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
            ),

            // Food icon (fork and knife)
            Positioned(
              left: 203,
              top: 413,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Transform.rotate(
                    angle: -45 * 3.14159 / 180,
                    child: const Icon(
                      Icons.restaurant,
                      size: 19.144,
                      color: Color(0xFF052224),
                    ),
                  ),
                ],
              ),
            ),

            // Divider between Revenue and Food last week
            Positioned(
              left: 210,
              top: 403,
              child: SizedBox(
                width: 120,
                height: 2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),

            // Salary icon (stack of money)
            Positioned(
              left: 197,
              top: 355,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 31,
                      height: 28,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Container(
                      width: 27,
                      height: 24,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      width: 23,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Divider between Revenue and Food last week
            Positioned(
              left: 186,
              top: 350,
              child: SizedBox(
                width: 2,
                height: 100,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),

            // Circular Progress Bar for Savings Goal with Car Icon
            Positioned(
              left: 73,
              top: 348,
              child: SizedBox(
                width: 71,
                height: 71,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer circle background
                    SizedBox(
                      width: 68.344,
                      height: 68.344,
                      child: CircularProgressIndicator(
                        value: 1.0,
                        backgroundColor: const Color(0xFFF1FFF3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFF1FFF3)),
                        strokeWidth: 3,
                      ),
                    ),
                    // Progress circle (filled portion)
                    _isLoadingProgress
                        ? const SizedBox(
                            width: 68.344,
                            height: 68.344,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                              strokeWidth: 3,
                            ),
                          )
                        : Transform.rotate(
                            angle: -90 * math.pi / 180, // Start from top (-90 degrees)
                            child: SizedBox(
                              width: 68.344,
                              height: 68.344,
                              child: CircularProgressIndicator(
                                value: _savingsProgress,
                                backgroundColor: Colors.transparent,
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0068FF)),
                                strokeWidth: 3,
                                strokeCap: StrokeCap.round,
                              ),
                            ),
                          ),
                    // Car icon for savings goal - positioned at center
                    const Icon(
                      Icons.directions_car,
                      size: 14.338,
                      color: Color(0xFF052224),
                    ),
                  ],
                ),
              ),
            ),

            // Savings on goals text
            Positioned(
              left: 108.5,
              top: 422,
              child: SizedBox(
                width: 63,
                child: Text(
                  'Savings on goals',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.496,
                  ),
                ),
              ),
            ),


            // Notification icon (bell)
            Positioned(
              left: 364,
              top: 61,
              child: GestureDetector(
                onTap: () {
                  // Navigate to notifications if needed
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDFF7E2),
                    borderRadius: BorderRadius.all(Radius.circular(25.71)),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        // Bell shape
                        Positioned(
                          left: 7.71,
                          top: 5.14,
                          child: Container(
                            width: 14.57,
                            height: 18.86,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF052224),
                                width: 1.29,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Bell clapper
                                Positioned(
                                  left: 6,
                                  bottom: 2,
                                  child: Container(
                                    width: 2.5,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF052224),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
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
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 0),
    );
  }
}