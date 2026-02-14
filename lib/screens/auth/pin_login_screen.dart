import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_config.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';

class PinLoginScreen extends StatefulWidget {
  const PinLoginScreen({super.key});

  @override
  State<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends State<PinLoginScreen> {
  static const _pinKey = 'user_pin';
  static const _lightGreen = AppTheme.primaryColor;
  static const _headerDark = Color(0xFF093030);
  static const _textGray = Color(0xFF757575);
  static const _keypadBg = Color(0xFFE8E8E8);

  String _pin = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkPinExists();
  }

  Future<void> _checkPinExists() async {
    final pin = StorageService.getString(_pinKey);
    if ((pin == null || pin.isEmpty) && mounted) {
      NavigationHelper.showSnackBar(
        context,
        'Set up a PIN first (login with email, then Settings → Security)',
        backgroundColor: Colors.orange,
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) context.go('/login');
      });
    }
  }

  String _getGreeting() {
    return 'Welcome,';
  }

  String get _userName {
    final name = StorageService.getString('user_display_name');
    return name != null && name.isNotEmpty ? name : 'User';
  }

  void _onKeyTap(String digit) {
    if (_pin.length >= 6 || _isLoading) return;
    setState(() => _pin += digit);
    if (_pin.length == 6) _handleLogin();
  }

  void _onBackspace() {
    if (_pin.isEmpty) return;
    setState(() => _pin = _pin.substring(0, _pin.length - 1));
  }

  void _clearPin() {
    setState(() => _pin = '');
  }

  Future<void> _handleBiometricLogin() async {
    final hasSupport = await BiometricService.hasBiometricSupport;
    if (!mounted) return;
    if (!hasSupport) {
      NavigationHelper.showSnackBar(
        context,
        'Biometric is not set up. Set up fingerprint or face unlock in your device settings.',
        backgroundColor: Colors.orange,
      );
      return;
    }
    final ok = await BiometricService.authenticate(reason: 'Unlock UtilityHub360');
    if (!mounted) return;
    if (!ok) {
      NavigationHelper.showSnackBar(
        context,
        'Biometric authentication failed or was cancelled',
        backgroundColor: Colors.orange,
      );
      return;
    }
    setState(() => _isLoading = true);
    final restored = await AuthService.restoreSessionFromStorage();
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (restored) {
      await AuthService.registerDeviceId();
      if (!mounted) return;
      NavigationHelper.showSnackBar(context, 'Welcome back!', backgroundColor: _lightGreen);
      context.go('/');
    } else {
      NavigationHelper.showSnackBar(
        context,
        'No saved session. Log in with email/password.',
        backgroundColor: Colors.orange,
      );
    }
  }

  Future<void> _handleLogin() async {
    if (_pin.length != 6) return;
    final storedPin = StorageService.getString(_pinKey);
    if (storedPin == null || storedPin.isEmpty) {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'No PIN set. Log in with email first.',
          backgroundColor: Colors.orange,
        );
        _clearPin();
      }
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 400));

    if (!mounted) return;
    if (storedPin == _pin) {
      bool restored = await AuthService.restoreSessionFromStorage();
      if (!mounted) return;
      if (restored) {
        setState(() => _isLoading = false);
        await AuthService.registerDeviceId();
        if (!mounted) return;
        NavigationHelper.showSnackBar(context, 'Welcome back!', backgroundColor: _lightGreen);
        context.go('/');
        return;
      }
      // No session (e.g. after logout): log in with PIN via backend
      final email = StorageService.getString(AppConfig.pinLoginEmailKey);
      if (email != null && email.isNotEmpty) {
        final result = await AuthService.loginWithPin(email: email, pin: _pin);
        if (!mounted) return;
        setState(() => _isLoading = false);
        if (result['success'] == true) {
          await AuthService.registerDeviceId();
          if (!mounted) return;
          NavigationHelper.showSnackBar(context, 'Welcome back!', backgroundColor: _lightGreen);
          context.go('/');
        } else {
          NavigationHelper.showSnackBar(
            context,
            result['message'] as String? ?? 'PIN login failed',
            backgroundColor: Colors.red,
          );
          _clearPin();
        }
        return;
      }
      setState(() => _isLoading = false);
      NavigationHelper.showSnackBar(
        context,
        'No saved session. Log in with email/password.',
        backgroundColor: Colors.orange,
      );
      _clearPin();
    } else {
      setState(() => _isLoading = false);
      NavigationHelper.showSnackBar(context, 'Incorrect PIN. Try again.', backgroundColor: Colors.red);
      _clearPin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          if (context.canPop()) context.pop();
          else context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        bottomNavigationBar: Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _BottomNavItem(
                icon: Icons.send_rounded,
                label: 'Sign-in Option',
                onTap: () => context.go('/login'),
              ),
              _BottomNavItem(
                icon: Icons.home_outlined,
                label: 'Products & Offers',
                onTap: () => context.go('/login'),
              ),
              _BottomNavItem(
                icon: Icons.phone_outlined,
                label: 'Call us',
                onTap: () {
                  // TODO: launch tel: or in-app support
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Top: logo
              Padding(
                padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                child: Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: _lightGreen,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(12),
                    child: Image.asset(
                      'logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(Icons.account_balance_rounded, size: 40, color: _headerDark),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Greeting
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: _textGray,
                ),
              ),
              const SizedBox(height: 4),
              // User name
              Text(
                _userName,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _headerDark,
                ),
              ),

              const SizedBox(height: 24),

              // 6 PIN dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (i) {
                  final filled = i < _pin.length;
                  return Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: filled ? _headerDark : _textGray.withOpacity(0.35),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              ),

              if (_isLoading) ...[
                const SizedBox(height: 20),
                const SizedBox(
                  height: 28,
                  width: 28,
                  child: CircularProgressIndicator(strokeWidth: 2, color: _lightGreen),
                ),
              ],
              const SizedBox(height: 30),

              // Numeric keypad 3x4
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _KeypadButton(label: '1', onTap: () => _onKeyTap('1')),
                        _KeypadButton(label: '2', onTap: () => _onKeyTap('2')),
                        _KeypadButton(label: '3', onTap: () => _onKeyTap('3')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _KeypadButton(label: '4', onTap: () => _onKeyTap('4')),
                        _KeypadButton(label: '5', onTap: () => _onKeyTap('5')),
                        _KeypadButton(label: '6', onTap: () => _onKeyTap('6')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _KeypadButton(label: '7', onTap: () => _onKeyTap('7')),
                        _KeypadButton(label: '8', onTap: () => _onKeyTap('8')),
                        _KeypadButton(label: '9', onTap: () => _onKeyTap('9')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _KeypadButton(
                          customChild: BiometricService.isAndroid
                              ? const Icon(
                                  Icons.fingerprint_rounded,
                                  size: 28,
                                  color: Color(0xFF1a1a1a),
                                )
                              : SvgPicture.asset(
                                  'assets/icons/face_id.svg',
                                  width: 28,
                                  height: 28,
                                  colorFilter: const ColorFilter.mode(
                                    Color(0xFF1a1a1a),
                                    BlendMode.srcIn,
                                  ),
                                ),
                          onTap: _handleBiometricLogin,
                        ),
                        _KeypadButton(label: '0', onTap: () => _onKeyTap('0')),
                        _KeypadButton(
                          icon: Icons.backspace_outlined,
                          onTap: _onBackspace,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Switch User | Forgot PIN?
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Switch User',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'Forgot PIN?',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _KeypadButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final Widget? customChild;
  final VoidCallback onTap;

  const _KeypadButton({this.label, this.icon, this.customChild, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (customChild != null) {
      content = customChild!;
    } else if (label != null) {
      content = Text(
        label!,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 24,
          fontWeight: FontWeight.w500,
          color: Color(0xFF1a1a1a),
        ),
      );
    } else {
      content = Icon(icon ?? Icons.circle_outlined, size: 24, color: const Color(0xFF1a1a1a));
    }
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: 72,
          height: 56,
          decoration: BoxDecoration(
            color: const Color(0xFFE8E8E8),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomNavItem({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF424242)),
              const SizedBox(height: 4),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF424242),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
