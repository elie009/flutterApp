import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../services/biometric_service.dart';
import '../../services/storage_service.dart';
import '../../utils/navigation_helper.dart';
import '../../utils/theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final biometricEnabled = StorageService.getBool('biometric_enabled') ?? false;
    if (mounted) {
      setState(() {
        _biometricEnabled = biometricEnabled;
      });
    }
  }

  Future<void> _handleLogout() async {
    debugPrint('🚪 Logout button pressed');
    
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
      debugPrint('🚪 User confirmed logout');
      
      // Save the navigator before async gap
      final navigator = GoRouter.of(context);
      
      // Perform logout (clears tokens and user state)
      await AuthService.logout();
      
      debugPrint('🚪 Navigating to /landing');
      // Force navigation to landing page using saved navigator
      // The router redirect will handle the rest
      navigator.go('/landing');
      debugPrint('🚪 Navigation command sent');
    } else {
      debugPrint('🚪 User cancelled logout');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.getCurrentUser();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/profile');
            }
          },
        ),
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          // Profile Section
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.person),
            ),
            title: Text(
              user?.name ?? 'User',
              style: const TextStyle(color: Color(0xFF093030)),
            ),
            subtitle: Text(
              user?.email ?? '',
              style: const TextStyle(color: Color(0xFF093030)),
            ),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'profile');
            },
          ),
          const Divider(),
          // Menu Items
          _buildSectionHeader('General'),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'profile');
            },
          ),
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Bank Accounts', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'banks');
            },
          ),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Income Sources', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'income');
            },
          ),
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text('Loans', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'loans');
            },
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notifications', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'notifications');
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Transaction Categories', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () {
              NavigationHelper.navigateTo(context, 'transaction-categories');
            },
          ),
          const Divider(),
          _buildSectionHeader('Security'),
          if (BiometricService.isAndroid)
            SwitchListTile(
              secondary: const Icon(Icons.fingerprint),
              title: const Text('Biometric Authentication', style: TextStyle(color: Color(0xFF093030))),
              subtitle: const Text('Use fingerprint or face ID to login (Android only)', style: TextStyle(color: Color(0xFF093030))),
              value: _biometricEnabled,
              onChanged: (value) async {
                // Save the scaffold messenger before async gap
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                
                setState(() {
                  _biometricEnabled = value;
                });
                await StorageService.saveBool('biometric_enabled', value);
                
                if (mounted) {
                  NavigationHelper.showSnackBar(
                    context,
                    value ? 'Biometric authentication enabled' : 'Biometric authentication disabled',
                    backgroundColor: value ? AppTheme.successColor : Colors.grey,
                  );
                }
              },
            ),
          const Divider(),
          _buildSectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('App Version', style: TextStyle(color: Color(0xFF093030))),
            subtitle: Text('1.0.0', style: TextStyle(color: Color(0xFF093030))),
            trailing: SizedBox(width: 24),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),         ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help & Support', style: TextStyle(color: Color(0xFF093030))),
            trailing: const SizedBox(
              width: 24,
              child: Icon(Icons.chevron_right, size: 24),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: () => context.pushNamed('help'),
          ),
          const Divider(),
          // Logout
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

