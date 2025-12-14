import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  void _navigateToNext(BuildContext context) {
    print('DEBUG: Navigating to login from onboarding');
    context.go('/login');
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
              child: Container(
                width: 430,
                height: 32,
                decoration: const BoxDecoration(),
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
            ),

            // Circular image background
            Positioned(
              left: 99,
              top: 443,
              child: Container(
                width: 248,
                height: 248,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Circular image placeholder
            Positioned(
              left: 72,
              top: 403.50,
              child: Container(
                width: 287,
                height: 287,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: const NetworkImage("https://placehold.co/287x287"),
                    fit: BoxFit.cover,
                    onError: (error, stackTrace) {
                      // Fallback for image loading errors
                    },
                  ),
                ),
              ),
            ),

            // Welcome title
            const Positioned(
              left: 70,
              top: 123,
              child: SizedBox(
                width: 289,
                height: 122,
                child: Text(
                  'Welcome to Expense Manager',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0E3E3E),
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.30,
                  ),
                ),
              ),
            ),

            // Next button (text)
            Positioned(
              left: 181,
              top: 758,
              child: GestureDetector(
                onTap: () {
                  print('Onboarding Next button tapped');
                  _navigateToNext(context);
                },
                child: const Text(
                  'Next',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF0E3E3E),
                    fontSize: 30,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 0.73,
                  ),
                ),
              ),
            ),

            // Pagination dots
            Positioned(
              left: 194,
              top: 807,
              child: Container(
                width: 13,
                height: 13,
                decoration: const BoxDecoration(
                  color: Color(0xFF00D09E),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Positioned(
              left: 223,
              top: 807,
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    width: 2,
                    color: const Color(0xFF0E3E3E),
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
