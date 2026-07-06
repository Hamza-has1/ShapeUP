import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shapeup/main.dart';
import 'package:shapeup/models/user_profile.dart';
import 'package:shapeup/providers/dr_pink_provider.dart';
import 'package:shapeup/providers/social_provider.dart';
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
    test('Harris-Benedict formula BMR & TDEE calculation check', () {
      final profile = UserProfile();
      profile.name = 'Test User';
      profile.age = 25;
      profile.gender = 'Male';
      profile.height = 180.0;
      profile.weight = 80.0;
      profile.activityLevel = 'Sedentary (Little to no exercise)';
      profile.primaryGoal = 'Weight Loss';

      // Verify BMR estimation
      double bmr = 88.362 + (13.397 * profile.weight) + (4.799 * profile.height) - (5.677 * profile.age);
      expect(bmr, closeTo(1882.017, 0.01));
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

    test('Social provider content moderation filter blocks abusive entries', () {
      final social = SocialProvider();
      
      // Clean post should pass
      bool resClean = social.addPost('Hamza', 'Finished a wonderful morning jog!');
      expect(resClean, true);

      // Abusive post should fail
      bool resAbuse = social.addPost('Hamza', 'You look ugly and fat');
      expect(resAbuse, false);
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
