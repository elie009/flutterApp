import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/auth_service.dart';
import '../../utils/navigation_helper.dart';
import '../../widgets/loading_indicator.dart';
import '../../utils/theme.dart';
import '../../widgets/bottom_nav_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  bool _isLoading = false;
  bool _isEditing = false;
  User? _user;

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
      _jobTitleController.text = _user?.jobTitle ?? '';
      _companyController.text = _user?.company ?? '';
      _isLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final result = await AuthService.updateProfile(
      jobTitle: _jobTitleController.text.trim().isEmpty
          ? null
          : _jobTitleController.text.trim(),
      company: _companyController.text.trim().isEmpty
          ? null
          : _companyController.text.trim(),
    );

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    if (result['success'] == true) {
      _user = result['user'] as User;
      if (mounted) {
        NavigationHelper.showSnackBar(
          context,
          'Profile updated successfully',
          backgroundColor: AppTheme.successColor,
        );
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
        body: LoadingIndicator(message: 'Loading profile...'),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          if (_isEditing)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(color: Colors.white),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _jobTitleController.text = _user?.jobTitle ?? '';
                  _companyController.text = _user?.company ?? '';
                });
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _user == null
              ? const Center(child: Text('Failed to load profile'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Picture
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: AppTheme.primaryColor,
                          child: Text(
                            _user!.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              fontSize: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Name (Read-only)
                        TextFormField(
                          initialValue: _user!.name,
                          decoration: const InputDecoration(
                            labelText: 'Name',
                            prefixIcon: Icon(Icons.person),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        // Email (Read-only)
                        TextFormField(
                          initialValue: _user!.email,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.email),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        // Phone (Read-only)
                        TextFormField(
                          initialValue: _user!.phone ?? '',
                          decoration: const InputDecoration(
                            labelText: 'Phone',
                            prefixIcon: Icon(Icons.phone),
                          ),
                          enabled: false,
                        ),
                        const SizedBox(height: 16),
                        // Job Title
                        TextFormField(
                          controller: _jobTitleController,
                          decoration: const InputDecoration(
                            labelText: 'Job Title',
                            prefixIcon: Icon(Icons.work),
                          ),
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        // Company
                        TextFormField(
                          controller: _companyController,
                          decoration: const InputDecoration(
                            labelText: 'Company',
                            prefixIcon: Icon(Icons.business),
                          ),
                          enabled: _isEditing,
                        ),
                        const SizedBox(height: 16),
                        // Preferred Currency
                        TextFormField(
                          initialValue: _user!.preferredCurrency ?? 'PHP',
                          decoration: const InputDecoration(
                            labelText: 'Preferred Currency',
                            prefixIcon: Icon(Icons.currency_exchange),
                          ),
                          enabled: false,
                        ),
                        if (_user!.totalMonthlyIncome != null) ...[
                          const SizedBox(height: 16),
                          TextFormField(
                            initialValue:
                                _user!.totalMonthlyIncome!.toStringAsFixed(2),
                            decoration: const InputDecoration(
                              labelText: 'Total Monthly Income',
                              prefixIcon: Icon(Icons.attach_money),
                            ),
                            enabled: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  @override
  void dispose() {
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }
}

