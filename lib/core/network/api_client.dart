import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_exception.dart';

class ApiClient {
  ApiClient({required String baseUrl, http.Client? httpClient})
    : _baseUrl = Uri.parse(baseUrl),
      _httpClient = httpClient ?? http.Client();

  final Uri _baseUrl;
  final http.Client _httpClient;
  static const _requestTimeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? accessToken,
  }) async {
    return _send(
      () => _httpClient.get(_uri(path), headers: _headers(accessToken)),
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? accessToken,
  }) async {
    return _send(
      () => _httpClient.post(
        _uri(path),
        headers: _headers(accessToken),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path.substring(1) : path;
    return Uri.parse('${_baseUrl.toString()}/$normalizedPath');
  }

  Map<String, String> _headers(String? accessToken) {
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken',
    };
  }

  Future<Map<String, dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    late http.Response response;
    try {
      response = await request().timeout(_requestTimeout);
    } on http.ClientException {
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message:
            'Unable to connect to Bahasha. Check your connection and retry.',
      );
    } on TimeoutException {
      throw const ApiException(
        code: 'NETWORK_ERROR',
        message: 'Bahasha took too long to respond. Please retry.',
      );
    }

    final payload = _decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return payload;
    }

    final rawError = payload['error'];
    if (rawError is Map<String, dynamic>) {
      throw ApiException(
        code: rawError['code']?.toString() ?? 'REQUEST_FAILED',
        message:
            rawError['message']?.toString() ??
            'The request could not be completed.',
        statusCode: response.statusCode,
        fields: _readFields(rawError['fields']),
      );
    }
    throw ApiException(
      code: 'REQUEST_FAILED',
      message: 'The request could not be completed.',
      statusCode: response.statusCode,
    );
  }

  Map<String, dynamic> _decode(String body) {
    if (body.trim().isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(body);
      return decoded is Map<String, dynamic> ? decoded : <String, dynamic>{};
    } on FormatException {
      return <String, dynamic>{};
    }
  }

  Map<String, List<String>> _readFields(dynamic rawFields) {
    if (rawFields is! Map) return const {};
    return rawFields.map((key, value) {
      final messages = value is List
          ? value.map((item) => item.toString()).toList()
          : <String>[value.toString()];
      return MapEntry(key.toString(), messages);
    });
  }

  void close() => _httpClient.close();
}
