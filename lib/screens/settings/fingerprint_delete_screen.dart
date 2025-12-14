import 'package:flutter/material.dart';
import '../../utils/navigation_helper.dart';

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
      // Navigate to success screen with fingerprint ID
      Navigator.of(context).pushReplacementNamed(
        'fingerprint-delete-success',
        arguments: {'id': widget.fingerprintName}, // Using name as ID for demo
      );
    }
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
                onTap: () => Navigator.of(context).pop(false),
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
            Positioned(
              left: 95,
              top: 64,
              child: SizedBox(
                width: 241,
                child: Text(
                  widget.fingerprintName,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
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
                  color: Color(0xFF00D09E),
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
                  borderRadius: BorderRadius.circular(18),
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
                    color: const Color(0xFF00D09E),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Delete',
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
