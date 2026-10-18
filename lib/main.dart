import 'package:flutter/material.dart';

import 'core/config/app_config.dart';
import 'core/network/api_client.dart';
import 'core/network/authenticated_api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/contributions/data/member_api_service.dart';
import 'features/dashboard/presentation/landing_page.dart';
import 'features/payments/data/payment_api_service.dart';

void main() {
  runApp(const BahashaApp());
}

class BahashaApp extends StatefulWidget {
  const BahashaApp({
    super.key,
    this.authController,
    this.memberDataGateway,
    this.paymentGateway,
  });

  final AuthController? authController;
  final MemberDataGateway? memberDataGateway;
  final PaymentGateway? paymentGateway;

  @override
  State<BahashaApp> createState() => _BahashaAppState();
}

class _BahashaAppState extends State<BahashaApp> {
  late final AuthController _authController;
  late final bool _ownsController;
  late final MemberDataGateway _memberDataGateway;
  late final PaymentGateway _paymentGateway;
  ApiClient? _memberApiClient;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.authController == null;
    _authController =
        widget.authController ?? AuthController(AuthService.create());
    if (widget.memberDataGateway == null || widget.paymentGateway == null) {
      _memberApiClient = ApiClient(baseUrl: AppConfig.apiBaseUrl);
      final authenticatedClient = AuthenticatedApiClient(
        apiClient: _memberApiClient!,
        accessToken: () => _authController.session?.accessToken,
        refreshAccessToken: _authController.refreshAccessToken,
      );
      _memberDataGateway =
          widget.memberDataGateway ?? MemberApiService(authenticatedClient);
      _paymentGateway =
          widget.paymentGateway ?? PaymentApiService(authenticatedClient);
    } else {
      _memberDataGateway = widget.memberDataGateway!;
      _paymentGateway = widget.paymentGateway!;
    }
    _authController.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _authController.dispose();
    _memberApiClient?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bahasha',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: AnimatedBuilder(
        animation: _authController,
        builder: (context, _) {
          return switch (_authController.status) {
            AuthStatus.initializing => const _StartupScreen(),
            AuthStatus.signedIn => LandingPage(
              memberData: _memberDataGateway,
              paymentGateway: _paymentGateway,
              onLogout: _authController.logout,
            ),
            AuthStatus.signedOut || AuthStatus.authenticating => LoginPage(
              authController: _authController,
            ),
          };
        },
      ),
    );
  }
}

class _StartupScreen extends StatelessWidget {
  const _StartupScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
