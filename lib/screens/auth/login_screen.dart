import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController(text: 'demo@utilityhub360.com');
  final _passwordController = TextEditingController(text: 'Demo123!');
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Design colors (from provided design)
  static const _lightGreen = AppTheme.primaryColor;
  static const _lightGreenBorder = Color(0xFFB8E6A8);
  static const _textDark = Color(0xFF1a1a1a);
  static const _textGray = Color(0xFF757575);
  static const _borderLight = Color(0xFFE0E0E0);
  static const _white = Color(0xFFFFFFFF);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await AuthService.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      ).timeout(
        const Duration(seconds: 35),
        onTimeout: () => {
          'success': false,
          'message': 'Request timed out. Check your connection and try again.',
        },
      );

      if (result['success'] == true) {
        if (mounted) context.go('/');
      } else {
        if (mounted) {
          final message = result['message'];
          final displayMessage = message is String ? message : 'Login failed';
          debugPrint('🔐 Login failed: $displayMessage');
          NavigationHelper.showSnackBar(context, displayMessage, backgroundColor: Colors.red);
        }
      }
    } catch (e, stackTrace) {
      debugPrint('🔐 Login error: $e');
      debugPrint('$stackTrace');
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Login failed. ${e.toString().replaceFirst('Exception: ', '')}',
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/auth-selection');
          }
        }
      },
      child: Scaffold(
        backgroundColor: _white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  // App logo (square, light green fill, white outline shape in center)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _lightGreen,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _white, width: 2),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Welcome Back
                  const Text(
                    'Welcome Back',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sign in to continue',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: _textGray,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Email field (white bg, light gray border, envelope icon)
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 16, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Email address',
                      hintStyle: TextStyle(color: _textGray, fontSize: 15),
                      prefixIcon: Icon(Icons.mail_outline, color: _textGray, size: 22),
                      filled: true,
                      fillColor: _white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _lightGreen, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your email';
                      if (!v.contains('@')) return 'Please enter a valid email';
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // Password field (padlock + eye)
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    style: const TextStyle(fontSize: 16, color: _textDark),
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: TextStyle(color: _textGray, fontSize: 15),
                      prefixIcon: Icon(Icons.lock_outline, color: _textGray, size: 22),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: _textGray,
                          size: 22,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: _white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _borderLight),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _borderLight),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: _lightGreen, width: 1.5),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Please enter your password';
                      if (v.length < 6) return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),

                  const SizedBox(height: 8),

                  // Forgot Password? (right-aligned, light green)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => context.push('/forgot-password'),
                      child: const Text(
                        'Forgot Password?',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _lightGreen,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign In button (light green, white text, arrow)
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _lightGreen,
                        foregroundColor: _white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(strokeWidth: 2, color: _white),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 17,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                    ),
                  ),

                  if (BiometricService.isMobile) ...[
                    const SizedBox(height: 28),
                    // Biometric and PIN icon buttons (side by side)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _IconActionButton(
                          icon: Icons.fingerprint_rounded,
                          onTap: () async {
                            final ok = await BiometricService.authenticate(reason: 'Log in to UtilityHub360');
                            if (!mounted) return;
                            if (!ok) {
                              NavigationHelper.showSnackBar(
                                context,
                                'Biometric authentication failed or was cancelled',
                                backgroundColor: Colors.orange,
                              );
                              return;
                            }
                            final restored = await AuthService.restoreSessionFromStorage();
                            if (!mounted) return;
                            if (restored) {
                              NavigationHelper.showSnackBar(context, 'Welcome back!', backgroundColor: _lightGreen);
                              context.go('/');
                            } else {
                              NavigationHelper.showSnackBar(
                                context,
                                'No saved session. Please log in with email/password first.',
                                backgroundColor: Colors.orange,
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 20),
                        _IconActionButton(
                          icon: Icons.key_rounded,
                          onTap: () => context.push('/pin-login'),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 32),

                  // Or continue with (divider + text)
                  Row(
                    children: [
                      Expanded(child: Divider(color: _borderLight, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 13,
                            color: _textGray,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: _borderLight, thickness: 1)),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Google and Facebook buttons (white, light green border)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Google login
                          },
                          icon: Icon(Icons.g_mobiledata_rounded, color: _lightGreen, size: 24),
                          label: const Text(
                            'Google',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _lightGreenBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Facebook login
                          },
                          icon: Icon(Icons.facebook_rounded, color: _lightGreen, size: 24),
                          label: const Text(
                            'Facebook',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: _lightGreenBorder),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Don't have an account? Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          color: _textGray,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/register'),
                        child: const Text(
                          'Sign Up',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _lightGreen,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Small square button with icon (for biometric / PIN).
class _IconActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconActionButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 28, color: const Color(0xFF1a1a1a)),
        ),
      ),
    );
  }
}
