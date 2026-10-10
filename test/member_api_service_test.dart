import 'dart:convert';

import 'package:bahasha/core/network/api_client.dart';
import 'package:bahasha/core/network/authenticated_api_client.dart';
import 'package:bahasha/features/contributions/data/member_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('bootstrap parses configurable category data', () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/v1/bootstrap');
      expect(request.headers['Authorization'], 'Bearer access-token');
      return http.Response(
        jsonEncode({
          'member': {
            'id': 'member-id',
            'full_name': 'Herman John',
            'bahasha_number': '1532',
            'photo_url': null,
            'church': {'id': 'church-id', 'code': '001', 'name': 'Kijitonyama'},
          },
          'active_period': {
            'financial_year': {'id': 'year-id', 'year': 2026},
            'week': {
              'id': 'week-id',
              'number': 41,
              'sunday_date': '2026-10-11',
              'is_closed': false,
            },
          },
          'categories': [
            {
              'id': 'category-id',
              'key': 'ahadi',
              'labels': {'default': 'Ahadi', 'sw': 'Ahadi'},
              'description': 'Weekly promise offerings.',
              'icon': 'hand-heart',
              'color': '#A844B7',
              'frequency': 'weekly',
              'payments_enabled': true,
              'allows_catch_up': true,
              'missing_weeks_count': 2,
              'total_contributed': {'amount': '25000.00', 'currency': 'TZS'},
              'amount_guidance': {
                'suggested': {'amount': '5000.00', 'currency': 'TZS'},
                'minimum': null,
                'maximum': null,
              },
            },
          ],
          'unread_notifications_count': 1,
          'capabilities': {'payments_enabled': false},
        }),
        200,
      );
    });
    final service = MemberApiService(
      AuthenticatedApiClient(
        apiClient: ApiClient(
          baseUrl: 'http://localhost:8000/api/v1',
          httpClient: client,
        ),
        accessToken: () => 'access-token',
        refreshAccessToken: () async => null,
      ),
    );

    final result = await service.bootstrap();

    expect(result.member.fullName, 'Herman John');
    expect(result.activePeriod.week?.number, 41);
    expect(result.categories.single.totalContributed.amount, 25000);
    expect(result.categories.single.suggestedAmount?.amount, 5000);
  });

  test('authenticated client refreshes an expired access token once', () async {
    var token = 'expired-token';
    var calls = 0;
    final client = MockClient((request) async {
      calls += 1;
      if (request.headers['Authorization'] == 'Bearer expired-token') {
        return http.Response(
          jsonEncode({
            'error': {
              'code': 'TOKEN_EXPIRED',
              'message': 'Expired',
              'fields': {},
            },
          }),
          401,
        );
      }
      return http.Response(jsonEncode({'ok': true}), 200);
    });
    final authenticated = AuthenticatedApiClient(
      apiClient: ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: client,
      ),
      accessToken: () => token,
      refreshAccessToken: () async {
        token = 'fresh-token';
        return token;
      },
    );

    final response = await authenticated.getJson('/bootstrap');

    expect(response['ok'], isTrue);
    expect(calls, 2);
  });
}
