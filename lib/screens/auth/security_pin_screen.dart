import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SecurityPinScreen extends StatefulWidget {
  const SecurityPinScreen({super.key});

  @override
  State<SecurityPinScreen> createState() => _SecurityPinScreenState();
}

class _SecurityPinScreenState extends State<SecurityPinScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;

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

  void _onPinChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  String _getPin() {
    return _pinControllers.map((controller) => controller.text).join();
  }

  Future<void> _handleAccept() async {
    final pin = _getPin();
    if (pin.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter all 6 digits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement pin verification logic
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pin verified successfully!'),
          backgroundColor: Color(0xFF00D09E),
        ),
      );
      // Navigate to next screen or back
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.go('/login');
        }
      });
    }
  }

  Future<void> _handleSendAgain() async {
    // Clear all pin fields
    for (var controller in _pinControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();

    // TODO: Implement resend pin logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pin code sent again!'),
        backgroundColor: Color(0xFF00D09E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          // Navigate back instead of closing app
          if (context.canPop()) {
            context.pop();
          } else {
            context.go('/forgot-password');
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
                      context.go('/forgot-password');
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
                    'Security Pin',
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),

                        // Description text
                        const Text(
                          'Enter the 6-digit security pin sent to your email',
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

                        // Pin Input Fields
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
                              ),
                              child: TextField(
                                controller: _pinControllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
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
                                    borderSide: BorderSide(
                                      color: const Color(0xFF00D09E),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) => _onPinChanged(index, value),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 50),

                        // Accept Button
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
                              onPressed: _handleAccept,
                              child: const Text(
                                'Accept',
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

                        const SizedBox(height: 20),

                        // Send Again Button
                        Container(
                          width: 207,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: _handleSendAgain,
                            child: const Text(
                              'Send Again',
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

                        const SizedBox(height: 50),

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
            ],
          ),
        ),
      ),
    );
  }
}

