import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';
import '../utils/theme.dart';

/// Widget that guards protected routes and ensures user is authenticated
/// Automatically redirects to login if session expires
class AuthGuard extends StatefulWidget {
  final Widget child;
  final bool checkSessionPeriodically;
  
  const AuthGuard({
    super.key,
    required this.child,
    this.checkSessionPeriodically = true,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> with WidgetsBindingObserver {
  bool _isCheckingAuth = true;
  bool _isAuthenticated = false;

  /// Last time back was pressed (for "press back again to exit").
  static DateTime? _lastBackPressTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAuthentication();
    
    // Add session expired callback
    if (widget.checkSessionPeriodically) {
      SessionManager.addSessionExpiredCallback(_onSessionExpired);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SessionManager.removeSessionExpiredCallback(_onSessionExpired);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Check auth when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      debugPrint('🔄 AuthGuard: App resumed, checking authentication');
      _checkAuthentication();
    }
  }

  /// Check if user is authenticated
  Future<void> _checkAuthentication() async {
    debugPrint('🔐 AuthGuard: Checking authentication');
    
    // Check if user is authenticated
    final isAuth = AuthService.isAuthenticated();
    
    if (!isAuth) {
      debugPrint('❌ AuthGuard: User not authenticated, redirecting to login');
      if (mounted) {
        context.go('/landing');
      }
      return;
    }
    
    // Verify session is valid
    final isSessionValid = await SessionManager.checkSessionValidity();
    
    if (!isSessionValid) {
      debugPrint('❌ AuthGuard: Session invalid, redirecting to login');
      if (mounted) {
        context.go('/landing');
      }
      return;
    }
    
    debugPrint('✅ AuthGuard: Authentication valid');
    
    if (mounted) {
      setState(() {
        _isAuthenticated = true;
        _isCheckingAuth = false;
      });
    }
  }

  /// Sub-routes that should go to a parent when back is pressed (app uses go() so canPop is often false).
  static const Map<String, String> _backParentRoutes = {
    '/security': '/profile',
    '/change-pin': '/profile',
    '/pin-change-success': '/profile',
    '/edit-profile': '/profile',
    '/fingerprint': '/profile',
    '/fingerprint-delete': '/fingerprint',
    '/fingerprint-delete-success': '/profile',
    '/terms-conditions': '/profile',
    '/notifications': '/',
    '/quick-analysis': '/analysis',
    '/add-bill': '/bills',
    '/income/add': '/income',
    '/transaction-categories': '/category',
  };

  /// When at root (nothing to pop), first back shows message, second back within 2s exits app.
  /// For sub-routes opened with go(), navigate to parent so back feels correct.
  void _onBackPressed(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    final location = GoRouterState.of(context).matchedLocation;
    String? parent = _backParentRoutes[location];
    if (parent == null && location.startsWith('/bills/')) parent = '/bills';
    if (parent == null && location.startsWith('/loans/')) parent = '/loans';
    if (parent != null) {
      context.go(parent);
      return;
    }
    final now = DateTime.now();
    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!).inMilliseconds < 2000) {
      SystemNavigator.pop();
      return;
    }
    _lastBackPressTime = now;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Press back again to exit'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Handle session expiration
  void _onSessionExpired() {
    debugPrint('🔒 AuthGuard: Session expired callback triggered');
    if (mounted) {
      // Show a snackbar or dialog
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Your session has expired. Please login again.'),
          duration: Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
      
      // Redirect to login
      context.go('/landing');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      // Show loading while checking auth
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      // This shouldn't happen as we redirect in _checkAuthentication
      // but just in case, show loading
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // User is authenticated; wrap with PopScope so back button doesn't exit immediately
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        if (!mounted) return;
        _onBackPressed(context);
      },
      child: widget.child,
    );
  }
}
