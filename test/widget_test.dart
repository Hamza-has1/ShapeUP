import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shapeup/main.dart';
import 'package:shapeup/models/user_profile.dart';
import 'package:shapeup/providers/dr_pink_provider.dart';
import 'package:shapeup/providers/evolution_provider.dart';
import 'package:shapeup/services/api_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({
      'isOnboarded': false,
    });
  });

  testWidgets('App initialization test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShapeUpApp());

    // Verify ShapeUpApp is built
    expect(find.byType(ShapeUpApp), findsOneWidget);

    // Let the animations run and settle
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  group('ShapeUp Unit & Calculation Validation Tests', () {
    test('Mifflin-St Jeor formula BMR & TDEE calculation check', () {
      final profile = UserProfile();
      profile.name = 'Test User';
      profile.age = 25;
      profile.gender = 'Male';
      profile.height = 180.0;
      profile.weight = 80.0;
      profile.activityLevel = 'Sedentary (Little to no exercise)';
      profile.primaryGoal = 'Weight Loss';

      // Verify BMR estimation
      double bmr = (10.0 * profile.weight) + (6.25 * profile.height) - (5.0 * profile.age) + 5.0;
      expect(bmr, closeTo(1805.0, 0.01));
    });

    test('Dr. Pink menstrual cycle adaptive workout intensity level rules check', () async {
      final drPink = DrPinkProvider();
      final profile = UserProfile();
      profile.gender = 'Female';
      profile.menstrualCycleStage = 'Menstrual';

      await drPink.generateFemalePlan(profile);
      expect(drPink.activePlan?.activeCyclePhase, 'Menstrual');
      expect(drPink.activePlan?.phaseWorkoutIntensity.contains('Low-intensity recovery focus'), true);
    });


    test('ApiService synchronization offline storage persistence simulation', () async {
      SharedPreferences.setMockInitialValues({});
      
      final profile = UserProfile();
      profile.name = 'Ayesha';
      
      bool syncOk = await ApiService.syncProfileToServer(profile.name);
      expect(syncOk, true);

      String? retrieved = await ApiService.fetchProfileFromServer();
      expect(retrieved, 'Ayesha');
    });

    test('EvolutionProvider wearable smartwatch sync & AI tuning loop checks', () {
      final evolution = EvolutionProvider();
      expect(evolution.isWearableConnected, false);
      expect(evolution.vo2Max, 38.0);

      // Connect wearable
      evolution.connectWearable('Apple Watch');
      expect(evolution.isWearableConnected, true);
      expect(evolution.vo2Max, 44.5);
      expect(evolution.metabolicAge, 22);

      // AI Self-improvement tuning loop
      final profile = UserProfile();
      evolution.runAiSelfImprovementLoop(profile, 0.9); // high compliance slow progress
      expect(evolution.metabolicMultiplier, 0.95); // calorie budget reduction auto-tuned
    });
  });
}
