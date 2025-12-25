import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _navigateToNextStep() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement password reset logic
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent!')),
      );
      // Navigate to reset password screen or back to login
      Navigator.of(context).pop();
    }
  }

  void _navigateToSignUp() {
    Navigator.of(context).pushReplacementNamed('register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFF00D09E),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          children: [
            // Status bar
            Positioned(
              left: 0,
              top: 0,
              child: Container(
                width: 430,
                height: 32,
                decoration: const BoxDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      left: 37,
                      top: 9,
                      child: SizedBox(
                        width: 30,
                        height: 14,
                        child: Text(
                          '16:04',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Title
            const Positioned(
              left: 88,
              top: 100,
              child: Text(
                'Forgot Password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 30,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 0.73,
                ),
              ),
            ),

            // Reset password subtitle
            const Positioned(
              left: 35,
              top: 277,
              child: Text(
                'reset password?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0E3E3E),
                  fontSize: 20,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                  height: 1.10,
                ),
              ),
            ),

            // Description text
            const Positioned(
              left: 35,
              top: 313,
              child: SizedBox(
                width: 359,
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                  style: TextStyle(
                    color: Color(0xFF0E3E3E),
                    fontSize: 14,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Email label
            const Positioned(
              left: 37,
              top: 421,
              child: Text(
                'Enter email address',
                style: TextStyle(
                  color: Color(0xFF093030),
                  fontSize: 15,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Email input field
            Positioned(
              left: 37,
              top: 452,
              child: Container(
                width: 356,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'example@example.com',
                      hintStyle: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w400,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 19, vertical: 10),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                ),
              ),
            ),

            // Next step button
            Positioned(
              left: 131,
              top: 538,
              child: GestureDetector(
                onTap: _navigateToNextStep,
                child: Container(
                  width: 169,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Next step',
                    style: TextStyle(
                      color: Color(0xFF093030),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ),

            // Sign Up button
            Positioned(
              left: 130,
              top: 690,
              child: GestureDetector(
                onTap: _navigateToSignUp,
                child: Container(
                  width: 169,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDFF7E2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      color: Color(0xFF0E3E3E),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ),

            // "or sign up with" text
            const Positioned(
              left: 156,
              top: 740,
              child: SizedBox(
                width: 119,
                height: 11,
                child: Text(
                  'or sign up with',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 13,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w300,
                    height: 1.15,
                  ),
                ),
              ),
            ),

            // Social login icons
            Positioned(
              left: 172,
              top: 769,
              child: Container(
                width: 32.71,
                height: 32.65,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.g_mobiledata, // Placeholder for Google icon
                  color: Colors.red,
                  size: 20,
                ),
              ),
            ),

            Positioned(
              left: 222,
              top: 769,
              child: Container(
                width: 32.71,
                height: 32.71,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.facebook, // Facebook icon
                  color: Colors.blue,
                  size: 20,
                ),
              ),
            ),

            // Bottom text
            Positioned(
              left: 79,
              top: 822,
              child: GestureDetector(
                onTap: _navigateToSignUp,
                child: const SizedBox(
                  width: 273,
                  height: 28,
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 13,
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                        TextSpan(
                          text: 'Sign Up',
                          style: TextStyle(
                            color: Color(0xFF3299FF),
                            fontSize: 13,
                            fontFamily: 'League Spartan',
                            fontWeight: FontWeight.w300,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
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

