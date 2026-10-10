import 'api_client.dart';
import 'api_exception.dart';

class AuthenticatedApiClient {
  AuthenticatedApiClient({
    required ApiClient apiClient,
    required String? Function() accessToken,
    required Future<String?> Function() refreshAccessToken,
  }) : _apiClient = apiClient,
       _accessToken = accessToken,
       _refreshAccessToken = refreshAccessToken;

  final ApiClient _apiClient;
  final String? Function() _accessToken;
  final Future<String?> Function() _refreshAccessToken;

  Future<Map<String, dynamic>> getJson(String path) {
    return _withRefresh(
      (token) => _apiClient.getJson(path, accessToken: token),
    );
  }

  Future<Map<String, dynamic>> _withRefresh(
    Future<Map<String, dynamic>> Function(String token) request,
  ) async {
    final token = _accessToken();
    if (token == null || token.isEmpty) {
      throw const ApiException(
        code: 'TOKEN_INVALID',
        message: 'Your session has ended. Please sign in again.',
        statusCode: 401,
      );
    }
    try {
      return await request(token);
    } on ApiException catch (error) {
      if (!error.isUnauthorized) rethrow;
      final refreshedToken = await _refreshAccessToken();
      if (refreshedToken == null || refreshedToken.isEmpty) rethrow;
      return request(refreshedToken);
    }
  }
}
