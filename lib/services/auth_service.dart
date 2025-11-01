import '../models/user.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'storage_service.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

class AuthService {
  static User? _currentUser;
  static bool get isLoggedIn => _currentUser != null;

  // Initialize API service
  static void init() {
    ApiService().init();
  }

  // Restore session from storage
  static Future<void> restoreSession() async {
    final token = await StorageService.getToken();
    if (token != null) {
      // Update API service auth header
      await ApiService().updateAuthHeader(token);
      
      // Try to get user profile to restore session
      try {
        final user = await getUserProfile();
        if (user != null) {
          _currentUser = user;
        }
      } catch (e) {
        // If getting profile fails, clear tokens (they might be expired)
        await clearTokens();
      }
    }
  }

  // Clear tokens (used internally)
  static Future<void> clearTokens() async {
    await StorageService.clearTokens();
    await ApiService().updateAuthHeader(null);
    _currentUser = null;
  }

  // Check if user is authenticated (checks both token and user)
  static Future<bool> isAuthenticated() async {
    if (_currentUser != null) {
      return true;
    }
    // Check if we have a stored token
    final token = await StorageService.getToken();
    if (token != null) {
      // Try to restore session
      await restoreSession();
      return _currentUser != null;
    }
    return false;
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
        '/auth/login',
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
          'message': response.data['message'] as String? ?? 'Login successful',
          'user': _currentUser,
        };
      } else {
        // Handle validation errors
        final errors = response.data['errors'] as List<dynamic>?;
        String message = response.data['message'] as String? ?? 'Login failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
    } on DioException catch (e) {
      // Handle DioException with response data
      if (e.response != null) {
        final responseData = e.response!.data;
        final errors = responseData['errors'] as List<dynamic>?;
        String message = responseData['message'] as String? ?? 'Login failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Register
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    String? phone,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService().post(
        '/auth/register',
        data: {
          'name': name,
          'email': email,
          if (phone != null && phone.isNotEmpty) 'phone': phone,
          'password': password,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.data['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>?;
        if (data != null && data.containsKey('token')) {
          // Auto-login after registration
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
        }
        
        return {
          'success': true,
          'message': response.data['message'] as String? ?? 'Registration successful',
        };
      } else {
        // Handle validation errors
        final errors = response.data['errors'] as List<dynamic>?;
        String message = response.data['message'] as String? ?? 'Registration failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
    } on DioException catch (e) {
      // Handle DioException with response data
      if (e.response != null) {
        final responseData = e.response!.data;
        final errors = responseData['errors'] as List<dynamic>?;
        String message = responseData['message'] as String? ?? 'Registration failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword({
    required String email,
  }) async {
    try {
      final response = await ApiService().post(
        '/auth/forgot-password',
        data: {
          'email': email,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] as String? ?? 
              'If the email exists, a password reset link has been sent.',
        };
      } else {
        // Handle validation errors
        final errors = response.data['errors'] as List<dynamic>?;
        String message = response.data['message'] as String? ?? 'Request failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
    } on DioException catch (e) {
      // Handle DioException with response data
      if (e.response != null) {
        final responseData = e.response!.data;
        final errors = responseData['errors'] as List<dynamic>?;
        String message = responseData['message'] as String? ?? 'Request failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Reset Password
  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String email,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await ApiService().post(
        '/auth/reset-password',
        data: {
          'token': token,
          'email': email,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.data['success'] == true) {
        return {
          'success': true,
          'message': response.data['message'] as String? ?? 
              'Password has been reset successfully.',
        };
      } else {
        // Handle validation errors
        final errors = response.data['errors'] as List<dynamic>?;
        String message = response.data['message'] as String? ?? 'Password reset failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
    } on DioException catch (e) {
      // Handle DioException with response data
      if (e.response != null) {
        final responseData = e.response!.data;
        final errors = responseData['errors'] as List<dynamic>?;
        String message = responseData['message'] as String? ?? 'Password reset failed';
        if (errors != null && errors.isNotEmpty) {
          message = errors.join(', ');
        }
        return {
          'success': false,
          'message': message,
          'errors': errors,
        };
      }
      return {
        'success': false,
        'message': 'Network error: ${e.message}',
      };
    } catch (e) {
      String errorMessage = e.toString().replaceAll('Exception: ', '');
      return {
        'success': false,
        'message': errorMessage,
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
        '/auth/refresh',
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
    try {
      final token = await StorageService.getToken();
      if (token != null) {
        // Try to call logout endpoint (don't wait for response if it fails)
        try {
          await ApiService().post('/auth/logout');
        } catch (e) {
          // Ignore logout API errors, still clear local tokens
        }
      }
    } catch (e) {
      // Ignore errors
    } finally {
      _currentUser = null;
      await clearTokens();
    }
  }

  // Get user profile
  static Future<User?> getUserProfile() async {
    try {
      final response = await ApiService().get('/auth/me');
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

