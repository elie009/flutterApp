import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

/// Provides a stable device identifier for registering the device with the backend.
class DeviceService {
  static final DeviceInfoPlugin _plugin = DeviceInfoPlugin();

  /// Returns a stable device ID (Android: fingerprint or model+device, iOS: identifierForVendor).
  /// Returns null on web or if unavailable.
  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final android = await _plugin.androidInfo;
        // Prefer fingerprint (unique per build); fallback to model+device for recognition
        final id = android.fingerprint.isNotEmpty
            ? android.fingerprint
            : '${android.manufacturer}_${android.model}_${android.device}';
        return id.isNotEmpty ? id : null;
      }
      if (Platform.isIOS) {
        final ios = await _plugin.iosInfo;
        return ios.identifierForVendor;
      }
    } catch (_) {}
    return null;
  }

  /// Returns platform string: 'android', 'ios', or 'unknown'.
  static String get platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }
}
