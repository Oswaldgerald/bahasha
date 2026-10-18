import 'package:bahasha/features/contributions/data/member_api_service.dart';
import 'package:bahasha/features/contributions/domain/member_data.dart';
import 'package:bahasha/features/contributions/presentation/category_detail_page.dart';
import 'package:bahasha/features/payments/presentation/payment_page.dart';
import 'package:bahasha/features/payments/data/payment_api_service.dart';
import 'package:bahasha/features/payments/domain/payment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _PaymentTestGateway implements MemberDataGateway {
  _PaymentTestGateway({this.paymentEligible = true});

  final bool paymentEligible;

  @override
  Future<MemberBootstrap> bootstrap() => throw UnimplementedError();

  @override
  Future<PagedResult<ContributionWeek>> categoryWeeks({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async {
    return PagedResult(
      items: [
        ContributionWeek(
          id: 'week-40',
          number: 40,
          sundayDate: DateTime(2026, 10, 4),
          state: 'missing',
          paymentEligible: paymentEligible,
          contributed: const Money(amount: 0, currency: 'TZS'),
        ),
      ],
      hasMore: false,
    );
  }

  @override
  Future<PagedResult<ContributionRecord>> contributions({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async => const PagedResult(items: [], hasMore: false);
}

class _NoopPaymentGateway implements PaymentGateway {
  @override
  Future<PaymentIntent> createIntent({
    required String categoryId,
    required String financialYearId,
    required String contributionWeekId,
    required String provider,
    required String payerPhoneNumber,
    required String amount,
    required String idempotencyKey,
  }) => throw UnimplementedError();

  @override
  Future<PaymentIntent> paymentIntent(String paymentIntentId) =>
      throw UnimplementedError();

  @override
  Future<List<PaymentMethod>> paymentMethods() async => const [];
}

const _category = ContributionCategory(
  id: 'category-ahadi',
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
  totalContributed: Money(amount: 25000, currency: 'TZS'),
  suggestedAmount: Money(amount: 5000, currency: 'TZS'),
);

void main() {
  testWidgets('eligible week opens its payment page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryDetailPage(
          category: _category,
          financialYearId: 'year-2026',
          memberData: _PaymentTestGateway(),
          paymentGateway: _NoopPaymentGateway(),
          paymentsAvailable: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('contribution-week-week-40')));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentPage), findsOneWidget);
    expect(find.text('Payment · Malipo'), findsOneWidget);
    expect(find.text('Week 40 · 04 Oct 2026'), findsOneWidget);
    expect(
      find.textContaining('Online payments are not enabled yet.'),
      findsOneWidget,
    );
  });

  testWidgets('ineligible week does not open the payment page', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CategoryDetailPage(
          category: _category,
          financialYearId: 'year-2026',
          memberData: _PaymentTestGateway(paymentEligible: false),
          paymentGateway: _NoopPaymentGateway(),
          paymentsAvailable: false,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('contribution-week-week-40')));
    await tester.pumpAndSettle();

    expect(find.byType(PaymentPage), findsNothing);
  });
}
