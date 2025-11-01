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
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2DD4BF),
          unselectedItemColor: const Color(0xFF757575),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          onTap: (index) {
            switch (index) {
              case 0:
                context.go('/dashboard');
                break;
              case 1:
                context.go('/analytics');
                break;
              case 2:
                context.go('/transactions');
                break;
              case 3:
                context.go('/banks');
                break;
              case 4:
                context.go('/settings');
                break;
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 0 ? Icons.home : Icons.home_outlined,
              ),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
              ),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 2 ? Icons.swap_horiz : Icons.swap_horiz,
              ),
              label: 'Transfer',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 3 ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
              ),
              label: 'Wallet',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                currentIndex == 4 ? Icons.person : Icons.person_outline,
              ),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

