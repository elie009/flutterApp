import 'package:flutter/material.dart';
import 'dart:async';
import 'auth_service.dart';
import 'storage_service.dart';

/// Centralized session manager that monitors authentication state
/// and automatically redirects to login if session expires
class SessionManager {
  static Timer? _sessionCheckTimer;
  static bool _isChecking = false;
  static final List<VoidCallback> _sessionExpiredCallbacks = [];
  
  /// Session check interval (default: 30 seconds)
  static const Duration _checkInterval = Duration(seconds: 30);
  
  /// Initialize session monitoring
  static void init() {
    debugPrint('📱 SessionManager: Initializing session monitoring');
    startSessionMonitoring();
  }
  
  /// Start monitoring session validity
  static void startSessionMonitoring() {
    // Cancel existing timer if any
    _sessionCheckTimer?.cancel();
    
    debugPrint('📱 SessionManager: Starting periodic session checks (every ${_checkInterval.inSeconds}s)');
    
    // Check session immediately
    _checkSession();
    
    // Schedule periodic checks
    _sessionCheckTimer = Timer.periodic(_checkInterval, (timer) {
      _checkSession();
    });
  }
  
  /// Stop monitoring session
  static void stopSessionMonitoring() {
    debugPrint('📱 SessionManager: Stopping session monitoring');
    _sessionCheckTimer?.cancel();
    _sessionCheckTimer = null;
  }
  
  /// Check if session is still valid
  static Future<void> _checkSession() async {
    if (_isChecking) return; // Prevent concurrent checks
    
    _isChecking = true;
    
    try {
      // Check if user is authenticated
      if (!AuthService.isAuthenticated()) {
        debugPrint('⚠️ SessionManager: No active session detected');
        _isChecking = false;
        return;
      }
      
      // Verify token is still valid by checking storage
      final token = await StorageService.getToken();
      
      if (token == null || token.isEmpty) {
        debugPrint('⚠️ SessionManager: Token not found, session expired');
        await _handleSessionExpired();
        _isChecking = false;
        return;
      }
      
      // Optional: Verify token with backend (uncomment if needed)
      // final isValid = await AuthService.verifyTokenValid();
      // if (!isValid) {
      //   debugPrint('⚠️ SessionManager: Token validation failed');
      //   await _handleSessionExpired();
      // }
      
      debugPrint('✅ SessionManager: Session is valid');
    } catch (e) {
      debugPrint('❌ SessionManager: Error checking session: $e');
    } finally {
      _isChecking = false;
    }
  }
  
  /// Handle session expiration
  static Future<void> _handleSessionExpired() async {
    debugPrint('🔒 SessionManager: Session expired, triggering logout');
    
    // Clear session
    await AuthService.logout();
    
    // Notify all listeners
    for (final callback in _sessionExpiredCallbacks) {
      callback();
    }
  }
  
  /// Add callback to be notified when session expires
  static void addSessionExpiredCallback(VoidCallback callback) {
    _sessionExpiredCallbacks.add(callback);
  }
  
  /// Remove session expired callback
  static void removeSessionExpiredCallback(VoidCallback callback) {
    _sessionExpiredCallbacks.remove(callback);
  }
  
  /// Manually check session validity
  static Future<bool> checkSessionValidity() async {
    if (!AuthService.isAuthenticated()) {
      return false;
    }
    
    final token = await StorageService.getToken();
    if (token == null || token.isEmpty) {
      return false;
    }
    
    // Optional: Verify with backend
    // return await AuthService.verifyTokenValid();
    
    return true;
  }
  
  /// Dispose session manager
  static void dispose() {
    stopSessionMonitoring();
    _sessionExpiredCallbacks.clear();
  }
}
