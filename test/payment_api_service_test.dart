import 'dart:convert';

import 'package:bahasha/core/network/api_client.dart';
import 'package:bahasha/core/network/authenticated_api_client.dart';
import 'package:bahasha/features/payments/data/payment_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('creates an authenticated idempotent mobile-money payment', () async {
    final client = MockClient((request) async {
      expect(request.method, 'POST');
      expect(request.url.path, '/api/v1/payment-intents');
      expect(request.headers['Authorization'], 'Bearer access-token');
      expect(
        request.headers['Idempotency-Key'],
        '11111111-1111-4111-8111-111111111111',
      );
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['provider'], 'vodacom_m_pesa');
      expect(body['payer_phone_number'], '0712345678');
      expect(body['allocations'], [
        {'contribution_week_id': 'week-id', 'amount': '5000.00'},
      ]);
      return http.Response(
        jsonEncode({
          'id': 'intent-id',
          'reference': 'PAY-2026-0001',
          'status': 'pending_customer_action',
          'provider': 'vodacom_m_pesa',
          'amount': {'amount': '5000.00', 'currency': 'TZS'},
          'contribution_ids': [],
          'next_action': {
            'type': 'approve_mobile_money_prompt',
            'message': 'Approve the payment request on your phone.',
          },
        }),
        202,
      );
    });
    final service = _service(client);

    final intent = await service.createIntent(
      categoryId: 'category-id',
      financialYearId: 'year-id',
      contributionWeekId: 'week-id',
      provider: 'vodacom_m_pesa',
      payerPhoneNumber: '0712345678',
      amount: '5000.00',
      idempotencyKey: '11111111-1111-4111-8111-111111111111',
    );

    expect(intent.status, 'pending_customer_action');
    expect(intent.nextAction?.type, 'approve_mobile_money_prompt');
  });

  test('loads enabled providers and polls a successful payment', () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls += 1;
      if (request.url.path == '/api/v1/payment-methods') {
        return http.Response(
          jsonEncode({
            'items': [
              {
                'key': 'mobile_money',
                'name': 'Mobile money',
                'providers': ['vodacom_m_pesa', 'airtel_money', 'mixx_by_yas'],
                'currency': 'TZS',
                'enabled': true,
              },
            ],
          }),
          200,
        );
      }
      expect(request.url.path, '/api/v1/payment-intents/intent-id');
      return http.Response(
        jsonEncode({
          'id': 'intent-id',
          'reference': 'PAY-2026-0001',
          'status': 'succeeded',
          'provider': 'vodacom_m_pesa',
          'amount': {'amount': '5000.00', 'currency': 'TZS'},
          'contribution_ids': ['contribution-id'],
          'next_action': null,
        }),
        200,
      );
    });
    final service = _service(client);

    final methods = await service.paymentMethods();
    final intent = await service.paymentIntent('intent-id');

    expect(methods.single.providers, hasLength(3));
    expect(intent.isSuccessful, isTrue);
    expect(intent.contributionIds, ['contribution-id']);
    expect(calls, 2);
  });
}

PaymentApiService _service(http.Client client) {
  return PaymentApiService(
    AuthenticatedApiClient(
      apiClient: ApiClient(
        baseUrl: 'http://localhost:8000/api/v1',
        httpClient: client,
      ),
      accessToken: () => 'access-token',
      refreshAccessToken: () async => null,
    ),
  );
}
