import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/navigation/app_router.dart';
import 'providers/app_state.dart';
import 'providers/auth_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/dr_blue_provider.dart';
import 'providers/dr_pink_provider.dart';
import 'providers/nutrition_provider.dart';
import 'providers/workout_provider.dart';
import 'providers/analytics_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/brain_provider.dart';
import 'providers/evolution_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShapeUpApp());
}

class ShapeUpApp extends StatelessWidget {
  const ShapeUpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => DrBlueProvider()),
        ChangeNotifierProvider(create: (_) => DrPinkProvider()),
        ChangeNotifierProvider(create: (_) => NutritionProvider()),
        ChangeNotifierProvider(create: (_) => WorkoutProvider()),
        ChangeNotifierProvider(create: (_) => AnalyticsProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => BrainProvider()),
        ChangeNotifierProvider(create: (_) => EvolutionProvider()),
      ],
      child: Consumer<AppStateProvider>(
        builder: (context, appState, child) {
          return MaterialApp.router(
            title: 'ShapeUp - AI Weight Loss & Wellness',
            debugShowCheckedModeBanner: false,
            themeMode: appState.themeMode,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
