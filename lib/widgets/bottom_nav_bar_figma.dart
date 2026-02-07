import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/theme.dart';

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

  static const _lightGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(38),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 28),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: _lightGreen.withOpacity(0.35),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(
              color: _lightGreen.withOpacity(0.5),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(context: context, index: 0, icon: Icons.home_outlined, activeIcon: Icons.home),
              _buildNavItem(context: context, index: 1, icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart),
              _buildNavItem(context: context, index: 2, icon: Icons.swap_horiz_rounded, activeIcon: Icons.swap_horiz_rounded),
              _buildNavItem(context: context, index: 3, icon: Icons.layers_outlined, activeIcon: Icons.layers),
              _buildNavItem(context: context, index: 4, icon: Icons.person_outline_rounded, activeIcon: Icons.person),
            ],
          ),
        ),
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
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? _lightGreen.withOpacity(0.5) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isActive ? activeIcon : icon,
          color: isActive ? Colors.white : _headerDark.withOpacity(0.9),
          size: 26,
        ),
      ),
    );
  }
}

