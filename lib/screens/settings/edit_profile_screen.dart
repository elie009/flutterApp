import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar_figma.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  User? _user;
  bool _isLoading = false;
  bool _darkThemeEnabled = false;
  bool _pushNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
    });

    final user = await AuthService.getUserProfile();
    setState(() {
      _user = user ?? AuthService.getCurrentUser();
      _usernameController.text = _user?.name ?? '';
      _phoneController.text = _user?.phone ?? '';
      _emailController.text = _user?.email ?? '';
      _isLoading = false;
    });
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.updateProfile(
      name: _usernameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Profile updated successfully',
          backgroundColor: AppTheme.successColor,
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          result['message'] as String? ?? 'Failed to update profile',
          backgroundColor: AppTheme.errorColor,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(
          color: Color(0xFFb3ee9a),
          borderRadius: BorderRadius.all(Radius.circular(40)),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // White bottom section
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              top: 176,
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

            // Back button (arrow icon)
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

            // Title (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 64,
              child: const SizedBox(
                width: 148,
                child: Center(
                  child: Text(
                    'Edit my Profile',
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
            ),

            // Profile picture (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 117,
              child: Center(
                child: Container(
                  width: 117,
                  height: 117,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: _user?.profilePicture != null
                        ? DecorationImage(
                            image: NetworkImage(_user!.profilePicture!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: _user?.profilePicture == null ? const Color(0xFF6CB5FD) : null,
                  ),
                  child: _user?.profilePicture == null
                      ? Center(
                          child: Text(
                            _user?.name.isNotEmpty == true
                                ? _user!.name.substring(0, 1).toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 48,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : null,
                ),
              ),
            ),

            // Camera icon on profile picture (bottom right of profile picture)
            Positioned(
              left: 0,
              right: 0,
              top: 209,
              child: Center(
                child: Transform.translate(
                  offset: const Offset(46, 46), // Position at bottom right of 117x117 circle
                  child: GestureDetector(
                    onTap: () {
                      // TODO: Open image picker
                    },
                    child: Container(
                      width: 25,
                      height: 25,
                      decoration: const BoxDecoration(
                        color: Color(0xFFb3ee9a),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 13.571,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // User name (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 267,
              child: Center(
                child: Text(
                  _user?.name ?? 'User',
                  style: const TextStyle(
                    color: Color(0xFF093030),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            // User ID (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 288,
              child: Center(
                child: Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(
                        text: 'ID: ',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextSpan(
                        text: _user?.id.toString() ?? '25030024',
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
            ),

            // Account settings header
            const Positioned(
              left: 38,
              top: 331,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 177,
                    height: 25,
                    child: Text(
                      'account settings',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 20,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        height: 1.10,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Dark theme toggle switch (positioned on right)
            Positioned(
              right: 36,
              top: 650,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Switch(
                  value: _darkThemeEnabled,
                  onChanged: (value) {
                    setState(() {
                      _darkThemeEnabled = value;
                    });
                  },
                  activeColor: const Color(0xFFb3ee9a),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: const Color(0xFFDFF7E2),
                ),
              ),
            ),

            // Push notifications toggle switch (positioned on right)
            Positioned(
              right: 36,
              top: 702,
              child: Transform.rotate(
                angle: 3.14159, // 180 degrees in radians
                child: Opacity(
                  opacity: _pushNotificationsEnabled ? 1.0 : 0.51,
                  child: Switch(
                    value: _pushNotificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        _pushNotificationsEnabled = value;
                      });
                    },
                    activeColor: const Color(0xFFb3ee9a),
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: const Color(0xFFDFF7E2),
                  ),
                ),
              ),
            ),

            // Form fields section
            Positioned(
              left: 38,
              top: 386,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username field
                    const SizedBox(
                      width: 130,
                      height: 14,
                      child: Text(
                        'Username',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: 356,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _usernameController,
                        style: const TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a username';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 61),

                    // Phone field
                    const Text(
                      'phone',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: 356,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _phoneController,
                        style: const TextStyle(
                          color: Color(0xFF0E3E3E),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 61),

                    // Email field
                    const Text(
                      'email address',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 13),
                    Container(
                      width: 356,
                      height: 32,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDFF7E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextFormField(
                        controller: _emailController,
                        style: const TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 13,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w300,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an email address';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 61),

                    // Dark theme toggle
                    const SizedBox(
                      width: 174,
                      height: 14,
                      child: Text(
                        'Turn dark Theme',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                    const SizedBox(height: 61),

                    // Push notifications toggle
                    const SizedBox(
                      width: 150,
                      height: 14,
                      child: Text(
                        'push notifications',
                        style: TextStyle(
                          color: Color(0xFF093030),
                          fontSize: 15,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Update Profile button (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 754,
              child: Center(
                child: GestureDetector(
                  onTap: _updateProfile,
                  child: Container(
                    width: 169,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFb3ee9a),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 15,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Notification icon (bell)
            Positioned(
              right: 36,
              top: 61,
              child: GestureDetector(
                onTap: () {
                  context.go('/notifications');
                },
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDFF7E2),
                    borderRadius: BorderRadius.all(Radius.circular(25.71)),
                  ),
                  child: Center(
                    child: Stack(
                      children: [
                        // Bell shape
                        Positioned(
                          left: 7.71,
                          top: 5.14,
                          child: Container(
                            width: 14.57,
                            height: 18.86,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: const Color(0xFF052224),
                                width: 1.29,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                                bottomLeft: Radius.circular(2),
                                bottomRight: Radius.circular(2),
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Bell clapper
                                Positioned(
                                  left: 6,
                                  bottom: 2,
                                  child: Container(
                                    width: 2.5,
                                    height: 3,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF052224),
                                      borderRadius: BorderRadius.circular(1),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
