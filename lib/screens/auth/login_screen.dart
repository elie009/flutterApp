import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';

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

  @override
  void initState() {
    super.initState();
    AuthService.init();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      if (mounted) {
        context.go('/category');
      }
    } else {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          result['message'] as String,
          backgroundColor: Colors.red,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF00D09E), // Main Green background
        child: Stack(
          children: [
            // Status Bar Mockup (Top)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 32,
              child: Container(
                color: const Color(0xFF00D09E),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Time
                    const Text(
                      '16:04',
                      style: TextStyle(
                        fontFamily: 'League Spartan',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 12 / 13,
                      ),
                    ),
                    // Status Icons
                    Row(
                      children: [
                        // WiFi/Network
                        Container(
                          width: 13,
                          height: 11,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        // Battery
                        Container(
                          width: 15,
                          height: 8,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 2),
                            borderRadius: BorderRadius.circular(58),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Signal Bars
                        Container(
                          width: 17,
                          height: 9,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(1),
                          ),
                          child: Container(
                            width: 12,
                            height: 7,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Card (Base Shape)
            Positioned(
              top: 187,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3), // Background Green White and Letters
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(40),
                    topRight: Radius.circular(40),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 76), // Space for Welcome title positioning

                        // Welcome Title
                        const Text(
                          'Welcome',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                            height: 22 / 30, // 73% line height
                            color: Color(0xFF093030), // Letters and Icons
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Username or email label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Username or email',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Email Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              hintText: 'example@example.com',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 14 / 16, // 88% line height
                                color: Color(0xFF093030).withOpacity(0.45), // Letters and Icons
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Password label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Password',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              height: 22 / 15,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        // Password Input Field
                        Container(
                          width: 356,
                          height: 41,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a1a1a),
                            ),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                height: 14 / 12, // 117% line height
                                color: const Color(0xFF0E3E3E).withOpacity(0.45), // Dark Mode Green bar
                                letterSpacing: 4.2, // 0.7em spacing
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: Color(0xFF0E3E3E).withOpacity(0.6),
                                  size: 24,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 60),

                        // Forgot Password Link
                        const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 13 / 14,
                            color: Color(0xFF093030), // Letters and Icons
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Login Button
                        if (_isLoading)
                          const CircularProgressIndicator(
                            color: Color(0xFF00D09E),
                          )
                        else
                          Container(
                            width: 207,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E), // Main Green
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
                                  height: 22 / 20, // 110% line height
                                  color: Color(0xFF093030), // Letters and Icons
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 50),

                        // Alternative Login Button
                        Container(
                          width: 207,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () {
                              // TODO: Implement biometric login
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Biometric login coming soon!'),
                                  backgroundColor: Color(0xFF00D09E),
                                ),
                              );
                            },
                            child: const Text(
                              'Log In',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                height: 22 / 20,
                                color: Color(0xFF0E3E3E), // Dark Mode Green bar
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Use fingerprint to access
                        const Text(
                          'Use fingerprint to access',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 22 / 14, // 157% line height
                            color: Color(0xFF0E3E3E), // Dark Mode Green bar
                          ),
                        ),

                        const SizedBox(height: 40),

                        // or sign up with
                        const Text(
                          'or sign up with',
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            height: 15 / 13, // 115% line height
                            color: Color(0xFF093030), // Letters and Icons
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
                                  color: const Color(0xFF0E3E3E), // Dark Mode Green bar
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
                                  color: const Color(0xFF0E3E3E), // Dark Mode Green bar
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

                        const SizedBox(height: 140),

                        // Don't have an account? Sign Up
                        const Text(
                          "Don't have an account? Sign Up",
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 13,
                            fontWeight: FontWeight.w300,
                            height: 15 / 13, // 115% line height
                            color: Color(0xFF093030), // Letters and Icons
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

