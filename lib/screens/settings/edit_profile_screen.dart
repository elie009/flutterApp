import 'package:flutter/material.dart';
import '../../utils/theme.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';
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
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: screenWidth,
        height: screenHeight,
        decoration: const BoxDecoration(color: AppTheme.primaryColor),

        child: Stack(
          clipBehavior: Clip.none,
          children: [
           
            // White main content card (rounded top, overlaps header)
            Positioned(
              left: 0,
              bottom: 0,
              right: 0,
              top: 140,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
              ),
            ),
            
            // Back button (white)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).padding.top + 36,
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
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
            // Title centered (white, bold)
            Positioned(
              left: 0,
              right: 0,
              top: MediaQuery.of(context).padding.top + 38,
              child: const Center(
                child: Text(
                  'Edit my Profile',
                  style: TextStyle(
                    color: Color(0xFF052224),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            // Notification bell (white circle with dark-outlined bell)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).padding.top + 32,
              child: GestureDetector(
                onTap: () => context.push('/notifications'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9E9E9E),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_outlined,
                      color: Color(0xFF424242),
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),

            // Profile picture (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 100,
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
                    color: _user?.profilePicture == null ? const Color(0xFF2196F3) : null,
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
              top: 175,
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
                        color: AppTheme.primaryColor,
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

            // User name with small green icon (centered)
            Positioned(
              left: 0,
              right: 0,
              top: 215,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _user?.name ?? 'User',
                      style: const TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 22,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    
                  ],
                ),
              ),
            ),


            // Form fields section - NOT scrollable, responsive width
            Positioned(
              left: 24,
              right: 24,
              top: 260,
              bottom: 100,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                    // Username field (white bg, border, person icon)
                    _buildLabel('Username'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _usernameController,
                      hint: 'Enter username',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Phone'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _phoneController,
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),

                    _buildLabel('Email Address'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _emailController,
                      hint: 'Enter email address',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
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
                    const SizedBox(height: 20),

                    // Profile Tips section
                    const Text(
                      'Profile Tips:',
                      style: TextStyle(
                        color: Color(0xFF093030),
                        fontSize: 16,
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _profileTip('Keep your information up to date'),
                    const SizedBox(height: 8),
                    _profileTip('Use a valid email for notifications'),
                    const SizedBox(height: 8),
                    _profileTip('Verify your phone number for security'),
                    const SizedBox(height: 18),
                    ],
                  ),
                ),
              ),
            ),

            // Update Profile button (light green, bold white text, full width)
            Positioned(
              left: 24,
              right: 24,
              bottom: 20,
              child: GestureDetector(
                onTap: _updateProfile,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Update Profile',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w700,
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

  static const _inputTextStyle = TextStyle(
    color: Color(0xFF093030),
    fontSize: 15,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
  );

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF093030),
        fontSize: 15,
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        style: _inputTextStyle,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          hintStyle: const TextStyle(
            color: Color(0x80093030),
            fontSize: 15,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF757575), size: 22),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          isDense: false,
        ),
        validator: validator,
      ),
    );
  }

  Widget _profileTip(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFF093030),
              fontSize: 14,
              fontFamily: 'Poppins',
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
