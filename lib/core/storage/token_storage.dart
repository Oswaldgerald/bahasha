import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

class StoredTokens {
  const StoredTokens({required this.accessToken, required this.refreshToken});

  final String accessToken;
  final String refreshToken;
}

abstract class TokenStorage {
  Future<StoredTokens?> readTokens();
  Future<void> saveTokens(StoredTokens tokens);
  Future<void> clearTokens();
  Future<String> installationId();
}

class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  static const _accessTokenKey = 'bahasha_access_token';
  static const _refreshTokenKey = 'bahasha_refresh_token';
  static const _installationIdKey = 'bahasha_installation_id';

  final FlutterSecureStorage _storage;

  @override
  Future<StoredTokens?> readTokens() async {
    final values = await Future.wait([
      _storage.read(key: _accessTokenKey),
      _storage.read(key: _refreshTokenKey),
    ]);
    if (values[0] == null || values[1] == null) return null;
    return StoredTokens(accessToken: values[0]!, refreshToken: values[1]!);
  }

  @override
  Future<void> saveTokens(StoredTokens tokens) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: tokens.accessToken),
      _storage.write(key: _refreshTokenKey, value: tokens.refreshToken),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
    ]);
  }

  @override
  Future<String> installationId() async {
    final existing = await _storage.read(key: _installationIdKey);
    if (existing != null) return existing;
    final generated = const Uuid().v4();
    await _storage.write(key: _installationIdKey, value: generated);
    return generated;
  }
}
