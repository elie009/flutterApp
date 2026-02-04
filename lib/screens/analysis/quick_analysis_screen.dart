import 'package:flutter/material.dart';

class QuickAnalysisScreen extends StatelessWidget {
  const QuickAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // Status bar
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 430,
                height: 32,
                decoration: const BoxDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      left: 37,
                      top: 9,
                      child: SizedBox(
                        width: 30,
                        height: 14,
                        child: Text(
                          '16:04',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
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
            ),

            // Title
            const Positioned(
              left: 127,
              top: 64,
              child: SizedBox(
                width: 177,
                child: Text(
                  'Quickly Analysis',
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

            // Revenue Last Week section
            const Positioned(
              left: 251,
              top: 140,
              child: SizedBox(
                width: 117,
                height: 20,
                child: Text(
                  'Revenue Last Week',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 250.90,
              top: 163,
              child: SizedBox(
                width: 117.42,
                height: 23.71,
                child: Text(
                  '\$4.000.00',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 16.94,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Food Last Week section
            const Positioned(
              left: 251,
              top: 223,
              child: SizedBox(
                width: 115,
                height: 20,
                child: Text(
                  'Food Last Week',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 12,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            const Positioned(
              left: 250.90,
              top: 245,
              child: SizedBox(
                width: 82.42,
                height: 22.58,
                child: Text(
                  '- \$100.00',
                  style: TextStyle(
                    color: Color(0xFF0068FF),
                    fontSize: 16.94,
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // Savings on goals section
            const Positioned(
              left: 78,
              top: 236,
              child: SizedBox(
                width: 70,
                height: 40,
                child: Text(
                  'Savings on goals',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                    height: 1.50,
                  ),
                ),
              ),
            ),

            // Circular progress indicators for savings goals
            Positioned(
              left: 61,
              top: 231.91,
              child: Transform.rotate(
                angle: -1.53, // -87.5 degrees
                child: Container(
                  width: 95.98,
                  height: 95.98,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border(
                      top: BorderSide(
                        width: 3.26,
                        color: Color(0xFFF1FFF2),
                      ),
                      left: BorderSide(
                        width: 3.26,
                        color: Color(0xFFF1FFF2),
                      ),
                      right: BorderSide(
                        width: 3.26,
                        color: Color(0xFFF1FFF2),
                      ),
                      bottom: BorderSide(
                        width: 3.26,
                        color: Colors.transparent,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // April Expenses title
            const Positioned(
              left: 66,
              top: 356,
              child: Text(
                'April Expenses',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Chart legend icons
            Positioned(
              left: 296,
              top: 351,
              child: Container(
                width: 32.26,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFb3ee9a),
                  borderRadius: BorderRadius.all(Radius.circular(12.45)),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            Positioned(
              left: 332,
              top: 351,
              child: Container(
                width: 32.26,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFb3ee9a),
                  borderRadius: BorderRadius.all(Radius.circular(12.45)),
                ),
                child: const Icon(
                  Icons.trending_down,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),

            // Bar chart
            Positioned(
              left: 107,
              top: 454,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // 1st Week
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 6,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xFFb3ee9a),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 55),

                  // 2nd Week
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 6,
                        height: 15,
                        decoration: const BoxDecoration(
                          color: Color(0xFFb3ee9a),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 51,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0068FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 55),

                  // 3rd Week
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 6,
                        height: 33,
                        decoration: const BoxDecoration(
                          color: Color(0xFFb3ee9a),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 83,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0068FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 55),

                  // 4th Week
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        width: 6,
                        height: 66,
                        decoration: const BoxDecoration(
                          color: Color(0xFFb3ee9a),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                      Container(
                        width: 6,
                        height: 47,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0068FF),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(31),
                            topRight: Radius.circular(31),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chart labels
            const Positioned(
              left: 92,
              top: 542,
              child: Text(
                '1st Week',
                style: TextStyle(
                  color: Color(0xFF0E3E3E),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 161,
              top: 542,
              child: Text(
                '2nd Week',
                style: TextStyle(
                  color: Color(0xFF0E3E3E),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 236,
              top: 542,
              child: Text(
                '3rd Week',
                style: TextStyle(
                  color: Color(0xFF0E3E3E),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 307,
              top: 542,
              child: Text(
                '4th Week',
                style: TextStyle(
                  color: Color(0xFF0E3E3E),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Y-axis labels
            const Positioned(
              left: 67,
              top: 399,
              child: Text(
                '15k',
                style: TextStyle(
                  color: Color(0xFF6CB5FD),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 67,
              top: 431,
              child: Text(
                '10k',
                style: TextStyle(
                  color: Color(0xFF6CB5FD),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 67,
              top: 464,
              child: Text(
                '5k',
                style: TextStyle(
                  color: Color(0xFF6CB5FD),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const Positioned(
              left: 67,
              top: 497,
              child: Text(
                '1k',
                style: TextStyle(
                  color: Color(0xFF6CB5FD),
                  fontSize: 14,
                  fontFamily: 'League Spartan',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Recent transactions
            // Salary transaction
            Positioned(
              left: 37,
              top: 610,
              child: Row(
                children: [
                  Container(
                    width: 57,
                    height: 53,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6CB5FD),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Salary',
                          style: TextStyle(
                            color: Color(0xFF052224),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              '18:27 - April 30',
                              style: TextStyle(
                                color: Color(0xFF0068FF),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 0,
                              height: 35.49,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 1.01,
                                    color: Color(0xFFb3ee9a),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Monthly',
                              style: TextStyle(
                                color: Color(0xFF052224),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                                height: 1.15,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '\$4.000,00',
                              style: TextStyle(
                                color: Color(0xFF093030),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Groceries transaction
            Positioned(
              left: 37,
              top: 682,
              child: Row(
                children: [
                  Container(
                    width: 57,
                    height: 53,
                    decoration: BoxDecoration(
                      color: const Color(0xFF3299FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.shopping_cart,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Groceries',
                          style: TextStyle(
                            color: Color(0xFF052224),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              '17:00 - April 24',
                              style: TextStyle(
                                color: Color(0xFF0068FF),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 0,
                              height: 35.49,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 1.01,
                                    color: Color(0xFFb3ee9a),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Pantry',
                              style: TextStyle(
                                color: Color(0xFF052224),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                                height: 1.15,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '-\$100,00',
                              style: TextStyle(
                                color: Color(0xFF0068FF),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Rent transaction
            Positioned(
              left: 37,
              top: 754,
              child: Row(
                children: [
                  Container(
                    width: 57,
                    height: 53,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0068FF),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Icon(
                      Icons.home,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Rent',
                          style: TextStyle(
                            color: Color(0xFF052224),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Text(
                              '8:30 - April 15',
                              style: TextStyle(
                                color: Color(0xFF0068FF),
                                fontSize: 12,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                height: 1.25,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Container(
                              width: 0,
                              height: 35.49,
                              decoration: const BoxDecoration(
                                border: Border(
                                  left: BorderSide(
                                    width: 1.01,
                                    color: Color(0xFFb3ee9a),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'Rent',
                              style: TextStyle(
                                color: Color(0xFF052224),
                                fontSize: 13,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w300,
                                height: 1.15,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              '-\$674,40',
                              style: TextStyle(
                                color: Color(0xFF0068FF),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
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
                    // Home icon
                    Container(
                      width: 25,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Analysis icon (active)
                    Stack(
                      children: [
                        Positioned(
                          left: -13,
                          top: -11,
                          child: Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: const Color(0xFFb3ee9a),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Container(
                          width: 31,
                          height: 30,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF052224),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Transactions icon
                    Container(
                      width: 33,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Categories icon
                    Container(
                      width: 27,
                      height: 23,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Profile icon
                    Container(
                      width: 22,
                      height: 27,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
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
    );
  }
}




