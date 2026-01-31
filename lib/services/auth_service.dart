import 'package:flutter/material.dart';
import '../models/user.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';

class AuthService {
  static User? _currentUser;
  static bool get isLoggedIn => _currentUser != null;
  static bool _isLoggingOut = false;

  // Initialize API service and restore user session
  static Future<void> init() async {
    ApiService().init();
    // Restore user session from storage
    await _restoreUserFromStorage();
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _currentUser != null;
  }

  // Check authentication and redirect to login if not authenticated
  static Future<bool> checkAuthAndRedirect(BuildContext context) async {
    if (!isAuthenticated()) {
      // Clear any stale data
      await logout();
      // Redirect to login
      if (context.mounted) {
        context.go('/landing');
      }
      return false;
    }
    return true;
  }

  // Verify token is still valid
  static Future<bool> verifyTokenValid() async {
    try {
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return false;
      }
      
      // Try to get user profile to verify token
      final user = await getUserProfile();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  // Restore user from storage
  static Future<void> _restoreUserFromStorage() async {
    try {
      // Check if we have a token
      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        return;
      }

      // Try to restore user data
      final userDataString = StorageService.getString(AppConfig.userKey);
      if (userDataString != null && userDataString.isNotEmpty) {
        try {
          final userData = jsonDecode(userDataString) as Map<String, dynamic>;
          _currentUser = User.fromJson(userData);
          // Update API service auth header
          await ApiService().updateAuthHeader(token);
        } catch (e) {
          // If user data is corrupted, try to fetch from API
          final user = await getUserProfile();
          if (user != null) {
            _currentUser = user;
          }
        }
      } else {
        // No user data but have token, try to fetch from API
        final user = await getUserProfile();
        if (user != null) {
          _currentUser = user;
        }
      }
    } catch (e) {
      // Silently fail - user will need to login again
      _currentUser = null;
    }
  }

  // Get current user
  static User? getCurrentUser() {
    return _currentUser;
  }

  // Login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await ApiService().post(
        '/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final refreshToken = data['refreshToken'] as String;
        final userData = data['user'] as Map<String, dynamic>;

        // Save tokens
        await StorageService.saveToken(token);
        await StorageService.saveRefreshToken(refreshToken);

        // Update API service auth header
        await ApiService().updateAuthHeader(token);

        // Set current user
        _currentUser = User.fromJson(userData);

        // Save user data as JSON
        await StorageService.saveString(
          AppConfig.userKey,
          jsonEncode(userData),
        );

        return {
          'success': true,
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] as String? ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String country,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService().post(
        '/Auth/register',
        data: {
          'name': name,
          'email': email,
          'country': country,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] as String? ?? 'Registration successful',
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] as String? ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }

  // Refresh token
  static Future<bool> refreshToken() async {
    try {
      final refreshTokenValue = await StorageService.getRefreshToken();
      if (refreshTokenValue == null) {
        return false;
      }

      final response = await ApiService().post(
        '/Auth/refresh',
        data: {
          'refreshToken': refreshTokenValue,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final token = data['token'] as String;
        final newRefreshToken = data['refreshToken'] as String;

        await StorageService.saveToken(token);
        await StorageService.saveRefreshToken(newRefreshToken);
        await ApiService().updateAuthHeader(token);

        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Logout
  static Future<void> logout() async {
    if (_isLoggingOut) {
      debugPrint('⚠️ Logout already in progress, skipping...');
      return;
    }
    
    _isLoggingOut = true;
    debugPrint('🔓 Starting logout...');
    _currentUser = null;
    debugPrint('🔓 Cleared current user');
    await StorageService.clearTokens();
    debugPrint('🔓 Cleared tokens');
    // Clear user data from storage
    await StorageService.remove(AppConfig.userKey);
    debugPrint('🔓 Cleared user data from storage');
    await ApiService().updateAuthHeader(null);
    debugPrint('🔓 Cleared API auth header');
    debugPrint('✅ Logout complete - isAuthenticated: ${isAuthenticated()}');
    _isLoggingOut = false;
  }

  // Get user profile
  static Future<User?> getUserProfile() async {
    try {
      final response = await ApiService().get('/UserProfile');
      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        await StorageService.saveString(AppConfig.userKey, jsonEncode(userData));
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? jobTitle,
    String? company,
    String? preferredCurrency,
  }) async {
    try {
      final response = await ApiService().put(
        '/UserProfile',
        data: {
          if (name != null) 'name': name,
          if (phone != null) 'phone': phone,
          if (email != null) 'email': email,
          if (jobTitle != null) 'jobTitle': jobTitle,
          if (company != null) 'company': company,
          if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
        },
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        await StorageService.saveString(AppConfig.userKey, jsonEncode(userData));
        return {
          'success': true,
          'user': _currentUser,
        };
      } else {
        return {
          'success': false,
          'message': response.data['message'] as String? ?? 'Update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': e.toString().replaceAll('Exception: ', ''),
      };
    }
  }
}

