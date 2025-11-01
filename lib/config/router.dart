import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/bills/bill_detail_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/loans/loan_detail_screen.dart';
import '../screens/income/income_sources_screen.dart';
import '../screens/bank/bank_accounts_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../services/auth_service.dart';
import '../utils/navigation_helper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = AuthService.isAuthenticated();
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isLoginRoute) {
        return '/login';
      }
      if (isLoggedIn && isLoginRoute) {
        return '/dashboard';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/transactions',
        name: 'transactions',
        builder: (context, state) => const TransactionsScreen(),
      ),
      GoRoute(
        path: '/bills',
        name: 'bills',
        builder: (context, state) => const BillsScreen(),
      ),
      GoRoute(
        path: '/bills/:id',
        name: 'bill-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return BillDetailScreen(billId: id);
        },
      ),
      GoRoute(
        path: '/loans',
        name: 'loans',
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: '/loans/:id',
        name: 'loan-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return LoanDetailScreen(loanId: id);
        },
      ),
      GoRoute(
        path: '/income',
        name: 'income',
        builder: (context, state) => const IncomeSourcesScreen(),
      ),
      GoRoute(
        path: '/banks',
        name: 'banks',
        builder: (context, state) => const BankAccountsScreen(),
      ),
      GoRoute(
        path: '/notifications',
        name: 'notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}

