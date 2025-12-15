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
          // Home page
          GestureDetector(
            onTap: () => _navigateTo(context, 0),
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 0
                    ? const Color(0xFF00D09E) // Active highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.home,
                color: currentIndex == 0 ? Colors.white : const Color(0xFF052224),
                size: 25,
              ),
            ),
          ),

          // Analysis page (bar chart icon)
          GestureDetector(
            onTap: () => _navigateTo(context, 1),
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 1
                    ? const Color(0xFF00D09E) // Active highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.bar_chart,
                color: currentIndex == 1 ? Colors.white : const Color(0xFF052224),
                size: 30,
              ),
            ),
          ),

          // Transactions page (double arrow icon)
          GestureDetector(
            onTap: () => _navigateTo(context, 2),
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 2
                    ? const Color(0xFF00D09E) // Active highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.swap_horiz,
                color: currentIndex == 2 ? Colors.white : const Color(0xFF052224),
                size: 25,
              ),
            ),
          ),

          // Category page (transaction icon - wallet/receipt)
          GestureDetector(
            onTap: () => _navigateTo(context, 3),
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 3
                    ? const Color(0xFF00D09E) // Active highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.account_balance_wallet,
                color: currentIndex == 3 ? Colors.white : const Color(0xFF052224),
                size: 23,
              ),
            ),
          ),

          // Profile page (person icon)
          GestureDetector(
            onTap: () => _navigateTo(context, 4),
            child: Container(
              width: 57,
              height: 53,
              decoration: BoxDecoration(
                color: currentIndex == 4
                    ? const Color(0xFF00D09E) // Active highlight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Icon(
                Icons.person_outline,
                color: currentIndex == 4 ? Colors.white : const Color(0xFF052224),
                size: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

