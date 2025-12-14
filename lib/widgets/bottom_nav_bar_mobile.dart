import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBarMobile extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarMobile({
    super.key,
    required this.currentIndex,
  });

  void _navigateTo(BuildContext context, int index) {
    if (index == currentIndex) return; // Already on this page

    switch (index) {
      case 0:
        context.go('/'); // Home page
        break;
      case 1:
        context.go('/analysis');
        break;
      case 2:
        context.go('/category'); // Categories page
        break;
      case 3:
        context.go('/transactions');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      height: 108,
      padding: const EdgeInsets.fromLTRB(60, 36, 60, 41),
      decoration: const BoxDecoration(
        color: Color(0xFFDFF7E2), // #DFF7E2 - Light green background
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(70),
          topRight: Radius.circular(70),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home page
          _buildNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
            isActive: currentIndex == 0,
            onTap: () => _navigateTo(context, 0),
          ),

          // Analysis page
          _buildNavItem(
            icon: Icons.analytics_outlined,
            activeIcon: Icons.analytics,
            isActive: currentIndex == 1,
            onTap: () => _navigateTo(context, 1),
          ),

          // Category page
          Transform.translate(
            offset: const Offset(0, -15), // Move up by 15 pixels for highlight effect
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 2 ? const Color(0xFF00D09E) : Colors.transparent, // Green highlight for active
                borderRadius: BorderRadius.circular(22),
              ),
              child: _buildNavItem(
                icon: Icons.category_outlined,
                activeIcon: Icons.category,
                isActive: currentIndex == 2,
                onTap: () => _navigateTo(context, 2),
              ),
            ),
          ),

          // Transaction page
          _buildNavItem(
            icon: Icons.account_balance_wallet_outlined,
            activeIcon: Icons.account_balance_wallet,
            isActive: currentIndex == 3,
            onTap: () => _navigateTo(context, 3),
          ),

          // Profile page
          _buildNavItem(
            icon: Icons.person_outlined,
            activeIcon: Icons.person,
            isActive: currentIndex == 4,
            onTap: () => _navigateTo(context, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFF052224), // Dark border
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: const Color(0xFF052224), // Dark icon color
          size: 20,
        ),
      ),
    );
  }
}
