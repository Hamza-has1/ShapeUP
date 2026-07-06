import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/services/auth_service.dart';

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  authenticating,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.uninitialized;
  String? _token;
  String? _userEmail;
  String? _userName;
  String? _error;

  AuthProvider() {
    _loadSession();
  }

  AuthStatus get status => _status;
  String? get token => _token;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  String? get error => _error;
  bool get isLoading => _status == AuthStatus.authenticating;

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    _userEmail = prefs.getString('auth_email');
    _userName = prefs.getString('auth_name');

    if (_token != null) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password, bool rememberMe) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      final session = await _authService.login(email, password);
      _token = session.token;
      _userEmail = session.email;
      _userName = session.name;
      _status = AuthStatus.authenticated;

      if (rememberMe) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', session.token);
        await prefs.setString('auth_email', session.email);
        await prefs.setString('auth_name', session.name);
      }
      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _status = AuthStatus.authenticating;
    _error = null;
    notifyListeners();

    try {
      final session = await _authService.register(
        name: name,
        email: email,
        password: password,
      );
      _token = session.token;
      _userEmail = session.email;
      _userName = session.name;
      _status = AuthStatus.authenticated;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', session.token);
      await prefs.setString('auth_email', session.email);
      await prefs.setString('auth_name', session.name);

      notifyListeners();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendRecoveryEmail(String email) async {
    _error = null;
    notifyListeners();
    try {
      await _authService.sendRecoveryEmail(email);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyOtp(String otp) async {
    _error = null;
    notifyListeners();
    try {
      await _authService.verifyOtp(otp);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(newPassword);
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _status = AuthStatus.authenticating;
    notifyListeners();

    await _authService.logout();

    _token = null;
    _userEmail = null;
    _userName = null;
    _status = AuthStatus.unauthenticated;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('auth_email');
    await prefs.remove('auth_name');

    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
