import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/auth_selection_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/categories_screen.dart';
import '../screens/transactions/transactions_screen.dart';
import '../screens/bills/bills_screen.dart';
import '../screens/bills/bill_detail_screen.dart';
import '../screens/bills/add_bill_screen.dart';
import '../screens/loans/loans_screen.dart';
import '../screens/loans/loan_detail_screen.dart';
import '../screens/loans/add_loan_screen.dart';
import '../screens/income/income_sources_screen.dart';
import '../screens/income/add_edit_income_source_screen.dart';
import '../screens/bank/bank_accounts_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/settings/profile_screen.dart';
import '../screens/settings/edit_profile_screen.dart';
import '../screens/settings/security_screen.dart';
import '../screens/settings/change_pin_screen.dart';
import '../screens/settings/pin_change_success_screen.dart';
import '../screens/settings/fingerprint_screen.dart';
import '../screens/settings/fingerprint_delete_screen.dart';
import '../screens/settings/fingerprint_delete_success_screen.dart';
import '../screens/settings/terms_conditions_screen.dart';
import '../screens/settings/transaction_categories_screen.dart';
import '../screens/analysis/analysis_screen.dart';
import '../screens/analysis/quick_analysis_screen.dart';
import '../screens/launch_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../services/auth_service.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/launch',
    redirect: (BuildContext context, GoRouterState state) {
      final isLoggedIn = AuthService.isAuthenticated();
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/auth-selection' ||
          state.matchedLocation == '/landing';

      // If user is not logged in and trying to access protected routes
      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/launch') {
        return '/landing';
      }

      // If user is logged in and on auth routes, redirect to home
      if (isLoggedIn && (state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/auth-selection')) {
        return '/';
      }

      // If user is logged in and on landing page, redirect to home
      if (isLoggedIn && state.matchedLocation == '/landing') {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/auth-selection',
        name: 'auth-selection',
        builder: (context, state) => const AuthSelectionScreen(),
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
        path: '/category',
        name: 'category',
        builder: (context, state) => const CategoriesScreen(),
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
        path: '/add-bill',
        name: 'add-bill',
        builder: (context, state) => const AddBillScreen(),
      ),
      GoRoute(
        path: '/loans',
        name: 'loans',
        builder: (context, state) => const LoansScreen(),
      ),
      GoRoute(
        path: '/add-loan',
        name: 'add-loan',
        builder: (context, state) => const AddLoanScreen(),
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
        path: '/income/add',
        name: 'income-add-edit',
        builder: (context, state) => const AddEditIncomeSourceScreen(),
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
        path: '/edit-profile',
        name: 'edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: '/security',
        name: 'security',
        builder: (context, state) => const SecurityScreen(),
      ),
      GoRoute(
        path: '/change-pin',
        name: 'change-pin',
        builder: (context, state) => const ChangePinScreen(),
      ),
      GoRoute(
        path: '/pin-change-success',
        name: 'pin-change-success',
        builder: (context, state) => const PinChangeSuccessScreen(),
      ),
      GoRoute(
        path: '/fingerprint',
        name: 'fingerprint',
        builder: (context, state) => const FingerprintScreen(),
      ),
      GoRoute(
        path: '/fingerprint-delete',
        name: 'fingerprint-delete',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>? ?? {};
          final fingerprintName = args['name'] as String? ?? 'Unknown Fingerprint';
          return FingerprintDeleteScreen(fingerprintName: fingerprintName);
        },
      ),
      GoRoute(
        path: '/fingerprint-delete-success',
        name: 'fingerprint-delete-success',
        builder: (context, state) => const FingerprintDeleteSuccessScreen(),
      ),
      GoRoute(
        path: '/terms-conditions',
        name: 'terms-conditions',
        builder: (context, state) => const TermsConditionsScreen(),
      ),
      GoRoute(
        path: '/analysis',
        name: 'analysis',
        builder: (context, state) => const AnalysisScreen(),
      ),
      GoRoute(
        path: '/quick-analysis',
        name: 'quick-analysis',
        builder: (context, state) => const QuickAnalysisScreen(),
      ),
      GoRoute(
        path: '/launch',
        name: 'launch',
        builder: (context, state) => const LaunchScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/transaction-categories',
        name: 'transaction-categories',
        builder: (context, state) => const TransactionCategoriesScreen(),
      ),
    ],
  );
}

