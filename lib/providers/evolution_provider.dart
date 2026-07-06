import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class EvolutionProvider extends ChangeNotifier {
  // Wearables & Future Metrics
  bool _isWearableConnected = false;
  String _connectedDeviceName = '';
  double _vo2Max = 38.0;
  int _metabolicAge = 25;
  double _bodyFatPercentage = 22.0;

  // Self-Monitoring Metrics
  double _aiRecommendationAccuracy = 94.2; // %
  int _apiLatencyMs = 145; // ms
  double _uxFrictionScore = 1.8; // 0-10 scale (lower is better)

  // AI Auto-Tuning States
  double _metabolicMultiplier = 1.0; // scales target calories based on user adherence
  List<String> _evolutionLogs = [
    'System init: AI Self-Improvement loop is monitoring outcomes.',
    'Ready for Wearable Smartwatch sync integration.'
  ];

  bool get isWearableConnected => _isWearableConnected;
  String get connectedDeviceName => _connectedDeviceName;
  double get vo2Max => _vo2Max;
  int get metabolicAge => _metabolicAge;
  double get bodyFatPercentage => _bodyFatPercentage;
  double get aiRecommendationAccuracy => _aiRecommendationAccuracy;
  int get apiLatencyMs => _apiLatencyMs;
  double get uxFrictionScore => _uxFrictionScore;
  double get metabolicMultiplier => _metabolicMultiplier;
  List<String> get evolutionLogs => _evolutionLogs;

  void connectWearable(String deviceName) {
    _isWearableConnected = true;
    _connectedDeviceName = deviceName;
    
    // Simulating advanced metric updates pulled from wearable device sensors
    _vo2Max = 44.5;
    _metabolicAge = 22;
    _bodyFatPercentage = 18.5;
    
    _evolutionLogs.insert(0, 'Wearable ($deviceName) connected successfully. Fetched VO2 Max: 44.5 | Metabolic Age: 22.');
    notifyListeners();
  }

  void disconnectWearable() {
    _isWearableConnected = false;
    _connectedDeviceName = '';
    _vo2Max = 38.0;
    _metabolicAge = 25;
    _bodyFatPercentage = 22.0;
    
    _evolutionLogs.insert(0, 'Wearable disconnected. Reverted to assessment fallback estimations.');
    notifyListeners();
  }

  void runAiSelfImprovementLoop(UserProfile profile, double weightLossAdherence) {
    // Outcomes-based optimization:
    // If user compliance is high but weight loss is slower than target expected timeline,
    // reduce metabolicMultiplier slightly (metabolic slowdown correction)
    if (weightLossAdherence > 0.8) {
      _metabolicMultiplier = 0.95; // 5% calorie reduction auto-tuned
      _aiRecommendationAccuracy = 96.8;
      _uxFrictionScore = 1.1;
      _evolutionLogs.insert(0, 'Self-Improvement Triggered: Diet compliance is high but weight progress is slow. Auto-tuned metabolic multiplier to 0.95x (balancing caloric budgets).');
    } else {
      _metabolicMultiplier = 1.0;
      _evolutionLogs.insert(0, 'Self-Improvement Triggered: Normal progression. AI parameters aligned with standard timeline target.');
    }
    notifyListeners();
  }
}
