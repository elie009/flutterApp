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
    // AuthService is already initialized in main.dart
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
        context.go('/');
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
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Navigate to landing or auth-selection instead of closing app
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/auth-selection');
          }
        }
      },
      child: Scaffold(
        body: Container(
        width: double.infinity,
        height: double.infinity,
        color: const Color(0xFF00D09E), // Main Green background
        child: Stack(
          children: [
                 


            // The SizedBox and Center are currently just in the Stack's children,
            // so if later widgets (like the Positioned container) cover the whole area, 
            // they will overlap or obscure this welcome text. 
            // To ensure it stays visible, you might want to give it a higher position in the Stack,
            // or place it *inside* the top Card (not outside it).
            // Here's a suggestion to make it more visible by using Positioned:

            Positioned(
              top: 50,
              left: 0, right: 0,
              child: Center(
                child: Text(
                  'Welcome',
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


            // Main Content Card (Base Shape)
            Positioned(
              top: 150,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF), // Background Green White and Letters
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [

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
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
                              hintText: 'example@example.com',
                              hintStyle: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 14 / 16,
                                color: Color(0xFF093030).withOpacity(0.45),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                        const SizedBox(height: 20),

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
                              filled: true,
                              fillColor: const Color(0xFFDFF7E2),
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
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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

                        const SizedBox(height: 10),
                        // Forgot Password Link
                        GestureDetector(
                          onTap: () {
                            context.push('/forgot-password');
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontFamily: 'League Spartan',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 13 / 14,
                              color: Color(0xFF093030), // Letters and Icons
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                        // Sign Up Button
                        Container(
                          width: 207,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () {
                              context.go('/register');
                            },
                            child: const Text(
                              'Sign Up',
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

                        // Login with PIN button
                        GestureDetector(
                          onTap: () {
                            context.push('/pin-login');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 22 / 14,
                                color: Color(0xFF0E3E3E),
                              ),
                              children: const [
                                TextSpan(text: 'Use '),
                                TextSpan(
                                  text: 'PIN',
                                  style: TextStyle(
                                    color: Colors.blue,
                                  ),
                                ),
                                TextSpan(text: ' to login'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Use fingerprint to access
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 22 / 14, // 157% line height
                              color: Color(0xFF0E3E3E), // Default color
                            ),
                            children: const [
                              TextSpan(text: 'Use '),
                              TextSpan(
                                text: 'fingerprint',
                                style: TextStyle(
                                  color: Colors.blue, // Change 'fingerprint' to blue
                                ),
                              ),
                              TextSpan(text: ' to access'),
                            ],
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

                        const SizedBox(height: 50),

                        // Don't have an account? Sign Up
                        GestureDetector(
                          onTap: () {
                            context.go('/register');
                          },
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontFamily: 'League Spartan',
                                fontSize: 13,
                                fontWeight: FontWeight.w300,
                                height: 15 / 13,
                                color: Color(0xFF093030), // Default color for normal text
                              ),
                              children: const [
                                TextSpan(
                                  text: "Don't have an account? ",
                                ),
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    color: Colors.blue, // Blue color for "Sign Up"
                                    fontWeight: FontWeight.w300,
                                  ),
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
            ),
          ],
        ),
      ),
      ),
    );
  }
}

