import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  static const _lightGreen = AppTheme.primaryColor;
  static const _lightGreenBg = Color(0xFFDFF7E2);
  static const _headerDark = Color(0xFF093030);
  static const _textMuted = Color(0xFF0E3E3E);

  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<TextEditingController> _confirmPinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());
  final List<FocusNode> _confirmPinFocusNodes = List.generate(6, (_) => FocusNode());
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _showConfirmPin = false;
  static const String _pinKey = 'user_pin';

  @override
  void initState() {
    super.initState();
    for (var n in _pinFocusNodes) n.addListener(() => setState(() {}));
    for (var n in _confirmPinFocusNodes) n.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    for (var c in _pinControllers) c.dispose();
    for (var c in _confirmPinControllers) c.dispose();
    for (var n in _pinFocusNodes) n.dispose();
    for (var n in _confirmPinFocusNodes) n.dispose();
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

    if (!isConfirm && index == 5 && value.isNotEmpty && _getPin(false).length == 6) {
      setState(() => _showConfirmPin = true);
      Future.delayed(const Duration(milliseconds: 100), () {
        _confirmPinFocusNodes[0].requestFocus();
      });
    }

    if (isConfirm && index == 5 && value.isNotEmpty && _getPin(true).length == 6) {
      _handleSetPin();
    }
  }

  String _getPin(bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    return controllers.map((c) => c.text).join();
  }

  void _clearPin(bool isConfirm) {
    if (isConfirm) {
      for (var c in _confirmPinControllers) c.clear();
      _confirmPinFocusNodes[0].requestFocus();
    } else {
      for (var c in _pinControllers) c.clear();
      _pinFocusNodes[0].requestFocus();
    }
  }

  Future<void> _handleSetPin() async {
    final pin = _getPin(false);
    final confirmPin = _getPin(true);

    if (pin.length != 6) {
      NavigationHelper.showSnackBar(context, 'Please enter all 6 digits for PIN', backgroundColor: Colors.red);
      return;
    }
    if (confirmPin.length != 6) {
      NavigationHelper.showSnackBar(context, 'Please confirm your PIN', backgroundColor: Colors.red);
      return;
    }
    if (pin != confirmPin) {
      NavigationHelper.showSnackBar(context, 'PINs do not match. Please try again.', backgroundColor: Colors.red);
      _clearPin(true);
      return;
    }

    setState(() => _isLoading = true);
    await StorageService.saveString(_pinKey, pin);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    NavigationHelper.showSnackBar(context, 'PIN set successfully!', backgroundColor: _lightGreen);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) context.pop();
    });
  }

  void _togglePinVisibility() => setState(() => _obscurePin = !_obscurePin);

  Widget _buildPinRow(bool isConfirm) {
    final controllers = isConfirm ? _confirmPinControllers : _pinControllers;
    final focusNodes = isConfirm ? _confirmPinFocusNodes : _pinFocusNodes;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        6,
        (index) => Container(
          width: 44,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _lightGreenBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: focusNodes[index].hasFocus ? _lightGreen : Colors.transparent,
              width: 2,
            ),
          ),
          child: TextField(
            controller: controllers[index],
            focusNode: focusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            obscureText: _obscurePin,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: _headerDark,
            ),
            decoration: const InputDecoration(
              filled: true,
              fillColor: _lightGreenBg,
              counterText: '',
              contentPadding: EdgeInsets.zero,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            onChanged: (value) => _onPinChanged(index, value, isConfirm),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              // Header – light green, rounded bottom
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 12,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  color: _lightGreen,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back, color: _headerDark, size: 24),
                        onPressed: () => context.pop(),
                      ),
                    ),
                    const Text(
                      'Set PIN',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _headerDark,
                      ),
                    ),
                  ],
                ),
              ),

              // White content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Lock icon – outline in light green circle
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: _lightGreenBg.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          size: 40,
                          color: _lightGreen,
                        ),
                      ),

                      const SizedBox(height: 28),

                      Text(
                        _showConfirmPin ? 'Confirm your 6-digit PIN' : 'Create a 6-digit PIN',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: _headerDark,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'This PIN will be used for quick login',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: _textMuted,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 32),

                      _buildPinRow(false),

                      if (_showConfirmPin) ...[
                        const SizedBox(height: 28),
                        _buildPinRow(true),
                      ],

                      const SizedBox(height: 20),

                      // Show PIN
                      GestureDetector(
                        onTap: _togglePinVisibility,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _obscurePin ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: _textMuted.withOpacity(0.8),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _obscurePin ? 'Show PIN' : 'Hide PIN',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: _textMuted.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 36),

                      // Set PIN button
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: _lightGreen),
                          ),
                        )
                      else
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_showConfirmPin) {
                                _handleSetPin();
                              } else if (_getPin(false).length == 6) {
                                setState(() => _showConfirmPin = true);
                                _confirmPinFocusNodes[0].requestFocus();
                              } else {
                                NavigationHelper.showSnackBar(
                                  context,
                                  'Please enter all 6 digits',
                                  backgroundColor: Colors.red,
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _lightGreen,
                              foregroundColor: _headerDark,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Set PIN',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(height: 16),

                      // Clear button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: TextButton(
                          onPressed: () {
                            if (_showConfirmPin) {
                              setState(() => _showConfirmPin = false);
                              _clearPin(true);
                              _pinFocusNodes[0].requestFocus();
                            } else {
                              _clearPin(false);
                            }
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: _lightGreenBg.withOpacity(0.5),
                            foregroundColor: _headerDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: Text(
                            _showConfirmPin ? 'Back' : 'Clear',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // Security Tips
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Security Tips:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _headerDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              '• Don\'t use obvious PINs like 123456',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _textMuted,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '• Don\'t share your PIN with anyone',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _textMuted,
                                height: 1.5,
                              ),
                            ),
                            Text(
                              '• Choose a PIN you can remember',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: FontWeight.w400,
                                color: _textMuted,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
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
