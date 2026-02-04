import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';
class FingerprintDeleteScreen extends StatefulWidget {  
  final String fingerprintName;

  const FingerprintDeleteScreen({
    super.key,
    required this.fingerprintName,
  });

  @override
  State<FingerprintDeleteScreen> createState() => _FingerprintDeleteScreenState();
}

class _FingerprintDeleteScreenState extends State<FingerprintDeleteScreen> {
  final TextEditingController _confirmController = TextEditingController();

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _deleteFingerprint() async {
    // Check if user typed the fingerprint name for confirmation
    if (_confirmController.text.trim() != widget.fingerprintName) {
      NavigationHelper.showSnackBar(
        context,
        'Please type the fingerprint name to confirm deletion',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() {
      // Show loading state
    });

    // TODO: Implement actual fingerprint deletion
    await Future.delayed(const Duration(seconds: 1)); // Simulate API call

    if (mounted) {
      // Navigate to success screen
      context.go('/fingerprint-delete-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
      backgroundColor: const Color(0xFFFFFFFF),
      body: Container(
        width: 430,
        height: 932,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
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
              width: 413,
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
                    // If there's nothing to pop, go to the profile/settings root
                    Navigator.of(context).pushReplacementNamed('/profile');
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
                  widget.fingerprintName,
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Large fingerprint icon
            Positioned(
              left: 118,
              top: 261,
              child: Container(
                width: 195,
                height: 195,
                decoration: const BoxDecoration(
                  color: Color(0xFFb3ee9a),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.fingerprint,
                  color: Colors.white,
                  size: 120,
                ),
              ),
            ),

            // Confirmation text field background
            Positioned(
              left: 37.15,
              top: 495,
              child: Container(
                width: 356,
                height: 41,
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _confirmController,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF0E3E3E),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type "${widget.fingerprintName}" to confirm',
                    hintStyle: const TextStyle(
                      color: Color(0xFF0E3E3E),
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w400,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),

            // Delete button
            Positioned(
              left: 114,
              top: 626,
              child: GestureDetector(
                onTap: _deleteFingerprint,
                child: Container(
                  width: 202,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFFb3ee9a),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Delete',
                    style: TextStyle(
                      color: Color(0xFFFFFFFF),
                      fontSize: 20,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      height: 1.10,
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon
            Positioned(
              left: 364,
              top: 51,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications,
                    color: Color(0xFF093030),
                    size: 21,
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
