import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class Exercise {
  final String name;
  final int sets;
  final int reps;
  final int restTimeSeconds;
  final String targetMuscle;
  final String difficulty;
  final List<String> instructions;
  final List<String> safetyTips;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.restTimeSeconds,
    required this.targetMuscle,
    required this.difficulty,
    required this.instructions,
    required this.safetyTips,
  });
}

class DailyWorkout {
  final String dayName;
  final String workoutName;
  final int durationMinutes;
  final int estimatedCaloriesBurned;
  final List<Exercise> warmUp;
  final List<Exercise> exercises;
  final List<Exercise> coolDown;

  DailyWorkout({
    required this.dayName,
    required this.workoutName,
    required this.durationMinutes,
    required this.estimatedCaloriesBurned,
    required this.warmUp,
    required this.exercises,
    required this.coolDown,
  });
}

class WorkoutProvider extends ChangeNotifier {
  List<DailyWorkout> _weeklyWorkoutPlan = [];
  int _selectedDayIndex = 0;
  List<String> _workoutHistory = [];

  // Active workout session trackers
  bool _isSessionActive = false;
  DailyWorkout? _activeWorkoutSession;
  int _currentExerciseIndex = 0; // 0: Warmup, 1+: Exercises, Last: Cooldown
  bool _isResting = false;
  int _timerSeconds = 0;
  Timer? _workoutTimer;

  List<DailyWorkout> get weeklyWorkoutPlan => _weeklyWorkoutPlan;
  int get selectedDayIndex => _selectedDayIndex;
  DailyWorkout? get activeDayWorkout => _weeklyWorkoutPlan.isNotEmpty ? _weeklyWorkoutPlan[_selectedDayIndex] : null;
  List<String> get workoutHistory => _workoutHistory;

  bool get isSessionActive => _isSessionActive;
  DailyWorkout? get activeWorkoutSession => _activeWorkoutSession;
  int get currentExerciseIndex => _currentExerciseIndex;
  bool get isResting => _isResting;
  int get timerSeconds => _timerSeconds;

