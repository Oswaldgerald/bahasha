import 'package:flutter/foundation.dart';

import '../../../core/network/api_exception.dart';
import '../domain/auth_session.dart';
import '../data/auth_service.dart';

enum AuthStatus { initializing, signedOut, authenticating, signedIn }

class AuthController extends ChangeNotifier {
  AuthController(this._gateway);

  final AuthGateway _gateway;

  AuthStatus status = AuthStatus.initializing;
  AuthSession? session;
  String? errorMessage;

  bool get isBusy => status == AuthStatus.authenticating;

  Future<void> initialize() async {
    try {
      session = await _gateway.restoreSession();
      status = session == null ? AuthStatus.signedOut : AuthStatus.signedIn;
    } catch (_) {
      status = AuthStatus.signedOut;
    }
    notifyListeners();
  }

  Future<bool> login(String identifier, String password) async {
    status = AuthStatus.authenticating;
    errorMessage = null;
    notifyListeners();
    try {
      session = await _gateway.login(identifier, password);
      status = AuthStatus.signedIn;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
    } on FormatException {
      errorMessage = 'Bahasha returned an unexpected response. Please retry.';
    }
    status = AuthStatus.signedOut;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    try {
      await _gateway.logout();
    } catch (_) {
      // Local sign-out must still succeed when the API is unavailable.
    } finally {
      session = null;
      status = AuthStatus.signedOut;
      notifyListeners();
    }
  }

  Future<String> requestPasswordReset(String email) {
    return _gateway.requestPasswordReset(email);
  }
}
