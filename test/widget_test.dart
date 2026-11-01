import 'package:bahasha/features/auth/application/auth_controller.dart';
import 'package:bahasha/features/auth/data/auth_service.dart';
import 'package:bahasha/features/auth/domain/auth_session.dart';
import 'package:bahasha/features/contributions/data/member_api_service.dart';
import 'package:bahasha/features/contributions/domain/member_data.dart';
import 'package:bahasha/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthSession?> restoreSession() async => null;

  @override
  Future<AuthSession> login(String identifier, String password) async {
    return const AuthSession(
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      member: AuthMember(
        id: 'member-id',
        fullName: 'Amina Mushi',
        approvalStatus: 'approved',
      ),
    );
  }

  @override
  Future<AuthSession> refreshSession() => login('', '');

  @override
  Future<void> logout() async {}

  @override
  Future<String> requestPasswordReset(String email) async {
    return 'Reset instructions sent.';
  }
}

class FakeMemberDataGateway implements MemberDataGateway {
  @override
  Future<MemberBootstrap> bootstrap() async {
    return MemberBootstrap(
      member: const MemberProfile(
        id: 'member-id',
        fullName: 'Amina Mushi',
        bahashaNumber: 'BHS-00412',
        churchName: 'Kijitonyama',
        photoUrl: null,
      ),
      activePeriod: ActivePeriod(
        financialYearId: 'year-id',
        year: 2026,
        week: ActiveWeek(
          id: 'week-id',
          number: 41,
          sundayDate: DateTime(2026, 10, 11),
          isClosed: false,
        ),
      ),
      categories: const [
        ContributionCategory(
          id: 'category-ahadi',
          key: 'ahadi',
          name: 'Promise',
          swahiliName: 'Ahadi',
          description: 'Weekly promise offering',
          iconKey: 'hand-heart',
          colorHex: '#A844B7',
          frequency: 'weekly',
          paymentsEnabled: false,
          allowsCatchUp: true,
          missingWeeksCount: 3,
          totalContributed: Money(amount: 125000, currency: 'TZS'),
          suggestedAmount: null,
        ),
        ContributionCategory(
          id: 'category-shukrani',
          key: 'shukrani',
          name: 'Thanksgiving',
          swahiliName: 'Shukrani',
          description: 'Annual thanksgiving offering',
          iconKey: 'heart-handshake',
          colorHex: '#2E9F75',
          frequency: 'annual',
          paymentsEnabled: false,
          allowsCatchUp: false,
          missingWeeksCount: 0,
          totalContributed: Money(amount: 40000, currency: 'TZS'),
          suggestedAmount: null,
        ),
        ContributionCategory(
          id: 'category-jengo',
          key: 'jengo',
          name: 'Building fund',
          swahiliName: 'Jengo',
          description: 'Church building fund',
          iconKey: 'building-2',
          colorHex: '#3465A4',
          frequency: 'seasonal',
          paymentsEnabled: false,
          allowsCatchUp: false,
          missingWeeksCount: 0,
          totalContributed: Money(amount: 0, currency: 'TZS'),
          suggestedAmount: null,
        ),
      ],
      unreadNotificationsCount: 0,
      capabilities: const MobileCapabilities(paymentsEnabled: false),
    );
  }

  @override
  Future<PagedResult<ContributionWeek>> categoryWeeks({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async => const PagedResult(items: [], hasMore: false);

  @override
  Future<PagedResult<ContributionRecord>> contributions({
    required String categoryId,
    String? financialYearId,
    String? cursor,
  }) async => const PagedResult(items: [], hasMore: false);
}

void main() {
  testWidgets('shows login and enters the authenticated dashboard', (
    WidgetTester tester,
  ) async {
    final controller = AuthController(FakeAuthGateway());
    await tester.pumpWidget(
      BahashaApp(
        authController: controller,
        memberDataGateway: FakeMemberDataGateway(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Username or phone number'), findsOneWidget);
    expect(find.text('Forgot password? · Umesahau nenosiri?'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'amina');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-password');
    await tester.tap(find.text('Sign in · Ingia'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Amina Mushi'), findsOneWidget);
  });

  testWidgets('dashboard cards fit a narrow screen with large text', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 2400);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.6;
    addTearDown(tester.view.reset);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    final controller = AuthController(FakeAuthGateway());
    await tester.pumpWidget(
      BahashaApp(
        authController: controller,
        memberDataGateway: FakeMemberDataGateway(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'amina');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-password');
    await tester.tap(find.text('Sign in · Ingia'));
    await tester.pumpAndSettle();

    expect(find.text('Choose a contribution'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
