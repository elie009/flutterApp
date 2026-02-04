import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement password reset logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent!'),
          backgroundColor: Color(0xFFb3ee9a),
        ),
      );
      // Navigate to security pin screen after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.push('/security-pin');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Navigate back to login instead of closing app
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
                  context.go('/login');
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
                  'Forgot Password',
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
              top: 117,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3), // Background Green White and Letters
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

                        // Description text
                        const Text(
                          'Enter your email address and we\'ll send you a link to reset your password.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'League Spartan',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Color(0xFF0E3E3E), // Dark Mode Green bar
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Email label
                        Container(
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.only(left: 29, bottom: 8),
                          child: const Text(
                            'Enter email address',
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
                                return 'Please enter your email address';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Reset Password Button
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
                              onPressed: _handleResetPassword,
                              child: const Text(
                                'Next Step',
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

                        const SizedBox(height: 130),

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

                        // Back to Login Link
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
                                color: Color(0xFF093030), // Default color for normal text
                              ),
                              children: const [
                                TextSpan(
                                  text: "Remember your password? ",
                                ),
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: Colors.blue, // Blue color for "Sign In"
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
