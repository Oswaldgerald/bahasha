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
      categories: const [],
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
    expect(find.text('Forgot password?'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'amina');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret-password');
    await tester.tap(find.text('Sign in'));
    await tester.pumpAndSettle();

    expect(find.text('Welcome, Amina Mushi'), findsOneWidget);
  });
}
