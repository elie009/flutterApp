import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LaunchScreen extends StatefulWidget {
  const LaunchScreen({super.key});

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen> {
  @override
  void initState() {
    super.initState();
    // Check authentication and navigate accordingly after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        if (AuthService.isAuthenticated()) {
          context.go('/');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFF1FFF2),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: const Stack(
          children: [
            // App title (centered on screen)
            Positioned.fill(
              child: Center(
                child: Text(
                  'UtilityHub360',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF00D09E),
                    fontSize: 52.14,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ),

            // Description text
            Positioned(
              left: 96,
              top: 462,
              child: SizedBox(
                width: 236,
                child: Text(
                  'Your Personal Finance Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF4B4544),
                    fontSize: 16,
                    fontFamily: 'League Spartan',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),

            // Loading indicator
            Positioned(
              left: 195,
              top: 550,
              child: SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00D09E)),
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
