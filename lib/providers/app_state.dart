import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppStateProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  String _userName = '';
  String _selectedGoal = '';
  String _activityLevel = '';
  String _selectedCoach = 'Dr. Blue'; // Default coach
  bool _isOnboarded = false;

  AppStateProvider() {
    _loadFromPrefs();
  }

  ThemeMode get themeMode => _themeMode;
  String get userName => _userName;
  String get selectedGoal => _selectedGoal;
  String get activityLevel => _activityLevel;
  String get selectedCoach => _selectedCoach;
  bool get isOnboarded => _isOnboarded;

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Theme load
    final themeStr = prefs.getString('themeMode') ?? 'system';
    if (themeStr == 'light') {
      _themeMode = ThemeMode.light;
    } else if (themeStr == 'dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    final email = prefs.getString('auth_email') ?? 'default';
    _userName = prefs.getString('userName_$email') ?? '';
    _selectedGoal = prefs.getString('selectedGoal_$email') ?? '';
    _activityLevel = prefs.getString('activityLevel_$email') ?? '';
    _selectedCoach = prefs.getString('selectedCoach_$email') ?? 'Dr. Blue';
    _isOnboarded = prefs.getBool('isOnboarded_$email') ?? false;

    // Fallback: If a completed profile exists in local or mock server cache, they are onboarded!
    final hasProfile = prefs.getString('user_profile_final_$email') != null || prefs.getString('local_profile_cache_$email') != null;
    if (hasProfile) {
      _isOnboarded = true;
    }
    
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode', mode.toString().split('.').last);
  }

  Future<void> saveProfile({
    required String name,
    required String goal,
    required String activity,
  }) async {
    _userName = name;
    _selectedGoal = goal;
    _activityLevel = activity;
    _isOnboarded = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email') ?? 'default';
    await prefs.setString('userName_$email', name);
    await prefs.setString('selectedGoal_$email', goal);
    await prefs.setString('activityLevel_$email', activity);
    await prefs.setBool('isOnboarded_$email', true);
  }

  Future<void> selectCoach(String coachName) async {
    _selectedCoach = coachName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email') ?? 'default';
    await prefs.setString('selectedCoach_$email', coachName);
  }

  Future<void> resetData() async {
    _userName = '';
    _selectedGoal = '';
    _activityLevel = '';
    _isOnboarded = false;
    _selectedCoach = 'Dr. Blue';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> reloadState() async {
    await _loadFromPrefs();
  }

  Future<void> syncFromProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email') ?? 'default';
    final profileJson = prefs.getString('local_profile_cache_$email') ?? prefs.getString('user_profile_final_$email');
    if (profileJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(profileJson);
        _userName = data['name'] ?? '';
        _selectedGoal = data['primaryGoal'] ?? '';
        _activityLevel = data['activityLevel'] ?? '';
        _isOnboarded = true;

        await prefs.setString('userName_$email', _userName);
        await prefs.setString('selectedGoal_$email', _selectedGoal);
        await prefs.setString('activityLevel_$email', _activityLevel);
        await prefs.setBool('isOnboarded_$email', true);
        notifyListeners();
      } catch (e) {
        // fail silently
      }
    }
  }

  Future<void> resetOnboarding() async {
    _isOnboarded = false;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString('auth_email') ?? 'default';
    await prefs.setBool('isOnboarded_$email', false);
    await prefs.remove('userName_$email');
    await prefs.remove('selectedGoal_$email');
    await prefs.remove('activityLevel_$email');
  }
}
