import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import '../config/app_config.dart';
import 'storage_service.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  late Dio _dio;
  Dio get dio => _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.baseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors
    _dio.interceptors.add(_AuthInterceptor());
    _dio.interceptors.add(
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
      ),
    );
  }

  // Update authorization header
  Future<void> updateAuthHeader(String? token) async {
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      // Reset logout flag when new token is set
      _AuthInterceptor.resetLogoutFlag();
    } else {
      _dio.options.headers.remove('Authorization');
    }
  }

  // Reset logout flag (public method for AuthInterceptor)
  static void resetLogoutFlag() {
    _AuthInterceptor.resetLogoutFlag();
  }

  // GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error handler
  Exception _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final message = error.response!.data['message'] as String? ?? 
          'An error occurred';
      
      switch (statusCode) {
        case 400:
          return Exception('Bad Request: $message');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 403:
          return Exception('Forbidden: $message');
        case 404:
          return Exception('Not Found: $message');
        case 429:
          return Exception('Too many requests. Please wait a moment.');
        case 500:
          return Exception('Server Error: Please try again later');
        case 503:
          return Exception('Service Unavailable: Please try again later');
        default:
          return Exception(message);
      }
    } else {
      return Exception('Network error: ${error.message}');
    }
  }
}

// Auth Interceptor to add token and handle token refresh
class _AuthInterceptor extends Interceptor {
  static bool _isHandling401 = false;
  static bool _hasLoggedOut = false;

  static void resetLogoutFlag() {
    _hasLoggedOut = false;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await StorageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      // Don't auto-logout when already logging out to prevent infinite loops
      final requestPath = err.requestOptions.path;
      
      // Skip if:
      // 1. Already handling a 401 error
      // 2. Already logged out in this session
      // 3. This is the logout request itself
      if (!requestPath.contains('/auth/logout') && 
          !_isHandling401 && 
          !_hasLoggedOut) {
        _isHandling401 = true;
        _hasLoggedOut = true;
        
        try {
          // Token expired or invalid, logout user
          await AuthService.logout();
        } catch (e) {
          // Even if logout fails, we don't want to try again
          _hasLoggedOut = true;
        } finally {
          _isHandling401 = false;
        }
      }
    }
    handler.next(err);
  }
}

