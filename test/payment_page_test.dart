import 'package:bahasha/features/contributions/domain/member_data.dart';
import 'package:bahasha/features/payments/data/payment_api_service.dart';
import 'package:bahasha/features/payments/domain/payment_data.dart';
import 'package:bahasha/features/payments/presentation/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _SimulatedPaymentGateway implements PaymentGateway {
  var createCalls = 0;
  var statusCalls = 0;

  @override
  Future<List<PaymentMethod>> paymentMethods() async => const [
    PaymentMethod(
      key: 'mobile_money',
      name: 'Mobile money',
      providers: ['vodacom_m_pesa', 'airtel_money', 'mixx_by_yas'],
      currency: 'TZS',
      enabled: true,
    ),
  ];

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
    createCalls += 1;
    expect(provider, 'vodacom_m_pesa');
    expect(payerPhoneNumber, '0712345678');
    expect(amount, '5000.00');
    expect(idempotencyKey, isNotEmpty);
    return const PaymentIntent(
      id: 'intent-id',
      reference: 'PAY-2026-0001',
      status: 'pending_customer_action',
      provider: 'vodacom_m_pesa',
      amount: Money(amount: 5000, currency: 'TZS'),
      contributionIds: [],
      nextAction: PaymentNextAction(
        type: 'approve_mobile_money_prompt',
        message: 'Approve the payment request on your phone.',
      ),
    );
  }

  @override
  Future<PaymentIntent> paymentIntent(String paymentIntentId) async {
    statusCalls += 1;
    return const PaymentIntent(
      id: 'intent-id',
      reference: 'PAY-2026-0001',
      status: 'succeeded',
      provider: 'vodacom_m_pesa',
      amount: Money(amount: 5000, currency: 'TZS'),
      contributionIds: ['contribution-id'],
    );
  }
}

void main() {
  testWidgets('submits and confirms a simulated weekly payment', (
    tester,
  ) async {
    final gateway = _SimulatedPaymentGateway();
    await tester.pumpWidget(
      MaterialApp(
        home: PaymentPage(
          category: _category,
          week: _week,
          financialYearId: 'year-id',
          paymentGateway: gateway,
          paymentsAvailable: true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('payment-phone')),
      '712345678',
    );
    await tester.drag(find.byType(ListView), const Offset(0, -700));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('continue-payment')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pumpAndSettle();

    expect(gateway.createCalls, 1);
    expect(gateway.statusCalls, 1);
    await tester.drag(find.byType(ListView), const Offset(0, 900));
    await tester.pumpAndSettle();
    expect(find.textContaining('Payment successful'), findsOneWidget);
    expect(find.text('Done · Maliza'), findsOneWidget);
  });
}

const _category = ContributionCategory(
  id: 'category-id',
  key: 'ahadi',
  name: 'Promise',
  swahiliName: 'Ahadi',
  description: 'Weekly promise offering',
  iconKey: 'hand-heart',
  colorHex: '#A844B7',
  frequency: 'weekly',
  paymentsEnabled: true,
  allowsCatchUp: true,
  missingWeeksCount: 1,
  totalContributed: Money(amount: 0, currency: 'TZS'),
  suggestedAmount: Money(amount: 5000, currency: 'TZS'),
);

final _week = ContributionWeek(
  id: 'week-id',
  number: 41,
  sundayDate: DateTime(2026, 10, 11),
  state: 'missing',
  paymentEligible: true,
  contributed: const Money(amount: 0, currency: 'TZS'),
);
