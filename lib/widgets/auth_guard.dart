import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

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

    // User is authenticated, show the protected screen
    return widget.child;
  }
}
