import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_mobile.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

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
            // White bottom section
            Positioned(
              left: 0,
              top: 132,
              width: 430,
              height: 800,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                ),
              ),
            ),

            // Status bar
            Positioned(
              left: 0,
              top: 0,
              width: 430,
              height: 32,
              child: Stack(
                children: [
                  const Positioned(
                    left: 37,
                    top: 9,
                    child: Text(
                      '16:04',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'League Spartan',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  // Status icons
                  Positioned(
                    left: 338,
                    top: 9,
                    child: Container(
                      width: 13,
                      height: 11,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 356,
                    top: 11,
                    child: Container(
                      width: 15,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(58),
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 377,
                    top: 12,
                    child: Container(
                      width: 12,
                      height: 7,
                      color: Colors.white,
                    ),
                  ),
                  Positioned(
                    left: 376,
                    top: 11,
                    child: Container(
                      width: 17,
                      height: 9,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(1),
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
                  ),
                ),
              ),
            ),

            // Security section title
            const Positioned(
              left: 38,
              top: 183,
              child: SizedBox(
                width: 177,
                height: 25,
                child: Text(
                  'Security',
                  style: TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Change pin menu item
            Positioned(
              left: 38,
              top: 263,
              child: GestureDetector(
                onTap: () => context.go('/change-pin'),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 157,
                      child: Text(
                        'Change pin',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 190),
                    Transform.rotate(
                      angle: 180 * 3.14159 / 180, // 180 degrees in radians
                      child: Container(
                        width: 7,
                        height: 13,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF093030),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fingerprint menu item
            Positioned(
              left: 38,
              top: 337,
              child: GestureDetector(
                onTap: () => context.go('/fingerprint'),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 157,
                      child: Text(
                        'fingerprint',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 190),
                    Transform.rotate(
                      angle: 180 * 3.14159 / 180, // 180 degrees in radians
                      child: Container(
                        width: 7,
                        height: 13,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF093030),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Terms and conditions menu item
            Positioned(
              left: 38,
              top: 411,
              child: GestureDetector(
                onTap: () => context.go('/terms-conditions'),
                child: Row(
                  children: [
                    const Text(
                      'Terms and conditions',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 180),
                    Transform.rotate(
                      angle: 180 * 3.14159 / 180, // 180 degrees in radians
                      child: Container(
                        width: 7,
                        height: 13,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF093030),
                            width: 2.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Separator lines
            Positioned(
              left: 38,
              top: 306,
              child: Container(
                width: 354,
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDFF7E2),
                    width: 1.01,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 38,
              top: 386,
              child: Container(
                width: 354,
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDFF7E2),
                    width: 1.01,
                  ),
                ),
              ),
            ),

            Positioned(
              left: 38,
              top: 466,
              child: Container(
                width: 354,
                height: 0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDFF7E2),
                    width: 1.01,
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
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarMobile(currentIndex: 4),
    );
  }
}