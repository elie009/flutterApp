import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _changePinEnabled = true;
  bool _fingerprintEnabled = false;
  bool _termsAccepted = true;

  void _showChangePinDialog() {
    NavigationHelper.navigateTo(context, 'change-pin');
  }

  void _navigateToFingerprint() {
    NavigationHelper.navigateTo(context, 'fingerprint');
  }

  Future<void> _showTermsScreen() async {
    // For now, navigate without expecting a return value
    // TODO: Implement proper result handling with GoRouter
    context.go('/terms-conditions');
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
              width: 430,
              height: 32,
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

            // Back button
            Positioned(
              left: 38,
              top: 69,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 19,
                  height: 16,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color(0xFFF1FFF3),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),

            // Title
            const Positioned(
              left: 153,
              top: 64,
              child: SizedBox(
                width: 125,
                child: Text(
                  'Security',
                  textAlign: TextAlign.center,
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

            // Security section header
            const Positioned(
              left: 38,
              top: 183,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 177,
                    height: 25,
                    child: Text(
                      'Security',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Change PIN option
            Positioned(
              left: 38,
              top: 263,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 157,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _changePinEnabled ? _showChangePinDialog : null,
                          child: SizedBox(
                            width: 166,
                            height: 14,
                            child: Text(
                              'Change pin',
                              style: TextStyle(
                                color: _changePinEnabled
                                    ? const Color(0xFF093030)
                                    : const Color(0xFF093030).withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 190),
                  Transform.rotate(
                    angle: 3.14159, // 180 degrees in radians
                    child: Switch(
                      value: _changePinEnabled,
                      onChanged: (value) {
                        setState(() {
                          _changePinEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF00D09E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFDFF7E2),
                    ),
                  ),
                ],
              ),
            ),

            // Fingerprint option
            Positioned(
              left: 38,
              top: 337,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: 157,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _fingerprintEnabled ? _navigateToFingerprint : null,
                          child: SizedBox(
                            width: 166,
                            height: 14,
                            child: Text(
                              'fingerprint',
                              style: TextStyle(
                                color: _fingerprintEnabled
                                    ? const Color(0xFF093030)
                                    : const Color(0xFF093030).withOpacity(0.5),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 190),
                  Transform.rotate(
                    angle: 3.14159, // 180 degrees in radians
                    child: Switch(
                      value: _fingerprintEnabled,
                      onChanged: (value) {
                        setState(() {
                          _fingerprintEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF00D09E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFDFF7E2),
                    ),
                  ),
                ],
              ),
            ),

            // Terms and conditions option
            Positioned(
              left: 38,
              top: 411,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _showTermsScreen,
                        child: Text(
                          'Terms and conditions',
                          style: TextStyle(
                            color: const Color(0xFF093030),
                            fontSize: 15,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 180),
                  Transform.rotate(
                    angle: 3.14159, // 180 degrees in radians
                    child: Switch(
                      value: _termsAccepted,
                      onChanged: (value) {
                        setState(() {
                          _termsAccepted = value;
                        });
                      },
                      activeColor: const Color(0xFF00D09E),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: const Color(0xFFDFF7E2),
                    ),
                  ),
                ],
              ),
            ),

            // Switch lines/dividers
            Positioned(
              left: 392,
              top: 306,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Container(
                  width: 354,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.01,
                        color: Color(0xFFDFF7E2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 392,
              top: 386,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Container(
                  width: 354,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.01,
                        color: Color(0xFFDFF7E2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              left: 392,
              top: 466,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Container(
                  width: 354,
                  height: 0,
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        width: 1.01,
                        color: Color(0xFFDFF7E2),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 61,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: Center(
                  child: Container(
                    width: 14.57,
                    height: 18.86,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFF093030),
                        width: 1.29,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Navigation
            Positioned(
              left: 0,
              top: 824,
              width: 430,
              height: 108,
              child: Container(
                padding: const EdgeInsets.fromLTRB(60, 36, 60, 41),
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Home icon
                    Container(
                      width: 25,
                      height: 31,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Analysis icon
                    Container(
                      width: 31,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Transactions icon
                    Container(
                      width: 33,
                      height: 25,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Categories icon
                    Container(
                      width: 27,
                      height: 23,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xFF052224),
                          width: 2,
                        ),
                      ),
                    ),

                    // Profile icon (active)
                    Stack(
                      children: [
                        Positioned(
                          left: -17,
                          top: -12,
                          child: Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00D09E),
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                        ),
                        Container(
                          width: 22,
                          height: 27,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xFF052224),
                              width: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
