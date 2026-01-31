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

    final String location;
    switch (index) {
      case 0:
        location = '/';
        break;
      case 1:
        location = '/analysis';
        break;
      case 2:
        location = '/transactions';
        break;
      case 3:
        location = '/category';
        break;
      case 4:
        location = '/profile';
        break;
      default:
        return;
    }
    GoRouter.of(context).go(location);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 28), // Increased bottom margin for more "floating" effect
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10), // More padding for bigger look
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90), // More opaque for increased visibility
        borderRadius: BorderRadius.circular(38),
        boxShadow: [
          // Stronger shadow for elevation
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 6,
            offset: const Offset(0, 2),
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
      behavior: HitTestBehavior.opaque,
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

