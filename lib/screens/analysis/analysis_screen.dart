import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  String _selectedPeriod = 'Daily'; // 'Daily', 'Weekly', 'Monthly', 'Year'

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // White bottom section
            Positioned(
              left: 0,
              top: 282,
              width: 430,
              height: 650,
              child: Container(
                padding: const EdgeInsets.fromLTRB(37, 35, 37, 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Time period selector
                      Container(
                        width: 357,
                        height: 60,
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Daily
                            GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = 'Daily'),
                              child: Container(
                                width: 78,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == 'Daily'
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Daily',
                                  style: TextStyle(
                                    color: _selectedPeriod == 'Daily'
                                        ? Colors.white
                                        : const Color(0xFF093030),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Weekly
                            GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = 'Weekly'),
                              child: Container(
                                width: 78,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == 'Weekly'
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Weekly',
                                  style: TextStyle(
                                    color: _selectedPeriod == 'Weekly'
                                        ? Colors.white
                                        : const Color(0xFF093030),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Monthly
                            GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = 'Monthly'),
                              child: Container(
                                width: 78,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == 'Monthly'
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Monthly',
                                  style: TextStyle(
                                    color: _selectedPeriod == 'Monthly'
                                        ? Colors.white
                                        : const Color(0xFF093030),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),

                            // Year
                            GestureDetector(
                              onTap: () => setState(() => _selectedPeriod = 'Year'),
                              child: Container(
                                width: 78,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: _selectedPeriod == 'Year'
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'Year',
                                  style: TextStyle(
                                    color: _selectedPeriod == 'Year'
                                        ? Colors.white
                                        : const Color(0xFF093030),
                                    fontSize: 15,
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Income and Expenses Bar Chart
                      Container(
                        width: 357,
                        height: 200,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1FFF3),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'Income and Expenses',
                                style: TextStyle(
                                  color: Color(0xFF093030),
                                  fontSize: 16,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildBar('Mon', 60, const Color(0xFFb3ee9a)),
                                    _buildBar('Tue', 80, const Color(0xFFb3ee9a)),
                                    _buildBar('Wed', 45, const Color(0xFF0068FF)),
                                    _buildBar('Thu', 70, const Color(0xFFb3ee9a)),
                                    _buildBar('Fri', 55, const Color(0xFF0068FF)),
                                    _buildBar('Sat', 90, const Color(0xFFb3ee9a)),
                                    _buildBar('Sun', 65, const Color(0xFF0068FF)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),

                      // Summary Cards
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Income Card
                          Container(
                            width: 165,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1FFF3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Income',
                                    style: TextStyle(
                                      color: Color(0xFF093030),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\$4,120.00',
                                    style: TextStyle(
                                      color: Color(0xFFb3ee9a),
                                      fontSize: 16,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Expenses Card
                          Container(
                            width: 165,
                            height: 80,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1FFF3),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Expenses',
                                    style: TextStyle(
                                      color: Color(0xFF093030),
                                      fontSize: 12,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '\$1,187.40',
                                    style: TextStyle(
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

                      const SizedBox(height: 30),

                      // My targets section
                      const Text(
                        'My targets',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 18,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Target items
                      _buildTargetItem('Emergency Fund', 0.75, '\$7,500'),
                      const SizedBox(height: 16),
                      _buildTargetItem('Vacation', 0.5, '\$3,000'),
                      const SizedBox(height: 16),
                      _buildTargetItem('New Car', 0.3, '\$15,000'),
                    ],
                  ),
                ),
              ),
            ),

            // Status bar
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 32,
              child: Stack(
                children: [
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

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: Container(
                width: 19,
                height: 16,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFF1FFF3),
                    width: 2,
                  ),
                ),
              ),
            ),

            // Title
            const Positioned(
              left: 153,
              top: 64,
              child: SizedBox(
                width: 125,
                child: Text(
                  'Analysis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
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
                '\$7,783.00',
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
                '-\$1.187.40',
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

            // Progress indicators
            Positioned(
              left: 60,
              top: 139,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF052224),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

            Positioned(
              left: 249,
              top: 139,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF052224),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),

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
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF052224),
                      width: 1,
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 61,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: Center(
                  child: Container(
                    width: 14.57,
                    height: 18.86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF093030),
                        width: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 1),
    );
  }

  Widget _buildBar(String label, double height, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 30,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF093030),
            fontSize: 12,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
        ),
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
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFb3ee9a)),
              strokeWidth: 6,
            ),
          ),
        ],
      ),
    );
  }
}