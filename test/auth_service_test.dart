import 'dart:convert';

import 'package:bahasha/core/network/api_client.dart';
import 'package:bahasha/core/storage/token_storage.dart';
import 'package:bahasha/features/auth/data/auth_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class MemoryTokenStorage implements TokenStorage {
  StoredTokens? tokens;
  String id = '4da812e9-f953-4db0-b331-b8128ccbb42f';

  @override
  Future<void> clearTokens() async => tokens = null;

  @override
  Future<String> installationId() async => id;

  @override
  Future<StoredTokens?> readTokens() async => tokens;

  @override
  Future<void> saveTokens(StoredTokens value) async => tokens = value;
}

void main() {
  test('login sends device context and stores returned tokens', () async {
    late Map<String, dynamic> requestBody;
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/auth/token');
      requestBody = jsonDecode(request.body) as Map<String, dynamic>;
      return http.Response(
        jsonEncode({
          'access_token': 'access-token',
          'refresh_token': 'refresh-token',
          'token_type': 'Bearer',
          'expires_in': 900,
          'member': {
            'id': 'member-id',
            'full_name': 'Amina Mushi',
            'approval_status': 'approved',
          },
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final storage = MemoryTokenStorage();
    final service = AuthService(
      apiClient: ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: client,
      ),
      tokenStorage: storage,
    );

    final session = await service.login('amina', 'secret-password');

    expect(session.member.fullName, 'Amina Mushi');
    expect(storage.tokens?.accessToken, 'access-token');
    expect(requestBody['identifier'], 'amina');
    expect(
      (requestBody['device'] as Map<String, dynamic>)['installation_id'],
      storage.id,
    );
  });

  test('logout clears tokens even when the server is unavailable', () async {
    final client = MockClient((request) async {
      throw http.ClientException('offline');
    });
    final storage = MemoryTokenStorage()
      ..tokens = const StoredTokens(
        accessToken: 'access-token',
        refreshToken: 'refresh-token',
      );
    final service = AuthService(
      apiClient: ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: client,
      ),
      tokenStorage: storage,
    );

    await expectLater(service.logout(), throwsA(isA<Exception>()));
    expect(storage.tokens, isNull);
  });
}
