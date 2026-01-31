import 'package:local_auth/local_auth.dart';
import '../utils/platform_utils.dart' as platform_utils;

/// Service for face and fingerprint authentication (mobile only).
class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// True when running on Android or iOS (not web/desktop).
  static bool get isMobile => platform_utils.isMobile;

  /// Returns true if device supports and has biometrics (face or fingerprint) available.
  static Future<bool> get hasBiometricSupport async {
    if (!isMobile) return false;
    try {
      final canCheck = await _auth.canCheckBiometrics;
      if (!canCheck) return false;
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      final types = await _auth.getAvailableBiometrics();
      return types.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Authenticate with system prompt (face or fingerprint).
  /// [reason] is shown in the system dialog (e.g. "Unlock UtilityHub360").
  /// Returns true if authentication succeeded.
  static Future<bool> authenticate({
    String reason = 'Unlock UtilityHub360',
  }) async {
    if (!isMobile) return false;
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}
