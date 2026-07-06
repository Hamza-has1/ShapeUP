import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class DrBluePlan {
  final String goalClassification;
  final double caloriesTarget;
  final double proteinTarget;
  final double carbsTarget;
  final double fatTarget;
  final String workoutStructure;
  final String dietPlan;
  final String restAndCardioPlan;
  final String sleepAndHydrationPlan;
  final String weeklySchedule;
  final String priorityFocus;
  final List<String> warnings;
  final String motivationalQuote;

  DrBluePlan({
    required this.goalClassification,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.carbsTarget,
    required this.fatTarget,
    required this.workoutStructure,
    required this.dietPlan,
    required this.restAndCardioPlan,
    required this.sleepAndHydrationPlan,
    required this.weeklySchedule,
    required this.priorityFocus,
    required this.warnings,
    required this.motivationalQuote,
  });
}

class DrBlueProvider extends ChangeNotifier {
  DrBluePlan? _activePlan;
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'isMe': false,
      'text': 'Hello, I am Dr. Blue. I have analyzed your wellness assessment data and am ready to design a custom health and fitness schedule. Would you like to generate your structured plan or ask any questions?',
      'time': 'Just now',
    }
  ];
  bool _isGenerating = false;
  bool _isTyping = false;

  DrBluePlan? get activePlan => _activePlan;
  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  bool get isGenerating => _isGenerating;
  bool get isTyping => _isTyping;

  Future<void> generatePlan(UserProfile profile) async {
    _isGenerating = true;
    notifyListeners();

    // Simulating decision-making pipeline latency
    await Future.delayed(const Duration(milliseconds: 2000));

    // Step 1: User Goal Identification
    final goal = profile.primaryGoal;

    // Step 2: Health Risk Screening & Flags
    final List<String> warnings = [];
    if (profile.bmi >= 30.0) {
      warnings.add('High BMI detected. Keep high-intensity impact cardio minimal to protect knee joints. Ensure to consult your doctor before starting heavy resistance loads.');
    }
    if (profile.medicalConditions.isNotEmpty) {
      warnings.add('Medical profile indicator alert: Ensure to crosscheck workouts with your physiotherapist regarding: ${profile.medicalConditions}');
    }

    // Step 3: Calorie & Macro Target Calculations
    final calories = profile.dailyCalorieEstimate;
    final protein = profile.recommendedProteinIntake;
    final fat = (calories * 0.25) / 9.0;
    final carbs = (calories - (protein * 4) - (fat * 9)) / 4.0;

    // Step 4: Workout Schedule based on Gym Access
    String workout = '';
    if (profile.gymAccess) {
      workout = '3-Day Push/Pull/Legs strength hypertrophy split using barbell/dumbbells. Focus on progressive overload.';
    } else {
      workout = '3-Day Full Body resistance workout using home equipment: ${profile.homeEquipment.isNotEmpty ? profile.homeEquipment : "resistance bands & bodyweight exercises"}.';
    }

    // Step 5: Diet structure
    String diet = '';
    if (profile.foodPreference == 'Vegetarian') {
      diet = 'Vegetarian macro-balanced diet focusing on cottage cheese, greek yogurt, lentils, tofu, and whey protein shakes to hit ${protein.round()}g protein.';
    } else if (profile.foodPreference == 'Vegan') {
      diet = 'Vegan plant-based diet focusing on tempeh, seitan, pea protein isolates, beans, and high-protein grains to secure protein targets.';
    } else {
      diet = 'High-protein diet focusing on lean chicken breast, eggs, fish, cottage cheese, and brown rice grains.';
    }

    // Step 6: Prioritization & Motivation
    String focus = '1. Consistent caloric adherence. 2. Progressive overload strength routine. 3. Sleep recovery.';
    String quote = 'Strength does not come from physical capacity. It comes from an indomitable will.';

    _activePlan = DrBluePlan(
      goalClassification: goal,
      caloriesTarget: calories,
      proteinTarget: protein,
      carbsTarget: carbs,
      fatTarget: fat,
      workoutStructure: workout,
      dietPlan: diet,
      restAndCardioPlan: 'Cardio: 20-min low-intensity steady-state walking on rest days. Rest days: Wed/Sun.',
      sleepAndHydrationPlan: 'Sleep target: ${profile.sleepHours} hours. Drink ${profile.waterIntake}L water daily.',
      weeklySchedule: 'Mon: Push/Full-Body, Tue: Rest, Wed: Pull/Cardio, Thu: Rest, Fri: Legs/Full-Body, Sat/Sun: Rest.',
      priorityFocus: focus,
      warnings: warnings,
      motivationalQuote: quote,
    );

    _isGenerating = false;
    _chatHistory.add({
      'isMe': false,
      'text': 'I have successfully generated your personalized health, nutrition, and workout strategy. Tap "View Generated Plan" below to check the full details.',
      'time': 'Just now',
    });
    notifyListeners();
  }

  Future<void> sendMessage(String text, UserProfile profile) async {
    if (text.trim().isEmpty) return;

    _chatHistory.add({
      'isMe': true,
      'text': text,
      'time': 'Just now',
    });
    _isTyping = true;
    notifyListeners();

    // AI thinking latency
    await Future.delayed(const Duration(milliseconds: 1500));

    String reply = '';
    final query = text.toLowerCase();

    if (query.contains('plan') || query.contains('diet') || query.contains('workout')) {
      reply = 'According to your goal of **${profile.primaryGoal}**, I recommend keeping to a calorie limit of **${profile.dailyCalorieEstimate.round()} kcal** with a target protein intake of **${profile.recommendedProteinIntake.round()}g**. For workouts, consistency is key: focus on ${profile.gymAccess ? "gym progressive overload" : "home training with your equipment"}.';
    } else if (query.contains('water') || query.contains('hydrate')) {
      reply = 'Aim to consume **${profile.waterIntake.toStringAsFixed(1)} Liters** of water spread evenly throughout your active hours. Proper hydration is critical for metabolic efficiency.';
    } else if (query.contains('sleep') || query.contains('stress')) {
      reply = 'You currently sleep **${profile.sleepHours.round()} hours** with **${profile.stressLevel}** stress levels. Focus on setting a strict bedtime and limit blue-light screens 1 hour before sleeping.';
    } else {
      reply = 'Understood. Regarding your profile, we want to prioritize **${profile.primaryGoal}**. Focus on hitting your daily targets, tracking your protein, and getting adequate rest. Let me know if you want me to adjust specific parts of your workout.';
    }

    _isTyping = false;
    _chatHistory.add({
      'isMe': false,
      'text': reply,
      'time': 'Just now',
    });
    notifyListeners();
  }

  void resetPlan() {
    _activePlan = null;
    _chatHistory.clear();
    _chatHistory.add({
      'isMe': false,
      'text': 'Hello, I am Dr. Blue. I have analyzed your wellness assessment data and am ready to design a custom health and fitness schedule. Would you like to generate your structured plan or ask any questions?',
      'time': 'Just now',
    });
    notifyListeners();
  }
}
