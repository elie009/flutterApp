import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/bottom_nav_bar_figma.dart';
import '../widgets/triangle_painter.dart';
import 'package:intl/intl.dart';
import '../services/data_service.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // "Categories" title added at the top of the screen.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 430,
        height: 932,
        decoration: BoxDecoration(
          color: const Color(0xFF00D09E),
          // Add geometric decorations using CustomPaint and positioned circles+shapes
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
           
          
            // White bottom section
            Positioned(
              left: 0,
              top: 191,
              width: 413,
              height: 751,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
              ),
            ),

            // Title "Categories"
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Center(
                child: Text(
                  'Categories',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Circular Total Balance Icon centered below the title "Categories"
            Positioned(
              left: 0,
              right: 0,
              top: 110,
              child: Center(
                child: _buildCircularBalance(),
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

            // Use a column to center everything
            Align(
              alignment: Alignment.center,
              child: Container(
                margin: const EdgeInsets.only(top: 210),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 24),

                    // Grid of categories
                    Container(
                      width: 350,
                      // Ensures labels don't get squeezed
                      child: Column(
                        children: [
                          // Row 1
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _categoryItem(
                                context,
                                icon: _buildFoodIcon(),
                                label: "Food",
                                color: const Color(0xFF0068FF),
                                onTap: () => _navigateToCategory(context, 'Food'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildTransportIcon(),
                                label: "Transport",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Transport'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildMedicineIcon(),
                                label: "Medicine",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Medicine'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Row 2
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _categoryItem(
                                context,
                                icon: _buildGroceriesIcon(),
                                label: "Groceries",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Groceries'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildRentIcon(),
                                label: "Rent",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Rent'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildGiftsIcon(),
                                label: "Gifts",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Gifts'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 28),
                          // Row 3
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _categoryItem(
                                context,
                                icon: _buildSavingsIcon(),
                                label: "Savings",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Savings'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildEntertainmentIcon(),
                                label: "Entertainment",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'Entertainment'),
                              ),
                              _categoryItem(
                                context,
                                icon: _buildMoreIcon(),
                                label: "More",
                                color: const Color(0xFF6DB6FE),
                                onTap: () => _navigateToCategory(context, 'More'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
    );
  }

  // Helper for category + label
  Widget _categoryItem(BuildContext context,
      {required Widget icon,
      required String label,
      required Color color,
      required VoidCallback onTap}) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 80,
            height: 80,
            child: icon,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF093030),
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
         
          child: Center(child: icon),
        ),
      ),
    );
  }

  
  static const Color _iconGreen = Color(0xFF00D09E);

  Widget _buildFoodIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Center(
        child: Icon(
          Icons.restaurant,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildTransportIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildMedicineIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.local_hospital,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildGroceriesIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.shopping_cart,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildRentIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.home,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildGiftsIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.card_giftcard,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildSavingsIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.savings,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildEntertainmentIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.movie,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }

  Widget _buildMoreIcon() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: _iconGreen,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Center(
        child: Icon(
          Icons.more_horiz,
          color: _iconGreen,
          size: 45,
        ),
      ),
    );
  }


  Widget _buildCircularBalance() {
    return FutureBuilder<double>(
      future: DataService().getTotalBalance(),
      builder: (context, snapshot) {
        double? balance = snapshot.data;
        bool loading = snapshot.connectionState == ConnectionState.waiting;

        return Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D09E).withOpacity(0.28),
                spreadRadius: 2,
                blurRadius: 16,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 16,
                    color: Color(0xFF666666),
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Total Balance',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF666666),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              loading
                  ? const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                    )
                  : Text(
                      balance == null
                          ? 'N/A'
                          : NumberFormat('#,##0.00').format(balance),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF00D09E),
                      ),
                    ),
              const SizedBox(height: 4),
              const Text(
                'Total Across All Accounts',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF999999),
                ),
              ),
            ],
          ),
        );
      },
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
