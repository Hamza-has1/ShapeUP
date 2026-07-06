import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class SmartNotification {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String category; // 'Workout', 'Meal', 'Water', 'Streak', 'AI Insight'
  final String coachName;
  bool isRead;

  SmartNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    required this.coachName,
    this.isRead = false,
  });
}

class NotificationProvider extends ChangeNotifier {
  final List<SmartNotification> _notifications = [
    SmartNotification(
      id: '1',
      title: 'Morning Plan Summary',
      body: 'Get ready for your Day 1 targets! Push Squats and High protein Daal Chawal are on today’s menu.',
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      category: 'AI Insight',
      coachName: 'Dr. Blue',
    ),
    SmartNotification(
      id: '2',
      title: 'Hydration Check-in',
      body: 'Time to drink 500ml of water to keep muscle synthesis high.',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      category: 'Water',
      coachName: 'Dr. Blue',
    ),
    SmartNotification(
      id: '3',
      title: 'Streak Warning Alert',
      body: 'Your 7-day tracking streak is in danger! Log a quick workout or your dinner to keep the fire going.',
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      category: 'Streak',
      coachName: 'Dr. Pink',
    ),
  ];

  // Settings
  bool _workoutReminders = true;
  bool _mealReminders = true;
  bool _waterReminders = true;
  String _frequency = 'Medium'; // Low, Medium, High
  bool _quietHoursEnabled = false;
  String _quietHoursStart = '22:00';
  String _quietHoursEnd = '06:00';

  List<SmartNotification> get notifications => _notifications;
  bool get workoutReminders => _workoutReminders;
  bool get mealReminders => _mealReminders;
  bool get waterReminders => _waterReminders;
  String get frequency => _frequency;
  bool get quietHoursEnabled => _quietHoursEnabled;
  String get quietHoursStart => _quietHoursStart;
  String get quietHoursEnd => _quietHoursEnd;

  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void toggleWorkoutReminders(bool val) {
    _workoutReminders = val;
    notifyListeners();
  }

  void toggleMealReminders(bool val) {
    _mealReminders = val;
    notifyListeners();
  }

  void toggleWaterReminders(bool val) {
    _waterReminders = val;
    notifyListeners();
  }

  void setFrequency(String val) {
    _frequency = val;
    notifyListeners();
  }

  void toggleQuietHours(bool val) {
    _quietHoursEnabled = val;
    notifyListeners();
  }

  void updateQuietHoursRange(String start, String end) {
    _quietHoursStart = start;
    _quietHoursEnd = end;
    notifyListeners();
  }

  void markAllAsRead() {
    for (var n in _notifications) {
      n.isRead = true;
    }
    notifyListeners();
  }

  void markAsRead(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _notifications[idx].isRead = true;
      notifyListeners();
    }
  }

  void snoozeNotification(String id) {
    final idx = _notifications.indexWhere((n) => n.id == id);
    if (idx != -1) {
      final notif = _notifications[idx];
      _notifications.removeAt(idx);
      // Re-schedule 15 minutes later (simulated by appending to notification list with updated time)
      _notifications.insert(
        0,
        SmartNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: '[Snoozed] ${notif.title}',
          body: notif.body,
          timestamp: DateTime.now().add(const Duration(minutes: 15)),
          category: notif.category,
          coachName: notif.coachName,
        ),
      );
      notifyListeners();
    }
  }

  void triggerMockNotification(UserProfile profile, String activeCoach, String category) {
    String title = '';
    String body = '';

    if (activeCoach == 'Dr. Blue') {
      if (category == 'Workout') {
        title = 'Workout Reminder - Dr. Blue';
        body = 'Discipline beats motivation. Get your training split done today and log it!';
      } else if (category == 'Streak') {
        title = 'Streak Alert - Dr. Blue';
        body = 'Do not let your hard work break. Finish today’s checks and keep progressing.';
      } else {
        title = 'Fuel Alert - Dr. Blue';
        body = 'Hit your protein goals today. High-quality fuel triggers high-quality transformation.';
      }
    } else {
      // Dr. Pink tone
      if (category == 'Workout') {
        title = 'Movement Routine - Dr. Pink';
        body = 'Listen to your body today. If you feel tired, try a gentle child’s pose or recovery stretch.';
      } else if (category == 'Streak') {
        title = 'Empathetic Check - Dr. Pink';
        body = 'No pressure, but taking 1 minute to log your day keeps you aligned with your long-term wellness.';
      } else {
        title = 'Nourish Check - Dr. Pink';
        body = 'Try adding some iron-rich green veggies or yogurt to stay vibrant today.';
      }
    }

    _notifications.insert(
      0,
      SmartNotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        body: body,
        timestamp: DateTime.now(),
        category: category,
        coachName: activeCoach,
      ),
    );
    notifyListeners();
  }
}
