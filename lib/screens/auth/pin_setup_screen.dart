import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final List<TextEditingController> _pinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<TextEditingController> _confirmPinControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  final List<FocusNode> _confirmPinFocusNodes = List.generate(
    6,
    (index) => FocusNode(),
  );
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _showConfirmPin = false;
  static const String _pinKey = 'user_pin';

  @override
  void dispose() {
    for (var controller in _pinControllers) {
      controller.dispose();
    }
    for (var controller in _confirmPinControllers) {
      controller.dispose();
    }
    for (var node in _pinFocusNodes) {
      node.dispose();
    }
    for (var node in _confirmPinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onPinChanged(int index, String value, bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    final focusNodes = isConfirm ? _confirmPinFocusNodes : _pinFocusNodes;

    if (value.isNotEmpty && index < 5) {
      focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      focusNodes[index - 1].requestFocus();
    }

    // Auto-move to confirm PIN when all 6 digits are entered
    if (!isConfirm && index == 5 && value.isNotEmpty) {
      final pin = _getPin(false);
      if (pin.length == 6) {
        setState(() {
          _showConfirmPin = true;
        });
        Future.delayed(const Duration(milliseconds: 100), () {
          _confirmPinFocusNodes[0].requestFocus();
        });
      }
    }

    // Auto-submit when confirm PIN is complete
    if (isConfirm && index == 5 && value.isNotEmpty) {
      final confirmPin = _getPin(true);
      if (confirmPin.length == 6) {
        _handleSetPin();
      }
    }
  }

  String _getPin(bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    return controllers.map((controller) => controller.text).join();
  }

  void _clearPin(bool isConfirm) {
    if (isConfirm) {
      for (var controller in _confirmPinControllers) {
        controller.clear();
      }
      _confirmPinFocusNodes[0].requestFocus();
    } else {
      for (var controller in _pinControllers) {
        controller.clear();
      }
      _pinFocusNodes[0].requestFocus();
    }
  }

  Future<void> _handleSetPin() async {
    final pin = _getPin(false);
    final confirmPin = _getPin(true);

    if (pin.length != 6) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter all 6 digits for PIN',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (confirmPin.length != 6) {
      NavigationHelper.showSnackBar(
        context,
        'Please confirm your PIN',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (pin != confirmPin) {
      NavigationHelper.showSnackBar(
        context,
        'PINs do not match. Please try again.',
        backgroundColor: Colors.red,
      );
      _clearPin(true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    // Save PIN to storage
    await StorageService.saveString(_pinKey, pin);
    
    // Simulate a small delay
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      NavigationHelper.showSnackBar(
        context,
        'PIN set successfully!',
        backgroundColor: const Color(0xFFb3ee9a),
      );
      // Navigate back to settings or security screen
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          context.pop();
        }
      });
    }
  }

  void _togglePinVisibility() {
    setState(() {
      _obscurePin = !_obscurePin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
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
                  onPressed: () => context.pop(),
                ),
              ),

              // Title
              Positioned(
                top: 50,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Set PIN',
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
                    color: Color(0xFFF1FFF3), // Background Green White
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
                        const SizedBox(height: 40),

                        // Lock Icon
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_open_outlined,
                            size: 40,
                            color: Color(0xFFb3ee9a),
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Description text
                        Text(
                          _showConfirmPin ? 'Confirm your 6-digit PIN' : 'Create a 6-digit PIN',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                            color: Color(0xFF093030),
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'This PIN will be used for quick login',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            height: 1.5,
                            color: Color(0xFF0E3E3E),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // PIN Input Fields
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            6,
                            (index) => Container(
                              width: 50,
                              height: 50,
                              margin: const EdgeInsets.symmetric(horizontal: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDFF7E2), // Light Green
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: _pinFocusNodes[index].hasFocus
                                      ? const Color(0xFFb3ee9a)
                                      : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: TextField(
                                controller: _pinControllers[index],
                                focusNode: _pinFocusNodes[index],
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
                                onChanged: (value) => _onPinChanged(index, value, false),
                              ),
                            ),
                          ),
                        ),

                        if (_showConfirmPin) ...[
                          const SizedBox(height: 40),

                          // Confirm PIN Label
                          const Text(
                            'Confirm PIN',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              height: 1.5,
                              color: Color(0xFF093030),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Confirm PIN Input Fields
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              6,
                              (index) => Container(
                                width: 50,
                                height: 50,
                                margin: const EdgeInsets.symmetric(horizontal: 6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFF7E2), // Light Green
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(
                                    color: _confirmPinFocusNodes[index].hasFocus
                                        ? const Color(0xFFb3ee9a)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: TextField(
                                  controller: _confirmPinControllers[index],
                                  focusNode: _confirmPinFocusNodes[index],
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
                                  onChanged: (value) => _onPinChanged(index, value, true),
                                ),
                              ),
                            ),
                          ),
                        ],

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

                        const SizedBox(height: 50),

                        // Set PIN Button
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
                              onPressed: _handleSetPin,
                              child: const Text(
                                'Set PIN',
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

                        // Clear Button
                        Container(
                          width: 207,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2), // Light Green
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: TextButton(
                            onPressed: () {
                              if (_showConfirmPin) {
                                setState(() {
                                  _showConfirmPin = false;
                                });
                                _clearPin(true);
                                _pinFocusNodes[0].requestFocus();
                              } else {
                                _clearPin(false);
                              }
                            },
                            child: Text(
                              _showConfirmPin ? 'Back' : 'Clear',
                              style: const TextStyle(
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

                        // Security Tips
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDFF7E2).withOpacity(0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Security Tips:',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF093030),
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                '• Don\'t use obvious PINs like 123456',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF0E3E3E),
                                ),
                              ),
                              Text(
                                '• Don\'t share your PIN with anyone',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF0E3E3E),
                                ),
                              ),
                              Text(
                                '• Choose a PIN you can remember',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF0E3E3E),
                                ),
                              ),
                            ],
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

