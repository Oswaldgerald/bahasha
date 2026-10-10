import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const _configuredApiBaseUrl = String.fromEnvironment('API_BASE_URL');

  static String get apiBaseUrl {
    final baseUrl = _resolvedApiBaseUrl;
    if (kReleaseMode && Uri.parse(baseUrl).scheme != 'https') {
      throw StateError('Production API_BASE_URL must use HTTPS.');
    }
    return baseUrl;
  }

  static String get _resolvedApiBaseUrl {
    if (_configuredApiBaseUrl.isNotEmpty) {
      return _withoutTrailingSlash(_configuredApiBaseUrl);
    }
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000/api/v1';
    }
    return 'http://127.0.0.1:8000/api/v1';
  }

  static String _withoutTrailingSlash(String value) {
    return value.endsWith('/') ? value.substring(0, value.length - 1) : value;
  }
}
