import 'package:flutter/material.dart';

class FingerprintDeleteSuccessScreen extends StatelessWidget {
  const FingerprintDeleteSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Auto navigate back after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        Navigator.of(context).pop(true); // Return true to indicate successful deletion
      }
    });

    return Scaffold(
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
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

            // Success checkmark icon
            Positioned(
              left: 144,
              top: 349.98,
              child: Container(
                width: 142,
                height: 142,
                child: Stack(
                  children: [
                    // Main circle background
                    Positioned.fill(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFFDFF7E2),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    // Checkmark
                    Positioned(
                      left: 31.24,
                      top: 61.06,
                      child: Container(
                        width: 18.46,
                        height: 18.46,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDFF7E2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Color(0xFFb3ee9a),
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Success message
            const Positioned(
              left: 102,
              top: 524,
              child: SizedBox(
                width: 227,
                child: Text(
                  'fingerprint Has been Changed successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFDFF7E2),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.30,
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
