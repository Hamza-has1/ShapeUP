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

    _userName = prefs.getString('userName') ?? '';
    _selectedGoal = prefs.getString('selectedGoal') ?? '';
    _activityLevel = prefs.getString('activityLevel') ?? '';
    _selectedCoach = prefs.getString('selectedCoach') ?? 'Dr. Blue';
    _isOnboarded = prefs.getBool('isOnboarded') ?? false;

    // Fallback: If a completed profile exists in local or mock server cache, they are onboarded!
    final hasProfile = prefs.getString('user_profile_final') != null || prefs.getString('local_profile_cache') != null;
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
    await prefs.setString('userName', name);
    await prefs.setString('selectedGoal', goal);
    await prefs.setString('activityLevel', activity);
    await prefs.setBool('isOnboarded', true);
  }

  Future<void> selectCoach(String coachName) async {
    _selectedCoach = coachName;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCoach', coachName);
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
    final profileJson = prefs.getString('local_profile_cache') ?? prefs.getString('user_profile_final');
    if (profileJson != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(profileJson);
        _userName = data['name'] ?? '';
        _selectedGoal = data['primaryGoal'] ?? '';
        _activityLevel = data['activityLevel'] ?? '';
        _isOnboarded = true;

        await prefs.setString('userName', _userName);
        await prefs.setString('selectedGoal', _selectedGoal);
        await prefs.setString('activityLevel', _activityLevel);
        await prefs.setBool('isOnboarded', true);
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
    await prefs.setBool('isOnboarded', false);
    await prefs.remove('userName');
    await prefs.remove('selectedGoal');
    await prefs.remove('activityLevel');
  }
}
