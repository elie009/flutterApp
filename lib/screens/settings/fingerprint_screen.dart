import 'package:flutter/material.dart';
import '../../utils/navigation_helper.dart';

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
              left: 95,
              top: 64,
              child: SizedBox(
                width: 241,
                child: Text(
                  'Fingerprint',
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

            // Fingerprint list
            ..._fingerprints.asMap().entries.map((entry) {
              final index = entry.key;
              final fingerprint = entry.value;
              final topPosition = 194.0 + (index * 96); // Space fingerprints vertically

              return Positioned(
                left: 37,
                top: topPosition,
                child: Row(
                  children: [
                    // Fingerprint icon
                    Container(
                      width: 57,
                      height: 53,
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CB5FD),
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
                    // Remove button
                    GestureDetector(
                      onTap: () => _removeFingerprint(fingerprint['id']!),
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF6B6B),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Add fingerprint option
            Positioned(
              left: 38,
              top: 194.0 + (_fingerprints.length * 96), // Position after existing fingerprints
              child: GestureDetector(
                onTap: _addFingerprint,
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
                    const Text(
                      'Add a fingerprint',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
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
