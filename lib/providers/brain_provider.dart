import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class BrainPrediction {
  final String metric;
  final String forecast;
  final double confidence;
  final String status; // 'Good', 'Warning', 'Plateau'

  BrainPrediction({
    required this.metric,
    required this.forecast,
    required this.confidence,
    required this.status,
  });
}

class AdaptiveSuggestion {
  final String title;
  final String action;
  final IconData icon;
  final String coach;

  AdaptiveSuggestion({
    required this.title,
    required this.action,
    required this.icon,
    required this.coach,
  });
}

class BrainProvider extends ChangeNotifier {
  double _complianceScore = 88.0;
  double _dropoffRisk = 12.0; // 0-100%
  String _plateauPrediction = 'Low probability in next 14 days.';

  final List<BrainPrediction> _predictions = [
    BrainPrediction(metric: 'Weight Target Timeline', forecast: '70.0 kg expected within 5 weeks', confidence: 0.92, status: 'Good'),
    BrainPrediction(metric: 'Diet Drop-off Risk', forecast: '12% probability of inconsistency next week', confidence: 0.85, status: 'Good'),
    BrainPrediction(metric: 'Plateau Estimate', forecast: 'No resistance plateaus detected yet', confidence: 0.88, status: 'Good'),
  ];

  final List<AdaptiveSuggestion> _suggestions = [
    AdaptiveSuggestion(
      title: 'Workout Load Reduction',
      action: 'We reduced your push sets from 4 to 2 today based on your low energy Luteal stage parameters.',
      icon: Icons.fitness_center_rounded,
      coach: 'Dr. Pink',
    ),
    AdaptiveSuggestion(
      title: 'Caloric Offset Alert',
      action: 'We adjusted tomorrow\'s dinner targets by -250 kcal to recover from logged cheat meals.',
      icon: Icons.restaurant_menu_rounded,
      coach: 'Dr. Blue',
    ),
    AdaptiveSuggestion(
      title: 'Hydration Target Increase',
      action: 'Expected high temperature tomorrow. Consume an additional 500ml water before 12:00.',
      icon: Icons.water_drop_rounded,
      coach: 'Dr. Pink',
    ),
  ];

  double get complianceScore => _complianceScore;
  double get dropoffRisk => _dropoffRisk;
  String get plateauPrediction => _plateauPrediction;
  List<BrainPrediction> get predictions => _predictions;
  List<AdaptiveSuggestion> get suggestions => _suggestions;

  void recomputeBrainState(UserProfile profile, int workoutHistoryLength, bool cheatMealLogged) {
    // Dynamically adjust scores based on current usage state parameters
    if (workoutHistoryLength == 0) {
      _complianceScore = 65.0;
      _dropoffRisk = 45.0;
    } else {
      _complianceScore = 85.0 + (workoutHistoryLength * 2.0).clamp(0.0, 15.0);
      _dropoffRisk = (25.0 - (workoutHistoryLength * 3.0)).clamp(5.0, 90.0);
    }

    if (cheatMealLogged) {
      _plateauPrediction = 'Minor digestion offsets predicted; calorie budgets have been balanced.';
    } else {
      _plateauPrediction = 'Optimal progression; metabolic performance is clean.';
    }
    notifyListeners();
  }
}
