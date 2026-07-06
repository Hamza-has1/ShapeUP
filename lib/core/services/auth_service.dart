import 'dart:async';

class UserSession {
  final String token;
  final String email;
  final String name;

  UserSession({
    required this.token,
    required this.email,
    required this.name,
  });
}

class AuthService {
  // Simulate network delay
  Future<void> _networkDelay() => Future.delayed(const Duration(milliseconds: 1500));

  Future<UserSession> login(String email, String password) async {
    await _networkDelay();

    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password cannot be empty.');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format.');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    // Default test user
    if (email == 'user@shapeup.com' && password == 'password123') {
      return UserSession(
        token: 'mock-jwt-token-xyz',
        email: email,
        name: 'Alex Mercer',
      );
    }

    // Accept other logins for mockup convenience but simulate success
    return UserSession(
      token: 'mock-jwt-token-abc',
      email: email,
      name: email.split('@').first,
    );
  }

  Future<UserSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _networkDelay();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('All fields are required.');
    }

    if (!email.contains('@')) {
      throw Exception('Invalid email format.');
    }

    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    return UserSession(
      token: 'mock-jwt-token-new',
      email: email,
      name: name,
    );
  }

  Future<void> sendRecoveryEmail(String email) async {
    await _networkDelay();
    if (!email.contains('@')) {
      throw Exception('Invalid email address.');
    }
  }

  Future<void> verifyOtp(String otp) async {
    await _networkDelay();
    if (otp.length != 4 || otp != '1234') {
      throw Exception('Invalid OTP. Use "1234" for mock verification.');
    }
  }

  Future<void> resetPassword(String newPassword) async {
    await _networkDelay();
    if (newPassword.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }
  }

  Future<void> logout() async {
    await _networkDelay();
  }
}
