import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';
class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _isLoading = false;
  bool _showCurrentPin = false;
  bool _showNewPin = false;
  bool _showConfirmPin = false;

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    super.dispose();
  }

  Future<void> _changePin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check if new PIN and confirm PIN match
    if (_newPinController.text != _confirmPinController.text) {
      NavigationHelper.showSnackBar(
        context,
        'New PIN and confirm PIN do not match',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // TODO: Implement PIN change logic with backend
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    setState(() {
      _isLoading = false;
    });

    // Navigate to success screen
    Navigator.of(context).pushReplacementNamed('pin-change-success');
  }

  String _getPinDots(String pin) {
    if (pin.isEmpty) return '';
    return '●' * pin.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
        ),
        child: Stack(
          children: [
         
            // Small top-right triangle
            Positioned.fill(
              child: Transform.rotate(
                angle: 0.4,
                child: CustomPaint(
                  painter: TrianglePainter(),
                ),
              ),
            ),

         
            // White bottom section
            Positioned(
              left: 0,
              top: 176,
              width: 413,
              height: 800,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
              ),
            ),

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/profile');
                  }
                },
                child: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFFF1FFF3),
                  size: 19,
                ),
              ),
            ),

            // Title "Profile"
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Center(
                child: Text(
                  'Change Pin',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Current PIN field background
            Positioned(
              left: 37,
              top: 287,
              child: Container(
                width: 356,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Invisible text field for input
                    Positioned.fill(
                      child: TextFormField(
                        controller: _currentPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: !_showCurrentPin,
                        style: const TextStyle(color: Colors.transparent),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter current PIN';
                          }
                          if (value.length != 4) {
                            return 'PIN must be 4 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Visible dots or text
                    Positioned(
                      left: 21,
                      top: 14,
                      child: SizedBox(
                        width: 293,
                        child: Opacity(
                          opacity: 0.45,
                          child: Text(
                            _showCurrentPin
                                ? _currentPinController.text
                                : _getPinDots(_currentPinController.text),
                            style: const TextStyle(
                              color: Color(0xFF0E3E3E),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.17,
                              letterSpacing: 8.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Eye icon
                    Positioned(
                      right: 12,
                      top: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showCurrentPin = !_showCurrentPin;
                          });
                        },
                        child: Icon(
                          _showCurrentPin ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF0E3E3E),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // New PIN field background
            Positioned(
              left: 37,
              top: 401,
              child: Container(
                width: 356,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Invisible text field for input
                    Positioned.fill(
                      child: TextFormField(
                        controller: _newPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: !_showNewPin,
                        style: const TextStyle(color: Colors.transparent),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter new PIN';
                          }
                          if (value.length != 4) {
                            return 'PIN must be 4 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Visible dots or text
                    Positioned(
                      left: 21,
                      top: 14,
                      child: SizedBox(
                        width: 293,
                        child: Opacity(
                          opacity: 0.45,
                          child: Text(
                            _showNewPin
                                ? _newPinController.text
                                : _getPinDots(_newPinController.text),
                            style: const TextStyle(
                              color: Color(0xFF0E3E3E),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.17,
                              letterSpacing: 8.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Eye icon
                    Positioned(
                      right: 12,
                      top: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showNewPin = !_showNewPin;
                          });
                        },
                        child: Icon(
                          _showNewPin ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF0E3E3E),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Confirm PIN field background
            Positioned(
              left: 37,
              top: 517,
              child: Container(
                width: 356,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [
                    // Invisible text field for input
                    Positioned.fill(
                      child: TextFormField(
                        controller: _confirmPinController,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        obscureText: !_showConfirmPin,
                        style: const TextStyle(color: Colors.transparent),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          counterText: '',
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm new PIN';
                          }
                          if (value.length != 4) {
                            return 'PIN must be 4 digits';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Visible dots or text
                    Positioned(
                      left: 21,
                      top: 14,
                      child: SizedBox(
                        width: 293,
                        child: Opacity(
                          opacity: 0.45,
                          child: Text(
                            _showConfirmPin
                                ? _confirmPinController.text
                                : _getPinDots(_confirmPinController.text),
                            style: const TextStyle(
                              color: Color(0xFF0E3E3E),
                              fontSize: 12,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              height: 1.17,
                              letterSpacing: 8.40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Eye icon
                    Positioned(
                      right: 12,
                      top: 16,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _showConfirmPin = !_showConfirmPin;
                          });
                        },
                        child: Icon(
                          _showConfirmPin ? Icons.visibility : Icons.visibility_off,
                          color: const Color(0xFF0E3E3E),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Field labels
            Positioned(
              left: 37,
              top: 267.5,
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: const Text(
                  'Current Pin',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 37,
              top: 381.5,
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: const Text(
                  'New Pin',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 38,
              top: 497.5,
              child: Transform.translate(
                offset: const Offset(0, -10),
                child: const Text(
                  'Confirm Pin',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 15,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

            // Change PIN button
            Positioned(
              left: 106,
              top: 593,
              child: GestureDetector(
                onTap: _isLoading ? null : _changePin,
                child: Container(
                  width: 218,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFb3ee9a),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF093030)),
                          ),
                        )
                      : const Text(
                          'Change Pin',
                          style: TextStyle(
                            color: Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 51,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications,
                    color: Color(0xFF093030),
                    size: 21,
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
