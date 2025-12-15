import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FFF3),
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
                  'Transaction',
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

            // Total balance card
            Positioned(
              left: 37,
              top: 117,
              child: Container(
                width: 357,
                height: 75,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      left: 127,
                      top: 11,
                      child: Text(
                        'Total Balance',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 118,
                      top: 34,
                      child: Text(
                        '\$7,783.00',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 24,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Income summary card
            Positioned(
              left: 37,
              top: 209,
              child: Container(
                width: 171,
                height: 101,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.circular(14.89),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      left: 57,
                      top: 44,
                      child: Text(
                        'Income',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 38,
                      top: 66,
                      child: Text(
                        '\$4,120.00',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 73,
                      top: 41,
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: Icon(
                          Icons.arrow_upward,
                          color: Color(0xFF00D09E),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Expense summary card
            Positioned(
              left: 223,
              top: 209,
              child: Container(
                width: 171,
                height: 101,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.circular(14.89),
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      left: 54,
                      top: 44,
                      child: Text(
                        'Expense',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 41,
                      top: 67,
                      child: Text(
                        '\$1.187.40',
                        style: TextStyle(
                          color: Color(0xFF0068FF),
                          fontSize: 20,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 73,
                      top: 15,
                      child: SizedBox(
                        width: 25,
                        height: 25,
                        child: Icon(
                          Icons.remove,
                          color: Color(0xFF0068FF),
                          size: 25,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // White bottom section
            Positioned(
              left: 0,
              top: 333,
              width: 430,
              height: 599,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(37, 35, 37, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // April transactions
                        const Text(
                          'April',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Salary transaction (April 30)
                        _buildTransactionItem(
                          icon: _buildSalaryIcon(),
                          name: 'Salary',
                          category: 'Monthly',
                          amount: '\$4.000,00',
                          isPositive: true,
                          date: '18:27 - April 30',
                        ),

                        const SizedBox(height: 22),

                        // Groceries transaction (April 24)
                        _buildTransactionItem(
                          icon: _buildGroceriesIcon(),
                          name: 'Groceries',
                          category: 'Pantry',
                          amount: '-\$100,00',
                          isPositive: false,
                          date: '17:00 - April 24',
                        ),

                        const SizedBox(height: 22),

                        // Rent transaction (April 15)
                        _buildTransactionItem(
                          icon: _buildRentIcon(),
                          name: 'Rent',
                          category: 'Rent',
                          amount: '-\$674,40',
                          isPositive: false,
                          date: '8:30 - April 15',
                        ),

                        const SizedBox(height: 22),

                        // Transport transaction (April 8)
                        _buildTransactionItem(
                          icon: _buildTransportIcon(),
                          name: 'Transport',
                          category: 'Fuel',
                          amount: '-\$4,13',
                          isPositive: false,
                          date: '7:30 - April 08',
                        ),

                        const SizedBox(height: 40),

                        // March transactions
                        const Text(
                          'March',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 22),

                        // Food transaction (March 31)
                        _buildTransactionItem(
                          icon: _buildFoodIcon(),
                          name: 'Food',
                          category: 'Dinner',
                          amount: '-\$70,40',
                          isPositive: false,
                          date: '19:30 - March 31',
                        ),

                        const SizedBox(height: 22),

                        // Salary transaction (March 31)
                        _buildTransactionItem(
                          icon: _buildSalaryIcon(),
                          name: 'Salary',
                          category: 'Monthly',
                          amount: '\$4.000,00',
                          isPositive: true,
                          date: '18:39 - March 31',
                        ),
                      ],
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
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 2),
    );
  }

  Widget _buildTransactionItem({
    required Widget icon,
    required String name,
    required String category,
    required String amount,
    required bool isPositive,
    required String date,
  }) {
    return Column(
      children: [
        Row(
          children: [
            // Icon
            SizedBox(
              width: 57,
              height: 53,
              child: icon,
            ),

            const SizedBox(width: 26),

            // Transaction details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 15,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    category,
                    style: const TextStyle(
                      color: Color(0xFF052224),
                      fontSize: 13,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date,
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

            // Amount
            Text(
              amount,
              style: TextStyle(
                color: isPositive ? const Color(0xFF052224) : const Color(0xFF0068FF),
                fontSize: 15,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 22),

        // Separator lines
        Row(
          children: [
            const SizedBox(width: 83), // Space for icon
            Expanded(
              child: Container(
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00D09E),
                    width: 1.01,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 94), // Space for amount
            Expanded(
              child: Container(
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF00D09E),
                    width: 1.01,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSalaryIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF6DB6FE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 26,
          height: 23.48,
          child: Icon(
            Icons.attach_money,
            color: Color(0xFFF1FFF3),
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildGroceriesIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF3299FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 16.76,
          height: 27.44,
          child: Icon(
            Icons.shopping_cart,
            color: Color(0xFFF1FFF3),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildRentIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF0068FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 28.37,
          height: 24.82,
          child: Icon(
            Icons.home,
            color: Color(0xFFF1FFF3),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildTransportIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF3299FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 25.45,
          height: 25.51,
          child: Icon(
            Icons.directions_car,
            color: Color(0xFFF1FFF3),
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF6DB6FE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 15.62,
          height: 27.79,
          child: Icon(
            Icons.restaurant,
            color: Color(0xFFF1FFF3),
            size: 20,
          ),
        ),
      ),
    );
  }
}