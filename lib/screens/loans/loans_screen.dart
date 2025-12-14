import 'package:flutter/material.dart';
import '../../utils/navigation_helper.dart';

class LoansScreen extends StatefulWidget {
  const LoansScreen({super.key});

  @override
  State<LoansScreen> createState() => _LoansScreenState();
}

class _LoansScreenState extends State<LoansScreen> {
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
            // Status bar
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 32,
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
              left: 189,
              top: 64,
              child: SizedBox(
                width: 52,
                child: Text(
                  'Loans',
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

            // Balance section
            const Positioned(
              left: 60,
              top: 152,
              child: Text(
                '\$15,230.00',
                style: TextStyle(
                  color: Color(0xFFF1FFF3),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const Positioned(
              left: 249,
              top: 152,
              child: Text(
                '-\$2,450.80',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 24,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Positioned(
              left: 78,
              top: 136,
              child: Text(
                'Total Loans',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              left: 216,
              top: 178,
              child: Transform.rotate(
                angle: -90 * 3.14159 / 180,
                child: Container(
                  width: 42,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFFDFF7E2),
                        width: 1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 268,
              top: 137,
              child: Text(
                'Monthly Payments',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            // Expense arrows
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
              top: 139,
              child: Transform.rotate(
                angle: -90 * 3.14159 / 180,
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
            ),

            // Progress bar section
            const Positioned(
              left: 81,
              top: 237,
              child: Text(
                '65% of your loan capacity used.',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
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
              ),
            ),
            const Positioned(
              left: 71,
              top: 205,
              child: Text(
                '65%',
                style: TextStyle(
                  color: Color(0xFFF1FFF3),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
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
                alignment: Alignment.center,
                child: const Text(
                  '\$8,450.00',
                  style: TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Check mark
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
                child: const Stack(
                  children: [
                    Positioned(
                      left: 3,
                      top: 3,
                      child: SizedBox(
                        width: 6,
                        height: 5,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(
                                color: Color(0xFF052224),
                                width: 1,
                              ),
                              right: BorderSide(
                                color: Color(0xFF052224),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // April section
            const Positioned(
              left: 37,
              top: 309,
              child: Text(
                'April',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Calendar button
            Positioned(
              left: 362,
              top: 308,
              child: Container(
                width: 32.26,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09E),
                  borderRadius: BorderRadius.circular(12.45),
                ),
              ),
            ),

            // Date circles and loan items for April
            // April 30 - Car Loan Payment
            Positioned(
              left: 37,
              top: 349,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF6CB5FD),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 351,
              child: Text(
                'Car Loan Payment',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 337,
              top: 368,
              child: Text(
                '-\$450.00',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 376.35,
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

            // April 24 - Home Loan Payment
            Positioned(
              left: 37,
              top: 426,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF3299FF),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 426,
              child: Text(
                'Home Mortgage',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 338,
              top: 436,
              child: Text(
                '-\$1,200.00',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 451.35,
              child: Text(
                '15:00 - April 24',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // April 15 - Student Loan Payment
            Positioned(
              left: 37,
              top: 503,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF6CB5FD),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 508,
              child: Text(
                'Student Loan',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 336,
              top: 524,
              child: Text(
                '-\$320.50',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 110,
              top: 533.35,
              child: Text(
                '12:30 - April 15',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // March section
            const Positioned(
              left: 38,
              top: 652,
              child: Text(
                'March',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // March 31 - Personal Loan Payment
            Positioned(
              left: 38,
              top: 695,
              child: Container(
                width: 57,
                height: 53,
                decoration: BoxDecoration(
                  color: const Color(0xFF6CB5FD),
                  borderRadius: BorderRadius.circular(22),
                ),
              ),
            ),
            const Positioned(
              left: 111,
              top: 694,
              child: Text(
                'Personal Loan',
                style: TextStyle(
                  color: Color(0xFF052224),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 334,
              top: 710,
              child: Text(
                '-\$180.25',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Positioned(
              left: 111,
              top: 720.35,
              child: Text(
                '20:50 - March 31',
                style: TextStyle(
                  color: Color(0xFF0068FF),
                  fontSize: 12,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Add Loan button
            Positioned(
              left: 123,
              top: 769,
              child: GestureDetector(
                onTap: () {
                  NavigationHelper.navigateTo(context, 'add-loan');
                },
                child: Container(
                  width: 169,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Add Loan',
                    style: TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
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

                    // Analysis icon
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

                    // Loans icon (active)
                    Stack(
                      children: [
                        Positioned(
                          left: -15,
                          top: -15,
                          child: Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
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
                      ],
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

