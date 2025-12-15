import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

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

  Future<void> _removeFingerprint(String fingerprintId) async {
    final fingerprint = _fingerprints.firstWhere((fp) => fp['id'] == fingerprintId);
    final fingerprintName = fingerprint['name'] ?? 'Unknown Fingerprint';

    final result = await Navigator.of(context).pushNamed(
      'fingerprint-delete',
      arguments: {'name': fingerprintName, 'id': fingerprintId},
    );

    // If deletion was successful (came back from success screen), remove from list
    if (result == true) {
      setState(() {
        _fingerprints.removeWhere((fp) => fp['id'] == fingerprintId);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
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

            // White bottom section
            Positioned(
              left: 0,
              top: 132,
              width: 430,
              height: 800,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
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

            // Title
            Positioned(
              left: 95,
              top: 64,
              child: SizedBox(
                width: 241,
                child: Text(
                  'Fingerprint',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    height: 1.10,
                  ),
                ),
              ),
            ),

            // Fingerprint list
            ..._fingerprints.asMap().entries.map((entry) {
              final index = entry.key;
              final fingerprint = entry.value;
              final topPosition = 194.0 + (index * 81); // Space fingerprints vertically

              return Positioned(
                left: 37,
                top: topPosition,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _removeFingerprint(fingerprint['id']!),
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
                              color: const Color(0xFF6DB6FE),
                              borderRadius: BorderRadius.circular(22),
                            ),
                            child: const Icon(
                              Icons.fingerprint,
                              color: Colors.white,
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
              top: 275.0, // Fixed position matching Figma design
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
                            color: const Color(0xFF3299FF),
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
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

            // Notification icon
            Positioned(
              right: 36,
              top: 61,
              child: Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFDFF7E2),
                  borderRadius: BorderRadius.all(Radius.circular(25.71)),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_outlined,
                    color: Color(0xFF093030),
                    size: 18,
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
