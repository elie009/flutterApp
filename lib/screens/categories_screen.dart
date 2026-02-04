import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../config/app_config.dart';
import '../services/data_service.dart';
import '../widgets/bottom_nav_bar_figma.dart';
import '../widgets/triangle_painter.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _primaryGreen = Color(0xFFb3ee9a);
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF666666);
  static const _textLightGray = Color(0xFF999999);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header: light green with geometric shapes
            Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 24,
                right: 24,
                bottom: 40,
              ),
              decoration: const BoxDecoration(
                color: _primaryGreen,
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Categories',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.notifications_outlined,
                          color: _headerDark,
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // White content with overlapping balance circle
            Expanded(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // White content area
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    margin: const EdgeInsets.only(top: 0),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(
                        left: 24,
                        right: 24,
                        top: 140,
                        bottom: 24,
                      ),
                      child: _buildCategoryGrid(context),
                    ),
                  ),
                  // Overlapping balance circle (moved down)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: -55,
                    child: Center(
                      child: _buildCircularBalance(context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 3),
    );
  }

  Widget _buildCircularBalance(BuildContext context) {
    return FutureBuilder<double>(
      future: DataService().getTotalBalance(),
      builder: (context, snapshot) {
        final balance = snapshot.data;
        final loading = snapshot.connectionState == ConnectionState.waiting;
        final currencySymbol = AppConfig.currencySymbol;

        return GestureDetector(
          onTap: () => context.push('/transactions'),
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: _primaryGreen, width: 3),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.25),
                  spreadRadius: 2,
                  blurRadius: 16,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Total Balance',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _textGray,
                  ),
                ),
                const SizedBox(height: 8),
                loading
                    ? const SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_primaryGreen),
                        ),
                      )
                    : Text(
                        balance != null
                            ? '$currencySymbol${NumberFormat('#,##0').format(balance)}'
                            : 'N/A',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: _primaryGreen,
                        ),
                      ),
                const SizedBox(height: 4),
                const Text(
                  'Across All Accounts',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: _textLightGray,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '+ Tap to add transaction',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF093030), // dark green
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CategoryItem(
              icon: Icons.restaurant,
              label: 'Food',
              onTap: () => _navigateToCategory(context, 'Food'),
            ),
            _CategoryItem(
              icon: Icons.local_shipping,
              label: 'Transport',
              onTap: () => _navigateToCategory(context, 'Transport'),
            ),
            _CategoryItem(
              icon: Icons.local_hospital,
              label: 'Medicine',
              onTap: () => _navigateToCategory(context, 'Medicine'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CategoryItem(
              icon: Icons.shopping_cart,
              label: 'Groceries',
              onTap: () => _navigateToCategory(context, 'Groceries'),
            ),
            _CategoryItem(
              icon: Icons.home,
              label: 'Rent',
              onTap: () => _navigateToCategory(context, 'Rent'),
            ),
            _CategoryItem(
              icon: Icons.card_giftcard,
              label: 'Gifts',
              onTap: () => _navigateToCategory(context, 'Gifts'),
            ),
          ],
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _CategoryItem(
              icon: Icons.savings,
              label: 'Savings',
              onTap: () => _navigateToCategory(context, 'Savings'),
            ),
            _CategoryItem(
              icon: Icons.movie,
              label: 'Entertainment',
              onTap: () => _navigateToCategory(context, 'Entertainment'),
            ),
            _CategoryItem(
              icon: Icons.more_horiz,
              label: 'More',
              onTap: () => _navigateToCategory(context, 'More'),
            ),
          ],
        ),
      ],
    );
  }

  void _navigateToCategory(BuildContext context, String categoryName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigate to $categoryName category'),
        duration: const Duration(seconds: 1),
        backgroundColor: _primaryGreen,
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const _primaryGreen = Color(0xFFb3ee9a);
  static const _headerDark = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _primaryGreen, width: 2),
            ),
            child: Icon(
              icon,
              color: _primaryGreen,
              size: 42,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: _headerDark,
            fontSize: 14,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
