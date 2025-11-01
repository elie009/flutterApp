import '../models/user.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  static User? _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // Initialize API service
  static void init() {
    ApiService().init();
  }

  // Check if user is authenticated
  static bool isAuthenticated() {
    return _currentUser != null;
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

        // Save user data
        await StorageService.saveString(
          AppConfig.userKey,
          userData.toString(),
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
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService().post(
        '/Auth/register',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
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
    _currentUser = null;
    await StorageService.clearTokens();
    await ApiService().updateAuthHeader(null);
  }

  // Get user profile
  static Future<User?> getUserProfile() async {
    try {
      final response = await ApiService().get('/UserProfile');
      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
        return _currentUser;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Update user profile
  static Future<Map<String, dynamic>> updateProfile({
    String? jobTitle,
    String? company,
    String? preferredCurrency,
  }) async {
    try {
      final response = await ApiService().put(
        '/UserProfile',
        data: {
          if (jobTitle != null) 'jobTitle': jobTitle,
          if (company != null) 'company': company,
          if (preferredCurrency != null) 'preferredCurrency': preferredCurrency,
        },
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'] as Map<String, dynamic>;
        _currentUser = User.fromJson(userData);
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

