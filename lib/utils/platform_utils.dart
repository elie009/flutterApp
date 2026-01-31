// Conditional export: use IO version when dart:io is available (mobile/desktop), stub on web.
export 'platform_utils_stub.dart' if (dart.library.io) 'platform_utils_io.dart';
