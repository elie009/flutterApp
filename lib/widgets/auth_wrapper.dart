import 'package:flutter/material.dart';
import '../services/auth_service.dart';

/// A wrapper widget that checks authentication before displaying content
class AuthWrapper extends StatefulWidget {
  final Widget child;
  final VoidCallback? onUnauthenticated;

  const AuthWrapper({
    super.key,
    required this.child,
    this.onUnauthenticated,
  });

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isChecking = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final isAuth = await AuthService.checkAuthAndRedirect(context);
    if (mounted) {
      setState(() {
        _isAuthenticated = isAuth;
        _isChecking = false;
      });

      if (!isAuth && widget.onUnauthenticated != null) {
        widget.onUnauthenticated!();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isChecking) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (!_isAuthenticated) {
      return const Scaffold(
        body: Center(
          child: Text('Redirecting to login...'),
        ),
      );
    }

    return widget.child;
  }
}
