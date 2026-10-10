import 'package:bahasha/features/auth/application/auth_controller.dart';
import 'package:bahasha/features/auth/data/auth_service.dart';
import 'package:bahasha/features/auth/domain/auth_session.dart';
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
  Future<void> logout() async {}

  @override
  Future<String> requestPasswordReset(String email) async {
    return 'Reset instructions sent.';
  }
}

void main() {
  testWidgets('shows login and enters the authenticated dashboard', (
    WidgetTester tester,
  ) async {
    final controller = AuthController(FakeAuthGateway());
    await tester.pumpWidget(BahashaApp(authController: controller));
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
