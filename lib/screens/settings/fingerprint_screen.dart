import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';
class FingerprintScreen extends StatefulWidget {
  const FingerprintScreen({super.key});

  @override
  State<FingerprintScreen> createState() => _FingerprintScreenState();
}

class _FingerprintScreenState extends State<FingerprintScreen> {
  // Mock data for demonstration - in real app this would come from biometric storage
  final List<Map<String, String>> _fingerprints = [
    {
      'name': 'John Fingerprint',
      'id': '1',
    },
  ];

  void _addFingerprint() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Fingerprint'),
        content: const Text(
          'Place your finger on the fingerprint sensor to add a new fingerprint.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // TODO: Implement actual fingerprint scanning
              Navigator.of(context).pop();
              setState(() {
                _fingerprints.add({
                  'name': 'Fingerprint ${_fingerprints.length + 1}',
                  'id': '${_fingerprints.length + 1}',
                });
              });
              NavigationHelper.showSnackBar(
                context,
                'Fingerprint added successfully',
              );
            },
            child: const Text('Scan'),
          ),
        ],
      ),
    );
  }

  void _removeFingerprint(String fingerprintId) {
    final fingerprint = _fingerprints.firstWhere(
      (fp) => fp['id'] == fingerprintId,
      orElse: () => {},
    );
    final fingerprintName = fingerprint['name'] ?? 'Unknown Fingerprint';

    Navigator.of(context).pushNamed(
      'fingerprint-delete',
      arguments: {
        'fingerprintName': fingerprintName,
        'fingerprintId': fingerprintId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
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
                  'Fingerprint',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Fingerprint list
            ..._fingerprints.asMap().entries.map((entry) {
              final index = entry.key;
              final fingerprint = entry.value;
              final topPosition = 234.0 + (index * 81); // Space fingerprints vertically

              return Positioned(
                left: 37,
                top: topPosition,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => context.push('/fingerprint-delete', extra: fingerprint),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 356, // Match the width of other items
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          // Fingerprint icon
                          Container(
                            width: 57,
                            height: 53,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: AppTheme.primaryColor, // Green border
                                width: 2,
                              ),
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              color: AppTheme.primaryColor, // Green icon
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 19),
                          // Fingerprint name
                          Expanded(
                            child: Text(
                              fingerprint['name'] ?? 'Unknown',
                              style: const TextStyle(
                                color: Color(0xFF093030),
                                fontSize: 15,
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          // Chevron arrow
                          const Icon(
                            Icons.chevron_right,
                            color: Color(0xFF093030),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),

            // Add fingerprint option
            Positioned(
              left: 37,
              top: 325.0, // Fixed position matching Figma design
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addFingerprint,
                  borderRadius: BorderRadius.circular(22),
                  child: Container(
                    width: 356, // Match the width of other items
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        // Add icon
                        Container(
                          width: 57,
                          height: 53,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(
                              color: AppTheme.primaryColor, // Green border
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: AppTheme.primaryColor, // Green icon
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 19),
                        // Add text
                        const Expanded(
                          child: Text(
                            'Add a fingerprint',
                            style: TextStyle(
                              color: Color(0xFF093030),
                              fontSize: 15,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        // Chevron arrow
                        const Icon(
                          Icons.chevron_right,
                          color: Color(0xFF093030),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon (same as dashboard: white circle, tap to open notifications)
            Positioned(
              left: 364,
              top: 51,
              child: GestureDetector(
                onTap: () => context.push('/notifications'),
                behavior: HitTestBehavior.opaque,
                child: Container(
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
