import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class ProfileProvider extends ChangeNotifier {
  UserProfile _profile = UserProfile();
  int _currentStep = 0;
  bool _isSaving = false;
  String? _error;

  double _consumedWaterLiters = 0.0;
  double get consumedWaterLiters => _consumedWaterLiters;
  int get consumedGlasses => (_consumedWaterLiters / 0.25).round();
  int get targetGlasses => (_profile.waterIntake / 0.25).round();

  ProfileProvider() {
    _loadDraft();
  }

  UserProfile get profile => _profile;
  int get currentStep => _currentStep;
  bool get isSaving => _isSaving;
  String? get error => _error;

  Future<void> _loadDraft() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final draftJson = prefs.getString('profile_draft');
      if (draftJson != null) {
        _profile = UserProfile.fromJson(jsonDecode(draftJson));
      }
      _currentStep = prefs.getInt('profile_step') ?? 0;
      await checkDailyWaterReset();
      notifyListeners();
    } catch (e) {
      // Fail silently
    }
  }

  Future<void> checkDailyWaterReset() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final lastReset = prefs.getString('last_water_reset_date');
    if (lastReset != todayStr) {
      _consumedWaterLiters = 0.0;
      await prefs.setDouble('consumed_water_liters', 0.0);
      await prefs.setString('last_water_reset_date', todayStr);
    } else {
      _consumedWaterLiters = prefs.getDouble('consumed_water_liters') ?? 0.0;
    }
    notifyListeners();
  }

  Future<void> recordWaterIntake(double amount) async {
    _consumedWaterLiters = amount;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('consumed_water_liters', amount);
  }

  Future<void> saveCurrentStep(int step) async {
    _currentStep = step;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('profile_step', step);
    await prefs.setString('profile_draft', jsonEncode(_profile.toJson()));
  }

  void updateBasicInfo({
    required String name,
    required int age,
    required String gender,
    required double height,
    required double weight,
    required double goalWeight,
  }) {
    _profile.name = name;
    _profile.age = age;
    _profile.gender = gender;
    _profile.height = height;
    _profile.weight = weight;
    _profile.goalWeight = goalWeight;
    
    // Auto-calculate BMI
    if (height > 0) {
      final heightM = height / 100.0;
      _profile.bmi = weight / (heightM * heightM);
    }
    notifyListeners();
  }

  void updateBodyMetrics({
    required double goalWeight,
    required String bodyType,
    required String conditions,
    required String injuries,
    required String medications,
  }) {
    _profile.goalWeight = goalWeight;
    _profile.bodyType = bodyType;
    _profile.medicalConditions = conditions;
    _profile.injuries = injuries;
    _profile.medications = medications;
    notifyListeners();
  }

  void updateFitnessLevel({
    required String activityLevel,
    required String workoutExperience,
    required bool gymAccess,
    required String homeEquipment,
  }) {
    _profile.activityLevel = activityLevel;
    _profile.workoutExperience = workoutExperience;
    _profile.gymAccess = gymAccess;
    _profile.homeEquipment = homeEquipment;
    notifyListeners();
  }

  void updateLifestyle({
    required String jobType,
    required double sleep,
    required double water,
  }) {
    _profile.jobType = jobType;
    _profile.sleepHours = sleep;
    _profile.waterIntake = water;
    notifyListeners();
  }

  void updateNutrition({
    required String preference,
    required String allergies,
    required String restrictions,
    required String budget,
    required String foodHint,
  }) {
    _profile.foodPreference = preference;
    _profile.allergies = allergies;
    _profile.dietRestrictions = restrictions;
    _profile.budgetRange = budget;
    _profile.countryFoodHint = foodHint;
    notifyListeners();
  }

  void updateGoals({
    required String goal,
  }) {
    _profile.primaryGoal = goal;
    _profile.secondaryGoals = '';
    _profile.targetTimelineWeeks = 12;
    _profile.motivation = '';
    notifyListeners();
  }

  Future<bool> submitProfile() async {
    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      // Calculate final target metrics (estimations)
      _calculateTargetMetrics();

      final jsonPayload = jsonEncode(_profile.toJson());
      
      // Sync to virtual API Server database
      await ApiService.syncProfileToServer(jsonPayload);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_profile_final', jsonPayload);
      await prefs.setBool('profile_completed', true);
      
      // Clear drafts
      await prefs.remove('profile_draft');
      await prefs.remove('profile_step');

      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSaving = false;
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _calculateTargetMetrics() {
    // 1. BMI category
    final bmi = _profile.bmi;
    _profile.healthRiskFlags = [];
    if (bmi < 18.5) {
      _profile.healthRiskFlags.add('Underweight status warning.');
    } else if (bmi >= 25.0 && bmi < 30.0) {
      _profile.healthRiskFlags.add('Overweight status warning.');
    } else if (bmi >= 30.0) {
      _profile.healthRiskFlags.add('High BMI (Obesity class warning).');
    }

    if (_profile.medicalConditions.isNotEmpty) {
      _profile.healthRiskFlags.add('Chronic medical condition warning: ${_profile.medicalConditions}');
    }

    // 2. Daily Calories (Harris-Benedict baseline estimation)
    double bmr = 0;
    if (_profile.gender == 'Male') {
      bmr = 88.362 + (13.397 * _profile.weight) + (4.799 * _profile.height) - (5.677 * _profile.age);
    } else {
      bmr = 447.593 + (9.247 * _profile.weight) + (3.098 * _profile.height) - (4.330 * _profile.age);
    }

    double activityMultiplier = 1.2;
    switch (_profile.activityLevel) {
      case 'Sedentary (Little to no exercise)':
        activityMultiplier = 1.2;
        break;
      case 'Lightly Active (1-3 days/week)':
        activityMultiplier = 1.375;
        break;
      case 'Moderate (3-5 days/week)':
      case 'Moderately Active':
        activityMultiplier = 1.55;
        break;
      case 'Very Active (6-7 days/week)':
        activityMultiplier = 1.725;
        break;
    }

    double tdee = bmr * activityMultiplier;

    // Adjust for goals
    switch (_profile.primaryGoal) {
      case 'Weight Loss':
      case 'Fat Loss':
        _profile.dailyCalorieEstimate = tdee - 500;
        break;
      case 'Muscle Gain':
      case 'Weight Gain':
        _profile.dailyCalorieEstimate = tdee + 300;
        break;
      case 'Maintenance':
      default:
        _profile.dailyCalorieEstimate = tdee;
        break;
    }

    // Protein calculation: 1.6g to 2.2g per kg of weight
    _profile.recommendedProteinIntake = _profile.weight * 1.8;

    // Water intake dynamic calculation
    double baseWater = _profile.weight * 0.033;
    if (_profile.activityLevel.contains('Active')) {
      baseWater += 0.5;
    }
    if (_profile.gender == 'Male') {
      baseWater += 0.5;
    }
    _profile.waterIntake = baseWater;
  }

  Future<void> resetProfileState() async {
    _profile = UserProfile();
    _currentStep = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('profile_draft');
    await prefs.remove('profile_step');
    await prefs.remove('user_profile_final');
    await prefs.remove('profile_completed');
  }
}
