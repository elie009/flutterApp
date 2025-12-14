import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar_mobile.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

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
              top: 281,
              width: 430,
              height: 651,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
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

            // Categories title
            const Positioned(
              left: 153,
              top: 64,
              child: SizedBox(
                width: 125,
                child: Text(
                  'Categories',
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

            // Category icons - Row 1
            _buildCategoryIcon(
              left: 37,
              top: 314,
              color: const Color(0xFF0068FF),
              icon: _buildFoodIcon(),
              onTap: () => _navigateToCategory(context, 'Food'),
            ),
            _buildCategoryIcon(
              left: 163,
              top: 314,
              color: const Color(0xFF6DB6FE),
              icon: _buildTransportIcon(),
              onTap: () => _navigateToCategory(context, 'Transport'),
            ),
            _buildCategoryIcon(
              left: 289,
              top: 314,
              color: const Color(0xFF6DB6FE),
              icon: _buildMedicineIcon(),
              onTap: () => _navigateToCategory(context, 'Medicine'),
            ),

            // Category icons - Row 2
            _buildCategoryIcon(
              left: 37,
              top: 483,
              color: const Color(0xFF6DB6FE),
              icon: _buildGroceriesIcon(),
              onTap: () => _navigateToCategory(context, 'Groceries'),
            ),
            _buildCategoryIcon(
              left: 163,
              top: 484,
              color: const Color(0xFF6DB6FE),
              icon: _buildRentIcon(),
              onTap: () => _navigateToCategory(context, 'Rent'),
            ),
            _buildCategoryIcon(
              left: 289,
              top: 483,
              color: const Color(0xFF6DB6FE),
              icon: _buildGiftsIcon(),
              onTap: () => _navigateToCategory(context, 'Gifts'),
            ),

            // Category icons - Row 3
            _buildCategoryIcon(
              left: 37,
              top: 645,
              color: const Color(0xFF6DB6FE),
              icon: _buildSavingsIcon(),
              onTap: () => _navigateToCategory(context, 'Savings'),
            ),
            _buildCategoryIcon(
              left: 166,
              top: 645,
              color: const Color(0xFF6DB6FE),
              icon: _buildEntertainmentIcon(),
              onTap: () => _navigateToCategory(context, 'Entertainment'),
            ),
            _buildCategoryIcon(
              left: 289,
              top: 645,
              color: const Color(0xFF6DB6FE),
              icon: _buildMoreIcon(),
              onTap: () => _navigateToCategory(context, 'More'),
            ),

            // Category labels
            const Positioned(
              left: 65,
              top: 414,
              child: Text(
                'Food',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 179,
              top: 414,
              child: Text(
                'Transport',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 307,
              top: 414,
              child: Text(
                'Medicine',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 53,
              top: 583,
              child: Text(
                'Groceries',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 198,
              top: 583,
              child: Text(
                'Rent',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 324,
              top: 583,
              child: Text(
                'Gifts',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 59,
              top: 748,
              child: Text(
                'Savings',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 164,
              top: 748,
              child: Text(
                'Entertainment',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const Positioned(
              left: 323,
              top: 748,
              child: Text(
                'More',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
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

            // Bottom Navigation
            Positioned(
              left: 0,
              top: 824,
              width: 430,
              height: 108,
              child: BottomNavBarMobile(currentIndex: 2),
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
    );
  }

  Widget _buildCategoryIcon({
    required double left,
    required double top,
    required Color color,
    required Widget icon,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 105,
          height: 97.63,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(25.79),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }

  Widget _buildFoodIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildTransportIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.directions_car,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildMedicineIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.local_hospital,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildGroceriesIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.shopping_cart,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildRentIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.home,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildGiftsIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.card_giftcard,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildSavingsIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.savings,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildEntertainmentIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.movie,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return const SizedBox(
      width: 69,
      height: 69,
      child: Center(
        child: Icon(
          Icons.more_horiz,
          color: Color(0xFFF1FFF3),
          size: 70,
        ),
      ),
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    // For now, just show a snackbar. In a real app, this would navigate to category details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $categoryName category'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}
