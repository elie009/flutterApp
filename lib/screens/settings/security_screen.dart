import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';

class SecurityScreen extends StatelessWidget {
  const SecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: AppTheme.primaryColor,
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
              width: 430,
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
                  'Security',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Setup Login PIN menu item
            Positioned(
              left: 38,
              top: 233,
              right: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/pin-setup'),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Setup Login PIN',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF093030),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Change pin menu item
            Positioned(
              left: 38,
              top: 293,
              right: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/change-pin'),
                child: Row(
                  children: [
                    const Expanded(
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
                    const SizedBox(
                      width: 24,
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF093030),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Fingerprint menu item
            Positioned(
              left: 38,
              top: 367,
              right: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.go('/fingerprint'),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Fingerprint',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF093030),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Terms and conditions menu item
            Positioned(
              left: 38,
              top: 441,
              right: 38,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => context.push('/terms-conditions'),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Terms and conditions',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 24,
                      child: Icon(
                        Icons.chevron_right,
                        color: Color(0xFF093030),
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Separator lines
            Positioned(
              left: 38,
              top: 276,
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
              top: 336,
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
              top: 416,
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
              top: 496,
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

            // Notification icon (same as dashboard: white circle + red badge, tap to open notifications)
            Positioned(
              left: 364,
              top: 51,
              child: GestureDetector(
                onTap: () => context.push('/notifications'),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        color: Color(0xFF093030),
                        size: 22,
                      ),
                    ),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                          border: Border.fromBorderSide(BorderSide(color: Colors.white, width: 1)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
    );
  }
}