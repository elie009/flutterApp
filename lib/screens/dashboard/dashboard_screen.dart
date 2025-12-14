import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_mobile.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // White bottom section
            Positioned(
              left: 0,
              top: 292,
              width: 430,
              height: 640,
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
              width: 430,
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
                '\$4.000.00',
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
                '-\$100.00',
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

            // Groceries icon
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
                  child: Container(
                    width: 16.76,
                    height: 27.44,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFF1FFF3),
                        width: 1.70,
                      ),
                    ),
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

            // Rent icon
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
                  child: Container(
                    width: 28.37,
                    height: 24.82,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFF1FFF3),
                        width: 1.70,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0.88,
                          top: 0.88,
                          child: Container(
                            width: 26.64,
                            height: 23.09,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFFF1FFF3),
                                width: 1.70,
                              ),
                            ),
                          ),
                        ),
                        const Positioned(
                          left: 4.76,
                          top: 3.90,
                          child: Text(
                            '•',
                            style: TextStyle(
                              color: Color(0xFFF1FFF3),
                              fontSize: 8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Chart elements in the green card
            Positioned(
              left: 203,
              top: 413,
              child: Container(
                width: 19.14,
                height: 34.06,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF093030),
                    width: 2.08,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 197,
              top: 355,
              child: Container(
                width: 31,
                height: 28,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF093030),
                    width: 2.11,
                  ),
                  borderRadius: BorderRadius.circular(0.53),
                ),
              ),
            ),

            Positioned(
              left: 90,
              top: 372.79,
              child: Container(
                width: 37.57,
                height: 21.75,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF052224),
                    width: 1.98,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 73,
              top: 416.29,
              child: Transform.rotate(
                angle: -88 * 3.14159 / 180, // -88 degrees in radians
                child: Container(
                  width: 68.34,
                  height: 68.34,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF1FFF3),
                      width: 2.32,
                    ),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 107.41,
              top: 416.73,
              child: Transform.rotate(
                angle: -88 * 3.14159 / 180, // -88 degrees in radians
                child: Container(
                  width: 66.48,
                  height: 33.01,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFF0068FF),
                      width: 3.25,
                    ),
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 77,
              top: 422,
              child: SizedBox(
                width: 63,
                height: 33,
                child: Text(
                  'Savings on goals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              top: 824,
              width: 430,
              height: 108,
              child: Container(
                padding: const EdgeInsets.fromLTRB(60, 36, 60, 41),
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home page (active)
                    Transform.translate(
                      offset: const Offset(0, -10), // Move up for highlight effect
                      child: Container(
                        width: 57,
                        height: 53,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09E), // Active highlight
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Container(
                          width: 25,
                          height: 31,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF052224),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Search page
                    GestureDetector(
                      onTap: () => context.go('/analysis'),
                      child: Container(
                        width: 31,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF052224),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.search,
                          color: Color(0xFF052224),
                          size: 16,
                        ),
                      ),
                    ),

                    // Category page
                    GestureDetector(
                      onTap: () => context.go('/category'),
                      child: Container(
                        width: 27,
                        height: 23,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF052224),
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    // Transaction page
                    GestureDetector(
                      onTap: () => context.go('/transactions'),
                      child: Container(
                        width: 33,
                        height: 25,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF052224),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet,
                          color: Color(0xFF052224),
                          size: 14,
                        ),
                      ),
                    ),

                    // Profile page
                    GestureDetector(
                      onTap: () => context.go('/profile'),
                      child: Container(
                        width: 22,
                        height: 27,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF052224),
                            width: 2,
                          ),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF052224),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
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
      bottomNavigationBar: const BottomNavBarMobile(currentIndex: 0),
    );
  }
}