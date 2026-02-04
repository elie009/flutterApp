import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _obscurePin = true;
  static const String _pinKey = 'user_pin';

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  Future<void> _checkPinExists() async {
    final pin = StorageService.getString(_pinKey);
    if (pin == null || pin.isEmpty) {
      // No PIN set, redirect to login screen
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Please set up a PIN first by logging in with email/password',
          backgroundColor: Colors.orange,
        );
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            context.go('/login');
          }
        });
      }
    }
  }

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    // Auto-submit when all 6 digits are entered
    if (index == 5 && value.isNotEmpty) {
      final pin = _getPin();
      if (pin.length == 6) {
        _handleLogin();
      }
    }
  }

  String _getPin() {
    return _pinControllers.map((controller) => controller.text).join();
  }

  void _clearPin() {
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _handleLogin() async {
    final enteredPin = _getPin();
    if (enteredPin.length != 6) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter all 6 digits',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Verify PIN against stored PIN
    final storedPin = StorageService.getString(_pinKey);
    
    // Simulate a small delay for security
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    if (storedPin == enteredPin) {
      await _onUnlockSuccess();
    } else {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Incorrect PIN. Please try again.',
          backgroundColor: Colors.red,
        );
        _clearPin();
      }
    }
  }

  void _togglePinVisibility() {
    setState(() {
      _obscurePin = !_obscurePin;
    });
  }

  /// Called after PIN or biometric success: restore session and navigate to dashboard.
  Future<void> _onUnlockSuccess() async {
    final restored = await AuthService.restoreSessionFromStorage();
    if (!mounted) return;
    if (restored) {
      NavigationHelper.showSnackBar(
        context,
        'Welcome back!',
        backgroundColor: const Color(0xFFb3ee9a),
      );
      context.go('/');
    } else {
      NavigationHelper.showSnackBar(
        context,
        'No saved session. Please log in with email/password.',
        backgroundColor: Colors.orange,
      );
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
            context.go('/login');
          }
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xFFb3ee9a), // Main Green background
          child: Stack(
            children: [
              // Back Button
              Positioned(
                top: 50,
                left: 24,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF093030),
                  ),
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/login');
                    }
                  },
                ),
              ),

              // Title
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Enter PIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                      height: 22 / 15,
                      color: Color(0xFF093030),
                    ),
                  ),
                ),
              ),

              // Main Content Card
              Positioned(
                top: 150,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFFFFF), // Background Green White
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 30),

                        // Lock Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline,
                            size: 40,
                            color: Color(0xFFb3ee9a),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Description text
                        const Text(
                          'Enter your 6-digit PIN to login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Color(0xFF0E3E3E), // Dark Mode Green bar
                          ),
                        ),

                        const SizedBox(height: 10),

                        // PIN Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 45,
                              height: 45,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF7E2), // Light Green
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _focusNodes[index].hasFocus
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: TextField(
                                controller: _pinControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                obscureText: _obscurePin,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF093030),
                                ),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFDFF7E2),
                                  counterText: '',
                                  contentPadding: EdgeInsets.zero,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(18),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                onChanged: (value) => _onPinChanged(index, value),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Toggle PIN Visibility
                        GestureDetector(
                          onTap: _togglePinVisibility,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _obscurePin
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: const Color(0xFF0E3E3E).withOpacity(0.6),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _obscurePin ? 'Show PIN' : 'Hide PIN',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF0E3E3E).withOpacity(0.6),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Login Button
                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: Color(0xFFb3ee9a),
                          )
                        else
                          Container(
                            width: 207,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFb3ee9a), // Main Green
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextButton(
                              onPressed: _handleLogin,
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  height: 22 / 20,
                                  color: Color(0xFF093030),
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Clear PIN Button
                        Container(
                          width: 207,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: _clearPin,
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 22 / 20,
                                color: Color(0xFF0E3E3E),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Forgot PIN Link
                        GestureDetector(
                          onTap: () {
                            context.push('/forgot-password');
                          },
                          child: const Text(
                            'Forgot PIN?',
                            style: TextStyle(
                              fontFamily: 'League Spartan',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 13 / 14,
                              color: Color(0xFF093030),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Mobile only: Use fingerprint/face to access
                        if (BiometricService.isMobile) ...[
                          GestureDetector(
                            onTap: () async {
                              final authenticated = await BiometricService.authenticate(
                                reason: 'Log in to UtilityHub360',
                              );
                              if (!mounted) return;
                              if (authenticated) {
                                await _onUnlockSuccess();
                              } else {
                                NavigationHelper.showSnackBar(
                                  context,
                                  'Biometric authentication failed or was cancelled',
                                  backgroundColor: Colors.orange,
                                );
                              }
                            },
                            child: RichText(
                              text: const TextSpan(
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 22 / 14,
                                  color: Color(0xFF0E3E3E),
                                ),
                                children: [
                                  TextSpan(text: 'Use '),
                                  TextSpan(
                                    text: 'fingerprint or face',
                                    style: TextStyle(
                                      color: Colors.blue,
                                    ),
                                  ),
                                  TextSpan(text: ' to access'),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                        ],

                        // or sign in with
                        const Text(
                          'or sign in with',
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            height: 15 / 13,
                            color: Color(0xFF093030),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Social Login Buttons
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Facebook Button
                            Container(
                              width: 32.71,
                              height: 32.65,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF0E3E3E),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.facebook,
                                  color: Color(0xFF0E3E3E),
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Implement Facebook login
                                },
                              ),
                            ),
                            const SizedBox(width: 20),
                            // Google Button
                            Container(
                              width: 32.71,
                              height: 32.71,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xFF0E3E3E),
                                  width: 1.3,
                                ),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.g_mobiledata,
                                  color: Color(0xFF0E3E3E),
                                  size: 20,
                                ),
                                onPressed: () {
                                  // TODO: Implement Google login
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 50),

                        // Login with Email/Password Link
                        GestureDetector(
                          onTap: () {
                            context.go('/login');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                height: 15 / 13,
                                color: Color(0xFF093030),
                              ),
                              children: const [
                                TextSpan(
                                  text: "Use ",
                                ),
                                TextSpan(
                                  text: "Email & Password",
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: " instead",
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