  void selectDay(int index) {
    if (index >= 0 && index < _weeklyWorkoutPlan.length) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  void startWorkoutSession(DailyWorkout workout) {
    _isSessionActive = true;
    _activeWorkoutSession = workout;
    _currentExerciseIndex = 0;
    _isResting = false;
    _timerSeconds = 0;
    notifyListeners();
  }

  void startRestTimer(int durationSeconds) {
    _isResting = true;
    _timerSeconds = durationSeconds;
    notifyListeners();

    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        _timerSeconds--;
        notifyListeners();
      } else {
        _isResting = false;
        timer.cancel();
        notifyListeners();
      }
    });
  }

  void nextExercise() {
    if (_activeWorkoutSession == null) return;
    final totalSteps = 1 + _activeWorkoutSession!.exercises.length + 1; // warmup + exercises + cooldown
    if (_currentExerciseIndex < totalSteps - 1) {
      _currentExerciseIndex++;
      _isResting = false;
      _workoutTimer?.cancel();
      notifyListeners();
    } else {
      finishWorkoutSession();
    }
  }

  void finishWorkoutSession() {
    if (_activeWorkoutSession != null) {
      _workoutHistory.add('${_activeWorkoutSession!.workoutName} completed on ${DateTime.now().toLocal()}');
    }
    _isSessionActive = false;
    _activeWorkoutSession = null;
    _currentExerciseIndex = 0;
    _workoutTimer?.cancel();
    notifyListeners();
  }

  void cancelWorkoutSession() {
    _isSessionActive = false;
    _activeWorkoutSession = null;
    _currentExerciseIndex = 0;
    _workoutTimer?.cancel();
    notifyListeners();
  }

  void generateWeeklyWorkoutPlan(UserProfile profile, String activeCoach) {
    final bool home = !profile.gymAccess;
    final String exp = profile.workoutExperience; // Beginner, Intermediate, Advanced
    final String goal = profile.primaryGoal;

    final String baseType = home ? 'Home Bodyweight' : 'Gym Equipment';
    final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];

    _weeklyWorkoutPlan = days.map((day) {
      final isRest = day == 'Tuesday' || day == 'Thursday' || day == 'Saturday' || day == 'Sunday';
      if (isRest) {
        return DailyWorkout(
          dayName: day,
          workoutName: 'Active Recovery & Stretching',
          durationMinutes: 15,
          estimatedCaloriesBurned: 50,
          warmUp: [_getStretchExercise()],
          exercises: [_getStretchExercise()],
          coolDown: [_getStretchExercise()],
        );
      }

      return DailyWorkout(
        dayName: day,
        workoutName: '$goal - $baseType Split',
        durationMinutes: 45,
        estimatedCaloriesBurned: goal == 'Weight Loss' ? 350 : 250,
        warmUp: [_getWarmupExercise()],
        exercises: _getExercisesList(goal: goal, exp: exp, home: home, activeCoach: activeCoach, cyclePhase: profile.menstrualCycleStage),
        coolDown: [_getCoolDownExercise()],
      );
    }).toList();

    notifyListeners();
  }

  Exercise _getWarmupExercise() {
    return Exercise(
      name: 'Dynamic Joint Rotation & Arm Circles',
      sets: 1,
      reps: 15,
      restTimeSeconds: 30,
      targetMuscle: 'Shoulders & Rotator cuff',
      difficulty: 'Beginner',
      instructions: ['Stand with feet shoulder-width apart.', 'Rotate arms forward in circular motions.'],
      safetyTips: ['Do not rush the movement.', 'Keep shoulder blades back.'],
    );
  }

  Exercise _getCoolDownExercise() {
    return Exercise(
      name: 'Static Hamstring & Quad Stretch',
      sets: 1,
      reps: 10,
      restTimeSeconds: 10,
      targetMuscle: 'Hamstrings & Quadriceps',
      difficulty: 'Beginner',
      instructions: ['Sit on ground with one leg extended.', 'Lean forward gently from hips and hold.'],
      safetyTips: ['Do not bounce.', 'Breathe deeply during the stretch.'],
    );
  }

  Exercise _getStretchExercise() {
    return Exercise(
      name: 'Full Body Yin Yoga Stretching',
      sets: 1,
      reps: 5,
      restTimeSeconds: 15,
      targetMuscle: 'Spine, Hips, & Hamstrings',
      difficulty: 'Beginner',
      instructions: ['Perform child’s pose, cobra pose, and downward dog.', 'Hold each stretch for 30 seconds.'],
      safetyTips: ['Only stretch to mild tension, not pain.'],
    );
  }

  List<Exercise> _getExercisesList({
    required String goal,
    required String exp,
    required bool home,
    required String activeCoach,
    required String cyclePhase,
  }) {
    final List<Exercise> list = [];

    // Modify volume/sets based on coach
    int baseSets = 3;
    if (activeCoach == 'Dr. Blue') {
      baseSets = 4; // Dr. Blue strength hypertrophy focus adds more sets
    }
    
    // Modify volume/sets based on cycle phase (Dr. Pink)
    if (activeCoach == 'Dr. Pink') {
      if (cyclePhase == 'Menstrual' || cyclePhase == 'Luteal') {
        baseSets = 2; // Reduce sets to manage energy/cortisol drops
      }
    }

    if (home) {
      if (goal == 'Weight Loss' || goal == 'Fat Loss') {
        list.add(Exercise(
          name: 'Jumping Jacks / Shadow Boxing',
          sets: baseSets,
          reps: 30,
          restTimeSeconds: 45,
          targetMuscle: 'Cardio & Full Body',
          difficulty: exp,
          instructions: ['Stand straight, jump spreading legs and arms.', 'Return to start.'],
          safetyTips: ['Land softly on your toes.'],
        ));
        list.add(Exercise(
          name: 'Bodyweight Squats',
          sets: baseSets,
          reps: 20,
          restTimeSeconds: 60,
          targetMuscle: 'Quadriceps & Glutes',
          difficulty: exp,
          instructions: ['Lower hips like sitting in a chair.', 'Drive up through heels.'],
          safetyTips: ['Keep chest up.', 'Ensure knees do not cave in.'],
        ));
        list.add(Exercise(
          name: 'Pike Pushups / Standard Pushups',
          sets: baseSets,
          reps: 12,
          restTimeSeconds: 60,
          targetMuscle: 'Chest, Triceps, & Shoulders',
          difficulty: exp,
          instructions: ['Keep body straight.', 'Lower chest to floor and push up.'],
          safetyTips: ['Do not sag your hips.'],
        ));
      } else {
        // Muscle Gain / Strength Home
        list.add(Exercise(
          name: 'Tempo Squats (3s negative)',
          sets: baseSets,
          reps: 15,
          restTimeSeconds: 90,
          targetMuscle: 'Legs & Glutes',
          difficulty: exp,
          instructions: ['Lower slowly for 3 seconds.', 'Push up explosively.'],
          safetyTips: ['Ensure good spinal alignment.'],
        ));
        list.add(Exercise(
          name: 'Deficit Pushups',
          sets: baseSets,
          reps: 15,
          restTimeSeconds: 90,
          targetMuscle: 'Chest & Triceps',
          difficulty: exp,
          instructions: ['Elevate hands on blocks.', 'Push down through deep range.'],
          safetyTips: ['Keep elbows tucked at 45 degrees.'],
        ));
      }
    } else {
      // Gym Equipment
      if (goal == 'Weight Loss' || goal == 'Fat Loss') {
        list.add(Exercise(
          name: 'Treadmill Incline Interval Walk',
          sets: baseSets,
          reps: 10,
          restTimeSeconds: 30,
          targetMuscle: 'Cardio & Calves',
          difficulty: exp,
          instructions: ['Set incline to 10%, walk at 4.5 km/h.'],
          safetyTips: ['Ensure chest is tall, do not hold handrails.'],
        ));
        list.add(Exercise(
          name: 'Dumbbell Goblet Squats',
          sets: baseSets,
          reps: 15,
          restTimeSeconds: 60,
          targetMuscle: 'Legs',
          difficulty: exp,
          instructions: ['Hold dumbbell at chest.', 'Squat deep.'],
          safetyTips: ['Maintain natural lower back curve.'],
        ));
      } else {
        // Strength Hypertrophy Gym
        list.add(Exercise(
          name: 'Barbell Squats',
          sets: baseSets,
          reps: 8,
          restTimeSeconds: 120,
          targetMuscle: 'Quadriceps, Glutes, Core',
          difficulty: exp,
          instructions: ['Set bar on traps.', 'Squat parallel and stand.'],
          safetyTips: ['Ensure brace is active.'],
        ));
        list.add(Exercise(
          name: 'Dumbbell Bench Press',
          sets: baseSets,
          reps: 10,
          restTimeSeconds: 90,
          targetMuscle: 'Pectorals & Triceps',
          difficulty: exp,
          instructions: ['Press dumbbells up from chest.'],
          safetyTips: ['Keep wrists straight.'],
        ));
      }
    }

    return list;
  }
}
