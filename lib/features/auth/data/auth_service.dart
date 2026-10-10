import 'package:flutter/foundation.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/storage/token_storage.dart';
import '../domain/auth_session.dart';

abstract class AuthGateway {
  Future<AuthSession> login(String identifier, String password);
  Future<AuthSession?> restoreSession();
  Future<void> logout();
  Future<String> requestPasswordReset(String email);
}

class AuthService implements AuthGateway {
  AuthService({
    required ApiClient apiClient,
    required TokenStorage tokenStorage,
  }) : _apiClient = apiClient,
       _tokenStorage = tokenStorage;

  factory AuthService.create() {
    return AuthService(
      apiClient: ApiClient(baseUrl: AppConfig.apiBaseUrl),
      tokenStorage: SecureTokenStorage(),
    );
  }

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> login(String identifier, String password) async {
    final installationId = await _tokenStorage.installationId();
    final payload = await _apiClient.postJson(
      '/auth/token',
      body: {
        'identifier': identifier.trim(),
        'password': password,
        'device': {
          'installation_id': installationId,
          'platform': _platformName,
          'app_version': '1.0.0',
          'device_name': '',
        },
      },
    );
    final session = AuthSession.fromTokenResponse(payload);
    await _save(session);
    return session;
  }

  @override
  Future<AuthSession?> restoreSession() async {
    final stored = await _tokenStorage.readTokens();
    if (stored == null) return null;
    try {
      final profile = await _apiClient.getJson(
        '/me',
        accessToken: stored.accessToken,
      );
      return AuthSession(
        accessToken: stored.accessToken,
        refreshToken: stored.refreshToken,
        member: AuthMember.fromJson(profile),
      );
    } on ApiException catch (error) {
      if (!error.isUnauthorized) rethrow;
      return _refresh(stored.refreshToken);
    }
  }

  Future<AuthSession> _refresh(String refreshToken) async {
    try {
      final payload = await _apiClient.postJson(
        '/auth/token/refresh',
        body: {'refresh_token': refreshToken},
      );
      final session = AuthSession.fromTokenResponse(payload);
      await _save(session);
      return session;
    } on ApiException {
      await _tokenStorage.clearTokens();
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    final stored = await _tokenStorage.readTokens();
    try {
      if (stored != null) {
        await _apiClient.postJson(
          '/auth/logout',
          accessToken: stored.accessToken,
        );
      }
    } finally {
      await _tokenStorage.clearTokens();
    }
  }

  @override
  Future<String> requestPasswordReset(String email) async {
    final payload = await _apiClient.postJson(
      '/auth/password/forgot',
      body: {'email': email.trim()},
    );
    return payload['message']?.toString() ??
        'If the account exists, password reset instructions have been sent.';
  }

  Future<void> _save(AuthSession session) {
    return _tokenStorage.saveTokens(
      StoredTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      ),
    );
  }

  String get _platformName {
    if (defaultTargetPlatform == TargetPlatform.iOS) return 'ios';
    return 'android';
  }
}
