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
}
