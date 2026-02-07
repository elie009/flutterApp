import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/bottom_nav_bar_figma.dart';
import '../../widgets/triangle_painter.dart';
import '../../services/auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 430,
        height: 932,
        decoration: BoxDecoration(
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

            // White bottom section (now redundant, but keep the padding/styling)
            Positioned(
              left: 0,
              top: 176,
              width: 412,
              height: 756,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFFFFFFF),
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

                      // User name (from session / current user)
                      Center(
                        child: Text(
                          AuthService.getCurrentUser()?.name ?? 'User',
                          style: const TextStyle(
                            color: Color(0xFF0E3E3E),
                            fontSize: 20,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      // User email (from session / current user)
                      Center(
                        child: Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Email: ',
                                style: TextStyle(
                                  color: Color(0xFF093030),
                                  fontSize: 13,
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: AuthService.getCurrentUser()?.email ?? '—',
                                style: const TextStyle(
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

                      const SizedBox(height: 62),

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

                          const SizedBox(height: 24),

                          // Security
                          GestureDetector(
                            onTap: () => context.go('/security'),
                            child: _buildMenuItem(
                              icon: _buildSecurityIcon(),
                              label: 'Security',
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Setting
                          GestureDetector(
                            onTap: () => context.go('/settings'),
                            child: _buildMenuItem(
                              icon: _buildSettingsIcon(),
                              label: 'Setting',
                            ),
                          ),

                          const SizedBox(height: 24),

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

                          const SizedBox(height: 24),

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
          
            // Title "Profile"
            Positioned(
              left: 0,
              right: 0,
              top: 50,
              child: Center(
                child: Text(
                  'Profile',
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 32,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor, // Green border
          width: 2,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 22.48,
          height: 28.12,
          child: Icon(
            Icons.edit,
            color: AppTheme.primaryColor, // Green icon
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor, // Green border
          width: 2,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 26.96,
          height: 28.54,
          child: Icon(
            Icons.security,
            color: AppTheme.primaryColor, // Green icon
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor, // Green border
          width: 2,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 27.52,
          height: 28.34,
          child: Icon(
            Icons.settings,
            color: AppTheme.primaryColor, // Green icon
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor, // Green border
          width: 2,
        ),
      ),
      child: const Center(
        child: Stack(
          children: [
            SizedBox(
              width: 30.87,
              height: 28.93,
              child: Icon(
                Icons.help,
                color: AppTheme.primaryColor, // Green icon
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: AppTheme.primaryColor, // Green border
          width: 2,
        ),
      ),
      child: const Center(
        child: SizedBox(
          width: 18,
          height: 26.98,
          child: Icon(
            Icons.logout,
            color: AppTheme.primaryColor, // Green icon
            size: 18,
          ),
        ),
      ),
    );
  }
}
