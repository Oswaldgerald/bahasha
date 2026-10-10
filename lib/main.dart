import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/data/auth_service.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/dashboard/presentation/landing_page.dart';

void main() {
  runApp(const BahashaApp());
}

class BahashaApp extends StatefulWidget {
  const BahashaApp({super.key, this.authController});

  final AuthController? authController;

  @override
  State<BahashaApp> createState() => _BahashaAppState();
}

class _BahashaAppState extends State<BahashaApp> {
  late final AuthController _authController;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    _ownsController = widget.authController == null;
    _authController =
        widget.authController ?? AuthController(AuthService.create());
    _authController.initialize();
  }

  @override
  void dispose() {
    if (_ownsController) _authController.dispose();
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
              memberName: _authController.session?.member.fullName ?? '',
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
