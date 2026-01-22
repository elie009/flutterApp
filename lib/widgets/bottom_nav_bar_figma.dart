import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBarFigma extends StatelessWidget {
  final int currentIndex;

  const BottomNavBarFigma({
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
        context.go('/transactions');
        break;
      case 3:
        context.go('/category');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(50),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Home page
          _buildNavItem(
            context: context,
            index: 0,
            icon: Icons.home_outlined,
            activeIcon: Icons.home,
          ),

          // Analysis page (bar chart icon)
          _buildNavItem(
            context: context,
            index: 1,
            icon: Icons.bar_chart_outlined,
            activeIcon: Icons.bar_chart,
          ),

          // Transactions page (double arrow icon)
          _buildNavItem(
            context: context,
            index: 2,
            icon: Icons.swap_horiz_rounded,
            activeIcon: Icons.swap_horiz_rounded,
          ),

          // Category page (layers/stack icon)
          _buildNavItem(
            context: context,
            index: 3,
            icon: Icons.layers_outlined,
            activeIcon: Icons.layers,
          ),

          // Profile page (person icon)
          _buildNavItem(
            context: context,
            index: 4,
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
  }) {
    final isActive = currentIndex == index;
    
    return GestureDetector(
      onTap: () => _navigateTo(context, index),
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFE8F5E9) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? const Color(0xFF00D09E) : const Color(0xFF666666),
          size: 28,
        ),
      ),
    );
  }
}

