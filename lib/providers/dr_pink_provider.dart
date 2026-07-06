import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class DrPinkPlan {
  final String goalClassification;
  final double caloriesTarget;
  final double proteinTarget;
  final double ironTargetMg;
  final String activeCyclePhase;
  final String phaseWorkoutIntensity;
  final String hormonalDietPlan;
  final String sleepAndStressPlan;
  final String weeklySchedule;
  final String priorityFocus;
  final List<String> safetyWarnings;
  final String empatheticMotivation;

  DrPinkPlan({
    required this.goalClassification,
    required this.caloriesTarget,
    required this.proteinTarget,
    required this.ironTargetMg,
    required this.activeCyclePhase,
    required this.phaseWorkoutIntensity,
    required this.hormonalDietPlan,
    required this.sleepAndStressPlan,
    required this.weeklySchedule,
    required this.priorityFocus,
    required this.safetyWarnings,
    required this.empatheticMotivation,
  });
}

class DrPinkProvider extends ChangeNotifier {
  DrPinkPlan? _activePlan;
  final List<Map<String, dynamic>> _chatHistory = [
    {
      'isMe': false,
      'text': 'Hello dear, I am Dr. Pink. I have reviewed your health metrics and cycle records. I am ready to generate a female-focused wellness, cycle-aware fitness, and hormonal diet plan for you. Would you like to proceed or discuss any symptoms?',
      'time': 'Just now',
    }
  ];
  bool _isGenerating = false;
  bool _isTyping = false;

  DrPinkPlan? get activePlan => _activePlan;
  List<Map<String, dynamic>> get chatHistory => _chatHistory;
  bool get isGenerating => _isGenerating;
  bool get isTyping => _isTyping;

  Future<void> generateFemalePlan(UserProfile profile) async {
    _isGenerating = true;
    notifyListeners();

    // 2-second decision latency simulation
    await Future.delayed(const Duration(milliseconds: 2000));

    // Step 1: Goal Selection
    String goal = profile.primaryGoal;
    if (profile.hasPcos) {
      goal = 'PCOS / Hormonal Balance Management';
    }

    // Step 2: Safety Screening
    final List<String> warnings = [];
    if (profile.isPregnant) {
      warnings.add('Pregnancy status active. Keep resistance moderate. Avoid high core strain or lying flat on your back after the first trimester.');
    }
    if (profile.hasIronDeficiency) {
      warnings.add('Iron deficiency history detected. Ensure regular intake of dark leafy greens, lean protein, and vitamin C. Keep workouts low impact if experiencing dizziness.');
    }

    // Step 3: Calorie & Macro (Iron focus)
    final calories = profile.dailyCalorieEstimate;
    final protein = profile.recommendedProteinIntake;
    final ironMg = profile.hasIronDeficiency ? 27.0 : 18.0; // Pregnant/deficit needs more iron

    // Step 4 & 5: Cycle Phase-Aware guidelines
    String phase = profile.menstrualCycleStage;
    String intensity = '';
    String diet = '';

    if (phase == 'Menstrual') {
      intensity = 'Low-intensity recovery focus. Foam rolling, walking, gentle yoga. Limit intense heavy lifting.';
      diet = 'Hormone-soothing comfort foods. Focus on warm soups, iron-rich spinach, wild salmon, and chamomile tea.';
    } else if (phase == 'Follicular') {
      intensity = 'High-energy progressive overload. Maximize strength lifting, HIIT cardio, and endurance workouts.';
      diet = 'Estrogen-balancing inputs. Lean proteins, cruciferous vegetables (broccoli, cauliflower), and complex carbs.';
    } else if (phase == 'Ovulation') {
      intensity = 'Peak energy split. Push for personal records in lifting or high-intensity athletic circuits.';
      diet = 'Light energy-dense carbohydrates, berries, and antioxidant-rich greens to support peak metabolism.';
    } else {
      // Luteal phase
      intensity = 'Moderate intensity strength. Steady-state recovery cardio. Reduce intensity as PMS approaches.';
      diet = 'Fiber-rich carbs (sweet potatoes, oats) to manage progesterone-induced cravings. Healthy fats.';
    }

    // Step 6: Prioritize Hormonal Stability
    String focus = '1. Cycle-phase workout sync. 2. Blood sugar regulation (PCOS control). 3. Cortisol reduction (sleep).';
    String quote = 'Your cycle is not a limitation; it is your biological blueprint. Work with your body, not against it.';

    _activePlan = DrPinkPlan(
      goalClassification: goal,
      caloriesTarget: calories,
      proteinTarget: protein,
      ironTargetMg: ironMg,
      activeCyclePhase: phase,
      phaseWorkoutIntensity: intensity,
      hormonalDietPlan: diet,
      sleepAndStressPlan: 'Aim for ${profile.sleepHours} hours sleep. Keep stress low: high cortisol directly inhibits hormonal balance.',
      weeklySchedule: 'Mon: Strength/Cycle-sync, Tue: Gentle walk, Wed: Strength, Thu: Rest, Fri: Cardio/Stretch, Sat/Sun: Rest.',
      priorityFocus: focus,
      safetyWarnings: warnings,
      empatheticMotivation: quote,
    );

    _isGenerating = false;
    _chatHistory.add({
      'isMe': false,
      'text': 'Your cycle-aware female health plan has been updated! Tap "View Generated Plan" below to check the full outline.',
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

    await Future.delayed(const Duration(milliseconds: 1500));

    String reply = '';
    final query = text.toLowerCase();

    if (query.contains('pcos') || query.contains('pcod')) {
      reply = 'PCOS management requires prioritizing insulin sensitivity. Focus on complex, low-glycemic carbohydrates, lean proteins, and fiber. Limit processed sugars to keep cortisol and insulin levels stable, dear.';
    } else if (query.contains('cycle') || query.contains('period') || query.contains('phase')) {
      reply = 'Since you are in the **${profile.menstrualCycleStage}** phase, your energy profile is set to adapt. Workout intensity should be **${profile.menstrualCycleStage == "Menstrual" ? "gentle and low-impact" : "moderate to high strength overload"}**. How are your energy levels feeling today?';
    } else if (query.contains('pregnant') || query.contains('baby') || query.contains('postpartum')) {
      reply = 'Wellness during this period is all about gentle care. Make sure to keep core temperature stable, hydrate with **${profile.waterIntake}L** water, and prioritize recovery sleeping hours.';
    } else if (query.contains('iron') || query.contains('tired') || query.contains('fatigue')) {
      reply = 'Fatigue is often tied to iron drops during menstrual phases. Ensure you pair iron sources (spinach, beans, lean meats) with Vitamin C (oranges, bell peppers) to maximize absorption.';
    } else {
      reply = 'I hear you. Wellness is a holistic path. Focus on gentle consistency, feed your body nutritious fuel based on your goal of **${profile.primaryGoal}**, and rest when needed. Let me know if you experience any cramps or low energy.';
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
      'text': 'Hello dear, I am Dr. Pink. I have reviewed your health metrics and cycle records. I am ready to generate a female-focused wellness, cycle-aware fitness, and hormonal diet plan for you. Would you like to proceed or discuss any symptoms?',
      'time': 'Just now',
    });
    notifyListeners();
  }
}
