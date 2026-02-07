import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';

class AuthSelectionScreen extends StatelessWidget {
  const AuthSelectionScreen({super.key});

  static const _primaryGreen = AppTheme.primaryColor;
  static const _darkGreen = Color(0xFF388E3C);
  static const _textMuted = Color(0xFF555555);
  static const _lightGreenBg = Color(0xFFE6F9E6);
  static const _screenBg = Color(0xFFF0FFF4);

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _screenBg,
      body: Stack(
        children: [
          // Decorative background shapes (upper-left/middle, upper-right)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.04,
            left: -30,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.08),
                borderRadius: BorderRadius.circular(80),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.06,
            right: -40,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.06),
                borderRadius: BorderRadius.circular(70),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top bar: time left, menu right
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatTime(DateTime.now()),
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.more_vert,
                          color: Color(0xFF333333),
                          size: 24,
                        ),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Logo: outer light green rounded square with logo image
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: _lightGreenBg,
                    borderRadius: BorderRadius.circular(38),
                    boxShadow: [
                      BoxShadow(
                        color: _primaryGreen.withOpacity(0.12),
                        blurRadius: 24,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: _primaryGreen.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    clipBehavior: Clip.antiAlias,
                    padding: const EdgeInsets.all(18),
                    child: Image.asset(
                      'logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.account_balance_wallet_rounded,
                        color: _darkGreen,
                        size: 72,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Welcome to',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: _darkGreen,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Utility Hub 360',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Take control of your finances',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: _textMuted,
                  ),
                ),
                const SizedBox(height: 28),
                // Track, Save, Grow chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _FeatureChip(icon: Icons.bar_chart_rounded, label: 'Track'),
                    const SizedBox(width: 10),
                    _FeatureChip(icon: Icons.monetization_on_outlined, label: 'Save'),
                    const SizedBox(width: 10),
                    _FeatureChip(icon: Icons.trending_up_rounded, label: 'Grow'),
                  ],
                ),
                SizedBox(height:32),
                // Action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () => context.go('/login'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _primaryGreen,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Sign In'),
                        ),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () => context.go('/register'),
                          style: OutlinedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _darkGreen,
                            side: const BorderSide(color: _primaryGreen, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Create Account'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                // Security section
                Column(
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      color: _primaryGreen,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Secure & Private',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textMuted,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: _textMuted,
                          ),
                          children: [
                            const TextSpan(
                                text: 'Your financial data is protected with '),
                            TextSpan(
                              text: 'bank-level security',
                              style: TextStyle(
                                color: _darkGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const _textDark = Color(0xFF555555);
  static const _darkGreen = Color(0xFF093030); // Or whatever dark green is used in your app

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade300, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: _textDark),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }
}
