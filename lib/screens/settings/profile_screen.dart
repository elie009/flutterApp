import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
              top: 176,
              width: 430,
              height: 756,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1FFF3),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(70),
                    topRight: Radius.circular(70),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(37, 0, 37, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 76), // Space for profile avatar

                      // User name
                      const Center(
                        child: Text(
                          'John Smith',
                          style: TextStyle(
                            color: Color(0xFF0E3E3E),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // User ID
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: 'ID: ',
                                style: TextStyle(
                                  color: Color(0xFF093030),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: '25030024',
                                style: TextStyle(
                                  color: Color(0xFF093030),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 72),

                      // Menu items
                      Column(
                        children: [
                          // Edit Profile
                          GestureDetector(
                            onTap: () => context.go('/edit-profile'),
                            child: _buildMenuItem(
                              icon: _buildEditProfileIcon(),
                              label: 'Edit Profile',
                            ),
                          ),

                          const SizedBox(height: 34),

                          // Security
                          GestureDetector(
                            onTap: () => context.go('/security'),
                            child: _buildMenuItem(
                              icon: _buildSecurityIcon(),
                              label: 'Security',
                            ),
                          ),

                          const SizedBox(height: 34),

                          // Setting
                          GestureDetector(
                            onTap: () => context.go('/settings'),
                            child: _buildMenuItem(
                              icon: _buildSettingsIcon(),
                              label: 'Setting',
                            ),
                          ),

                          const SizedBox(height: 34),

                          // Help
                          GestureDetector(
                            onTap: () {
                              // TODO: Navigate to help screen
                            },
                            child: _buildMenuItem(
                              icon: _buildHelpIcon(),
                              label: 'Help',
                            ),
                          ),

                          const SizedBox(height: 34),

                          // Logout
                          GestureDetector(
                            onTap: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Logout'),
                                  content: const Text('Are you sure you want to logout?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      child: const Text('Logout'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true) {
                                await AuthService.logout();
                                // Navigate directly to login page
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              }
                            },
                            child: _buildMenuItem(
                              icon: _buildLogoutIcon(),
                              label: 'Logout',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                  'Profile',
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

            // Profile avatar
            Positioned(
              left: 157,
              top: 117,
              child: Container(
                width: 117,
                height: 117,
                decoration: const BoxDecoration(
                  color: Colors.grey, // Placeholder color
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 60,
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
      bottomNavigationBar: const BottomNavBarFigma(currentIndex: 4),
    );
  }

  Widget _buildMenuItem({required Widget icon, required String label}) {
    return Row(
      children: [
        icon,
        const SizedBox(width: 13),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF093030),
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF6DB6FE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 22.48,
          height: 28.12,
          child: Icon(
            Icons.edit,
            color: Color(0xFFF1FFF3),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSecurityIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF3299FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 26.96,
          height: 28.54,
          child: Icon(
            Icons.security,
            color: Color(0xFFF1FFF3),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF0068FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 27.52,
          height: 28.34,
          child: Icon(
            Icons.settings,
            color: Color(0xFFF1FFF3),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildHelpIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF6DB6FE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: Stack(
          children: [
            SizedBox(
              width: 30.87,
              height: 28.93,
              child: Icon(
                Icons.help,
                color: Color(0xFFF1FFF3),
                size: 20,
              ),
            ),
            Positioned(
              left: 27.45,
              top: 29.22,
              child: SizedBox(
                width: 1.98,
                height: 1.98,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0xFFF1FFF3),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutIcon() {
    return Container(
      width: 57,
      height: 53,
      decoration: BoxDecoration(
        color: const Color(0xFF3299FF),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 26.98,
          child: Icon(
            Icons.logout,
            color: Color(0xFFF1FFF3),
            size: 18,
          ),
        ),
      ),
    );
  }
}