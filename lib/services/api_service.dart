import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String _baseUrl = 'https://api.shapeup-health.com/v1';
  static const String _tokenKey = 'jwt_access_token';
  static const String _refreshKey = 'jwt_refresh_token';

  // Simulated local offline cache table name
  static const String _profileCacheKey = 'local_profile_cache';

  // Simulated latency
  static Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Auth Operations
  static Future<Map<String, dynamic>> login(String email, String password) async {
    await _simulateLatency();

    if (email == 'user@shapeup.com' && password == 'password123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, 'mock-jwt-header.payload.signature-access');
      await prefs.setString(_refreshKey, 'mock-jwt-refresh-token-123');
      
      return {
        'success': true,
        'accessToken': 'mock-jwt-header.payload.signature-access',
        'email': email,
      };
    }
    
    return {
      'success': false,
      'error': 'Invalid credentials. Please check your username and password.',
    };
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_refreshKey);
  }

  // Profile Sync & Caching Service
  static Future<bool> syncProfileToServer(String jsonProfileString) async {
    await _simulateLatency();
    final prefs = await SharedPreferences.getInstance();
    
    // Save to local sqlite-style cache database
    await prefs.setString(_profileCacheKey, jsonProfileString);
    
    // In a real application, make a POST call to $_baseUrl/profile/sync
    // print('Synced profile payload to: $_baseUrl/profile/sync');
    return true;
  }

  static Future<String?> fetchProfileFromServer() async {
    await _simulateLatency();
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_profileCacheKey);
  }

  // Check Token Rotations
  static Future<bool> rotateTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshKey);
    if (refreshToken != null) {
      await prefs.setString(_tokenKey, 'mock-jwt-new-rotated-token');
      return true;
    }
    return false;
  }
}
