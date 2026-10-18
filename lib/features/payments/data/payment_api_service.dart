import 'package:uuid/uuid.dart';

import '../../../core/network/authenticated_api_client.dart';
import '../domain/payment_data.dart';

abstract class PaymentGateway {
  Future<List<PaymentMethod>> paymentMethods();

  Future<PaymentIntent> createIntent({
    required String categoryId,
    required String financialYearId,
    required String contributionWeekId,
    required String provider,
    required String payerPhoneNumber,
    required String amount,
    required String idempotencyKey,
  });

  Future<PaymentIntent> paymentIntent(String paymentIntentId);
}

class PaymentApiService implements PaymentGateway {
  PaymentApiService(this._client);

  final AuthenticatedApiClient _client;

  @override
  Future<List<PaymentMethod>> paymentMethods() async {
    final payload = await _client.getJson('/payment-methods');
    final rawItems = payload['items'];
    if (rawItems is! List) return const [];
    return rawItems
        .whereType<Map<String, dynamic>>()
        .map(PaymentMethod.fromJson)
        .where((method) => method.enabled)
        .toList();
  }

  @override
  Future<PaymentIntent> createIntent({
    required String categoryId,
    required String financialYearId,
    required String contributionWeekId,
    required String provider,
    required String payerPhoneNumber,
    required String amount,
    required String idempotencyKey,
  }) async {
    final key = idempotencyKey.isEmpty ? const Uuid().v4() : idempotencyKey;
    final payload = await _client.postJson(
      '/payment-intents',
      headers: {'Idempotency-Key': key},
      body: {
        'category_id': categoryId,
        'financial_year_id': financialYearId,
        'payment_method': 'mobile_money',
        'provider': provider,
        'payer_phone_number': payerPhoneNumber,
        'allocations': [
          {'contribution_week_id': contributionWeekId, 'amount': amount},
        ],
      },
    );
    return PaymentIntent.fromJson(payload);
  }

  @override
  Future<PaymentIntent> paymentIntent(String paymentIntentId) async {
    final payload = await _client.getJson('/payment-intents/$paymentIntentId');
    return PaymentIntent.fromJson(payload);
  }
}
