import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class WeightEntry {
  final DateTime date;
  final double weight;

  WeightEntry({required this.date, required this.weight});
}

class BodyMeasurement {
  final double waist;
  final double chest;
  final double arms;
  final double hips;

  BodyMeasurement({
    required this.waist,
    required this.chest,
    required this.arms,
    required this.hips,
  });
}

class AchievementBadge {
  final String title;
  final String description;
  final IconData icon;
  final bool unlocked;

  AchievementBadge({
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
  });
}

class AnalyticsProvider extends ChangeNotifier {
  final List<WeightEntry> _weightHistory = [
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 6)), weight: 72.4),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 5)), weight: 71.8),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 4)), weight: 71.5),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 3)), weight: 71.0),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 2)), weight: 70.8),
    WeightEntry(date: DateTime.now().subtract(const Duration(days: 1)), weight: 70.4),
    WeightEntry(date: DateTime.now(), weight: 70.0),
  ];

  BodyMeasurement _initialMeasurements = BodyMeasurement(waist: 88, chest: 102, arms: 35, hips: 98);
  BodyMeasurement _currentMeasurements = BodyMeasurement(waist: 85, chest: 100, arms: 36, hips: 96);

  int _dailyStreak = 7;
  int _workoutStreak = 4;
  int _nutritionStreak = 5;

  final List<AchievementBadge> _achievements = [
    AchievementBadge(title: 'First Step', description: 'Log your first weight entry.', icon: Icons.scale_rounded, unlocked: true),
    AchievementBadge(title: 'Consistency King/Queen', description: 'Maintain a 7-day tracking streak.', icon: Icons.local_fire_department_rounded, unlocked: true),
    AchievementBadge(title: 'Iron Mind', description: 'Complete 5 workouts in a week.', icon: Icons.fitness_center_rounded, unlocked: false),
    AchievementBadge(title: 'Clean Fuel', description: 'Hit your protein goals 3 days in a row.', icon: Icons.restaurant_menu_rounded, unlocked: true),
    AchievementBadge(title: 'Milestone Met', description: 'Reach your first weight target.', icon: Icons.emoji_events_rounded, unlocked: false),
  ];

  List<WeightEntry> get weightHistory => _weightHistory;
  BodyMeasurement get initialMeasurements => _initialMeasurements;
  BodyMeasurement get currentMeasurements => _currentMeasurements;
  int get dailyStreak => _dailyStreak;
  int get workoutStreak => _workoutStreak;
  int get nutritionStreak => _nutritionStreak;
  List<AchievementBadge> get achievements => _achievements;

  // Calculators
  int get nutritionScore => 85; // Mock adherence calculation
  int get workoutScore => 90;
  int get healthScore => ((nutritionScore + workoutScore) / 2).round();

  void addWeightEntry(double weight) {
    if (weight <= 0) return;
    _weightHistory.add(WeightEntry(date: DateTime.now(), weight: weight));
    _dailyStreak++;
    _nutritionStreak++;
    notifyListeners();
  }

  void updateMeasurements({
    required double waist,
    required double chest,
    required double arms,
    required double hips,
  }) {
    _currentMeasurements = BodyMeasurement(waist: waist, chest: chest, arms: arms, hips: hips);
    notifyListeners();
  }

  String getAiProgressReport(UserProfile profile, String activeCoach) {
    final double diff = profile.weight - profile.goalWeight;
    final String label = diff > 0 ? 'loss' : 'gain';

    if (activeCoach == 'Dr. Blue') {
      return 'Dr. Blue Analysis:\n'
          '• Your current weight trend matches safe expected speed parameters ($label target).\n'
          '• Progress: ${diff.abs().toStringAsFixed(1)} kg remaining to reach target.\n'
          '• Hypertrophy check: Strength outputs are recovering nicely; protein absorption is optimal.';
    } else {
      return 'Dr. Pink Cycle Report:\n'
          '• Active phase: **${profile.menstrualCycleStage}**.\n'
          '• Water retention is normal. Avoid scaling panic if minor weight jumps occur during Luteal pre-periods.\n'
          '• Energy levels are predicted to stabilize; prioritize gentle cardio stretching today.';
    }
  }

  int getWeeksRemaining(UserProfile profile) {
    // Basic estimation logic
    final double diff = (profile.weight - profile.goalWeight).abs();
    if (diff == 0) return 0;
    return (diff / 0.5).round(); // safe weight change rate estimation: 0.5kg per week
  }
}
