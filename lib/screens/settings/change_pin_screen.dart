import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';

class ChangePinScreen extends StatefulWidget {
  const ChangePinScreen({super.key});

  @override
  State<ChangePinScreen> createState() => _ChangePinScreenState();
}

class _ChangePinScreenState extends State<ChangePinScreen> {
  static const _pinKey = 'user_pin';
  static const _lightGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);
  static const _headerLight = Color(0xFFF1FFF3);
  static const _textDark = Color(0xFF333333);
  static const _textMuted = Color(0xFF757575);
  static const _boxBorder = Color(0xFFE0E0E0);
  static const _tipsBg = Color(0xFFE8F5E9);

  int _step = 0; // 0: Current, 1: New PIN, 2: Confirm
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _focusNode = FocusNode();

  bool _isLoading = false;
  bool _showPin = false;

  TextEditingController get _activeController {
    switch (_step) {
      case 0:
        return _currentPinController;
      case 1:
        return _newPinController;
      case 2:
        return _confirmPinController;
      default:
        return _currentPinController;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentPinController.addListener(() => setState(() {}));
    _newPinController.addListener(() => setState(() {}));
    _confirmPinController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _currentPinController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    final pin = _activeController.text;
    if (pin.length != 6) {
      NavigationHelper.showSnackBar(
        context,
        'Please enter all 6 digits',
        backgroundColor: Colors.red,
      );
      return;
    }

    if (_step == 0) {
      final storedPin = StorageService.getString(_pinKey);
      if (storedPin == null || storedPin.isEmpty) {
        NavigationHelper.showSnackBar(
          context,
          'No PIN set. Set up a PIN first.',
          backgroundColor: Colors.orange,
        );
        return;
      }
      if (pin != storedPin) {
        NavigationHelper.showSnackBar(
          context,
          'Incorrect current PIN. Try again.',
          backgroundColor: Colors.red,
        );
        _currentPinController.clear();
        return;
      }
      setState(() {
        _step = 1;
        _showPin = false;
      });
      return;
    }

    if (_step == 1) {
      setState(() {
        _step = 2;
        _showPin = false;
      });
      return;
    }

    // _step == 2: Confirm
    if (pin != _newPinController.text) {
      NavigationHelper.showSnackBar(
        context,
        'New PIN and confirm PIN do not match',
        backgroundColor: Colors.red,
      );
      _confirmPinController.clear();
      return;
    }

    setState(() => _isLoading = true);
    await StorageService.saveString(_pinKey, pin);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    NavigationHelper.showSnackBar(context, 'PIN changed successfully!', backgroundColor: _lightGreen);
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/profile');
    }
  }

  void _onBack() {
    if (_step > 0) {
      setState(() {
        _step--;
        _activeController.clear();
      });
    } else {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      } else {
        context.go('/profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(color: AppTheme.primaryColor),
        child: Stack(
          children: [
            
            SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(70),
                        topRight: Radius.circular(70),
                      ),
                      child: Container(
                        width: double.infinity,
                        color: Colors.white,
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            children: [
                              const SizedBox(height: 24),
                              _buildPadlock(),
                              const SizedBox(height: 24),
                              _buildStepTitle(),
                              const SizedBox(height: 8),
                              _buildStepSubtitle(),
                              const SizedBox(height: 28),
                              Stack(
                                children: [
                                  _buildSixDigitBoxes(),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: _buildHiddenField(),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              _buildShowPin(),
                              if (_step == 0) ...[
                                const SizedBox(height: 32),
                                _buildSecurityTips(),
                              ],
                              const SizedBox(height: 40),
                              _buildContinueButton(),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: _onBack,
                child: const Icon(Icons.arrow_back, color: _headerLight, size: 28),
              ),
              const Text(
                'Change PIN',
                style: TextStyle(
                  color: _headerLight,
                  fontSize: 22,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_outlined, color: _headerDark, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    const steps = ['Current', 'New PIN', 'Confirm'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < 3; i++) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: i <= _step ? _headerDark : Colors.white,
                  border: Border.all(
                    color: i <= _step ? _headerDark : _boxBorder,
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: TextStyle(
                      color: i <= _step ? Colors.white : _textMuted,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i],
                style: TextStyle(
                  color: i <= _step ? _headerDark : _textMuted,
                  fontSize: 12,
                  fontWeight: i == _step ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
          if (i < 2)
            Container(
              width: 40,
              margin: const EdgeInsets.only(bottom: 20),
              height: 2,
              color: i < _step ? _headerDark : _boxBorder,
            ),
        ],
      ],
    );
  }

  Widget _buildPadlock() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: _tipsBg,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.lock_outline, color: _lightGreen, size: 36),
    );
  }

  Widget _buildStepTitle() {
    const titles = [
      'Enter Current PIN',
      'Enter New PIN',
      'Confirm New PIN',
    ];
    return Text(
      titles[_step],
      style: const TextStyle(
        color: _textDark,
        fontSize: 20,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildStepSubtitle() {
    const subtitles = [
      'Enter your current 6-digit PIN to continue',
      'Enter your new 6-digit PIN',
      'Re-enter your new 6-digit PIN to confirm',
    ];
    return Text(
      subtitles[_step],
      style: const TextStyle(
        color: _textMuted,
        fontSize: 14,
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSixDigitBoxes() {
    final pin = _activeController.text;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        final hasDigit = i < pin.length;
        final char = hasDigit ? (_showPin ? pin[i] : '●') : '';
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(_focusNode);
          },
          child: Container(
            width: 44,
            height: 52,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _boxBorder, width: 1.5),
            ),
            alignment: Alignment.center,
            child: Text(
              char,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: _headerDark,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildHiddenField() {
    return SizedBox(
      width: 1,
      height: 1,
      child: TextField(
        focusNode: _focusNode,
        controller: _activeController,
        keyboardType: TextInputType.number,
        maxLength: 6,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(
          border: InputBorder.none,
          counterText: '',
          contentPadding: EdgeInsets.zero,
        ),
      ),
    );
  }

  Widget _buildShowPin() {
    return GestureDetector(
      onTap: () => setState(() => _showPin = !_showPin),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _showPin ? Icons.visibility : Icons.visibility_off,
            size: 20,
            color: _headerDark,
          ),
          const SizedBox(width: 8),
          Text(
            _showPin ? 'Hide PIN' : 'Show PIN',
            style: const TextStyle(
              color: _headerDark,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityTips() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _tipsBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Security Tips:',
            style: TextStyle(
              color: _textDark,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _tipBullet('Don\'t use sequential numbers (e.g., 123456)'),
          _tipBullet('Avoid using birthdays or common patterns'),
          _tipBullet('Keep your PIN private and secure'),
        ],
      ),
    );
  }

  Widget _tipBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '• ',
            style: TextStyle(color: _headerDark, fontSize: 14, fontWeight: FontWeight.w600),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: _headerDark, fontSize: 14, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    final isLastStep = _step == 2;
    final label = isLastStep ? 'Change PIN' : 'Continue';
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _onContinue,
        style: ElevatedButton.styleFrom(
          backgroundColor: _lightGreen,
          foregroundColor: _headerDark,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(_headerDark),
                ),
              )
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}
