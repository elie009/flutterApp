import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/launch/splash_screen.dart';
import '../screens/launch/launch_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/reset_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/bills/bill_detail_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/loans/loan_detail_screen.dart';
import '../screens/loans/apply_loan_screen.dart';
import '../screens/income/income_sources_screen.dart';
import '../screens/bank/bank_accounts_screen.dart';
import '../screens/category/category_screen.dart';
import '../screens/analytics/analytics_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/savings/savings_categories_screen.dart';
import '../screens/savings/savings_account_detail_screen.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../utils/navigation_helper.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) async {
      // Allow splash and launch screens without authentication
      final isPublicRoute = state.matchedLocation == '/splash' ||
          state.matchedLocation == '/launch' ||
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');

      // If going to splash and already logged in, skip to dashboard
      if (state.matchedLocation == '/splash') {
        final token = await StorageService.getToken();
        if (token != null) {
          final isLoggedIn = await AuthService.isAuthenticated();
          if (isLoggedIn) {
            return '/category';
          }
        }
      }

      if (isPublicRoute) {
        return null; // Allow access to public routes
      }

      // Check authentication for protected routes
      final token = await StorageService.getToken();
      final hasToken = token != null;
      final isLoggedIn = await AuthService.isAuthenticated();
      final isLoginRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/forgot-password' ||
          state.matchedLocation.startsWith('/reset-password');

      if (!isLoggedIn && !isLoginRoute) {
        return '/launch'; // Redirect to launch screen if not logged in
      }
      if (isLoggedIn && isLoginRoute) {
        return '/category';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/launch',
        name: 'launch',
        builder: (context, state) => const LaunchScreen(),
      ),
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
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        name: 'reset-password',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          final email = state.uri.queryParameters['email'];
          return ResetPasswordScreen(
            token: token,
            email: email,
          );
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/analytics',
        name: 'analytics',
        builder: (context, state) => const AnalyticsScreen(),
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
        path: '/loans/apply',
        name: 'loan-apply',
        builder: (context, state) => const ApplyLoanScreen(),
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
        path: '/category',
        name: 'category',
        builder: (context, state) => const CategoryScreen(),
      ),
      GoRoute(
        path: '/savings',
        name: 'savings',
        builder: (context, state) => const SavingsCategoriesScreen(),
      ),
      GoRoute(
        path: '/savings/:id',
        name: 'savings-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return SavingsAccountDetailScreen(savingsAccountId: id);
        },
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

