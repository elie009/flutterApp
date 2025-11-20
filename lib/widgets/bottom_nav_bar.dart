import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
        child: Container(
          height: 77,
          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Home
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: currentIndex == 0 ? Icons.home : Icons.home_outlined,
                  label: 'Home',
                  index: 0,
                  route: '/dashboard',
                ),
              ),
              // Analytics
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
                  label: 'Analytics',
                  index: 1,
                  route: '/analytics',
                ),
              ),
              // Category (Center - Bigger)
              Expanded(
                child: _buildCenterNavItem(
                  context,
                  icon: currentIndex == 2 ? Icons.apps : Icons.apps_outlined,
                  label: 'Category',
                  index: 2,
                  route: '/category',
                ),
              ),
              // Transactions
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: currentIndex == 3 ? Icons.receipt_long : Icons.receipt_long_outlined,
                  label: 'Transactions',
                  index: 3,
                  route: '/transactions',
                ),
              ),
              // Profile
              Expanded(
                child: _buildNavItem(
                  context,
                  icon: currentIndex == 4 ? Icons.person : Icons.person_outline,
                  label: 'Profile',
                  index: 4,
                  route: '/settings',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF10B981) : const Color(0xFF757575);

    return GestureDetector(
      onTap: () {
        // If we're in a pushed route (like AnalyzerScreen), pop first then navigate
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 22,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int index,
    required String route,
  }) {
    final isSelected = currentIndex == index;
    final color = isSelected ? const Color(0xFF10B981) : const Color(0xFF757575);

    return GestureDetector(
      onTap: () {
        // If we're in a pushed route (like AnalyzerScreen), pop first then navigate
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        context.go(route);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected ? color.withOpacity(0.15) : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: color,
                size: 28, // Bigger icon but adjusted
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12, // Adjusted font size
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
