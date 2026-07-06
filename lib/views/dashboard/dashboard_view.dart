import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/design_system.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/nutrition_provider.dart';
import '../../providers/workout_provider.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/brain_provider.dart';
import '../../providers/evolution_provider.dart';
import '../../providers/app_state.dart';
import 'widgets/progress_chart.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  int _activeTab = 0; // 0: Home, 1: Workout, 2: Nutrition, 3: Profile
  final TextEditingController _weightController = TextEditingController();

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileProvider = context.watch<ProfileProvider>();
    final authProvider = context.watch<AuthProvider>();
    final appState = context.watch<AppStateProvider>();
    final nutritionProvider = context.watch<NutritionProvider>();
    final workoutProvider = context.watch<WorkoutProvider>();
    final analyticsProvider = context.watch<AnalyticsProvider>();
    final notificationProvider = context.watch<NotificationProvider>();
    final brainProvider = context.watch<BrainProvider>();
    final evolutionProvider = context.watch<EvolutionProvider>();

    // Redirect to Health Assessment onboarding only if the user is not marked as onboarded
    if (!appState.isOnboarded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/onboarding');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // If onboarded but profile is still loading from storage, show loader instead of redirecting
    if (profileProvider.profile.name.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Auto-generate plans if not loaded
    if (nutritionProvider.weeklyPlan.isEmpty) {
      nutritionProvider.generateWeeklyMealPlan(profileProvider.profile, appState.selectedCoach);
    }
    if (workoutProvider.weeklyWorkoutPlan.isEmpty) {
      workoutProvider.generateWeeklyWorkoutPlan(profileProvider.profile, appState.selectedCoach);
    }

    // Update brain decisions
    brainProvider.recomputeBrainState(profileProvider.profile, workoutProvider.workoutHistory.length, nutritionProvider.cheatMealLogged);

    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.luxuryDarkGradient : AppColors.luxuryLightGradient,
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: IndexedStack(
                    index: _activeTab,
                    children: [
                      _buildHomeTab(context, authProvider, profileProvider, brainProvider, workoutProvider, nutritionProvider),
                      _buildWorkoutTab(context, profileProvider, workoutProvider, appState.selectedCoach),
                      _buildNutritionTab(context, profileProvider, nutritionProvider, appState.selectedCoach),
                      _buildProfileTab(context, authProvider, profileProvider, analyticsProvider, notificationProvider, appState, evolutionProvider),
                    ],
                  ),
                ),
                
                // Footer persistent navigation
                _buildFooterNavigation(isDark),
              ],
            ),
          ),

          // Start Workout Fullscreen Guided Mode
          if (workoutProvider.isSessionActive)
            _buildActiveWorkoutSessionOverlay(context, workoutProvider),
        ],
      ),
    );
  }

  Widget _buildHomeTab(
    BuildContext context, 
    AuthProvider auth, 
    ProfileProvider profileState,
    BrainProvider brain,
    WorkoutProvider workout,
    NutritionProvider nutrition,
  ) {
    final profile = profileState.profile;
    final appState = context.watch<AppStateProvider>();

    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(milliseconds: 1000));
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getGreetingText(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                              letterSpacing: 1.0,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        profile.name,
                        style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ThemeMode nextMode;
                          String modeName;
                          if (appState.themeMode == ThemeMode.system) {
                            nextMode = ThemeMode.light;
                            modeName = 'Light Mode';
                          } else if (appState.themeMode == ThemeMode.light) {
                            nextMode = ThemeMode.dark;
                            modeName = 'Dark Mode';
                          } else {
                            nextMode = ThemeMode.system;
                            modeName = 'Automated with device (System)';
                          }
                          appState.setThemeMode(nextMode);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Theme: $modeName'),
                              duration: const Duration(seconds: 1),
                              backgroundColor: AppColors.primaryPurple,
                            ),
                          );
                        },
                        icon: Icon(
                          appState.themeMode == ThemeMode.system
                              ? Icons.brightness_auto_rounded
                              : appState.themeMode == ThemeMode.light
                                  ? Icons.wb_sunny_rounded
                                  : Icons.mode_night_rounded,
                          color: AppColors.primaryPurple,
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.primaryPurple.withOpacity(0.2),
                        child: Text(
                          profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U',
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animateEntrance(delayMs: 50),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverToBoxAdapter(
              child: ResponsiveLayout(
                mobile: _buildVerticalLayout(context, profileState, brain, workout, nutrition),
                desktop: _buildGridLayout(context, profileState, brain, workout, nutrition),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalLayout(
    BuildContext context, 
    ProfileProvider profileState,
    BrainProvider brain,
    WorkoutProvider workout,
    NutritionProvider nutrition,
  ) {
    return Column(
      children: [
        _buildHeroSummaryCard(context, profileState),
        const SizedBox(height: 20),
        _buildShapeUpBrainWidget(context, brain),
        const SizedBox(height: 20),
        _buildDailyGoalPanel(context, profileState),
        const SizedBox(height: 20),
        _buildProgressSection(context),
        const SizedBox(height: 20),
        _buildMotivationQuote(context, profileState),
        const SizedBox(height: 20),
        _buildScheduleSection(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildGridLayout(
    BuildContext context, 
    ProfileProvider profileState,
    BrainProvider brain,
    WorkoutProvider workout,
    NutritionProvider nutrition,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            children: [
              _buildHeroSummaryCard(context, profileState),
              const SizedBox(height: 20),
              _buildShapeUpBrainWidget(context, brain),
              const SizedBox(height: 20),
              _buildProgressSection(context),
              const SizedBox(height: 20),
              _buildDailyGoalPanel(context, profileState),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _buildMotivationQuote(context, profileState),
              const SizedBox(height: 20),
              _buildScheduleSection(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSummaryCard(BuildContext context, ProfileProvider state) {
    final profile = state.profile;
    final bmi = profile.bmi;
    final progress = _calculateGoalProgress(profile.weight, profile.goalWeight, profile.primaryGoal);

    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HEALTH SUMMARY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPurple,
                      letterSpacing: 0.5,
                    ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _getBmiColor(bmi).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'BMI: ${bmi.toStringAsFixed(1)} - ${_getBmiLabel(bmi)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _getBmiColor(bmi),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${profile.weight.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const Text('Current weight', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
              const Icon(Icons.arrow_forward_rounded, color: Colors.grey),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.goalWeight.toStringAsFixed(1)} kg',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: AppColors.primaryPurple,
                        ),
                  ),
                  const Text('Goal weight', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Goal target progress',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    ).animateScaleEntrance(delayMs: 100);
  }

  Widget _buildShapeUpBrainWidget(BuildContext context, BrainProvider brain) {
    return GestureDetector(
      onTap: () => _showBrainConsoleModal(context, brain),
      child: GlassContainer(
        opacity: 0.08,
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.psychology_outlined, color: AppColors.primaryPurple, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'SHAPEUP BRAIN Reasoning Engine',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryPurple,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Compliance Rate: ${brain.complianceScore.round()}% | Drop-off Risk: ${brain.dropoffRisk.round()}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text('AI is continuously tracking your habits. Tap to open predictions & console decisions.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.grey, size: 16),
          ],
        ),
      ).animateScaleEntrance(delayMs: 120),
    );
  }

  void _showBrainConsoleModal(BuildContext context, BrainProvider brain) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return GlassContainer(
              opacity: 0.1,
              blur: 25,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: Container(
                color: isDark ? AppColors.darkCardBg.withOpacity(0.95) : AppColors.lightCardBg.withOpacity(0.95),
                padding: const EdgeInsets.all(24),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(10)))),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('ShapeUp Brain Intelligence Console', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    const Text('PREDICTIVE TRAJECTORIES', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Column(
                      children: brain.predictions.map((p) {
                        return ListTile(
                          leading: const Icon(Icons.timeline_rounded, color: AppColors.primaryPurple),
                          title: Text(p.metric, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          subtitle: Text(p.forecast, style: const TextStyle(fontSize: 12)),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                            child: Text('${(p.confidence * 100).round()}% conf', style: const TextStyle(fontSize: 10, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 20),
                    const Text('DYNAMIC PLAN ADAPTATIONS (AUTO-ADJUSTMENTS)', style: TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 8),
                    Column(
                      children: brain.suggestions.map((s) {
                        return Card(
                          color: AppColors.primaryPurple.withOpacity(0.04),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: AppColors.primaryPurple.withOpacity(0.1))),
                          child: ListTile(
                            leading: Icon(s.icon, color: AppColors.primaryPurple),
                            title: Text(s.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Text(s.action, style: const TextStyle(fontSize: 12)),
                            trailing: Text(s.coach, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, fontSize: 11)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDailyGoalPanel(BuildContext context, ProfileProvider state) {
    final profile = state.profile;
    
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DAILY GOALS TRACKER',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          _buildGoalProgressRow(
            icon: Icons.local_fire_department_rounded,
            label: 'Calorie Limit',
            value: '${profile.dailyCalorieEstimate.round()} kcal',
            progress: 0.0,
            color: Colors.redAccent,
          ),
          const SizedBox(height: 14),
          
          // Redesigned Water Intake with interactive glass icons
          _buildInteractiveWaterSection(context, state),
          
          const SizedBox(height: 14),
          _buildGoalProgressRow(
            icon: Icons.directions_walk_rounded,
            label: 'Target Steps',
            value: '8,000 steps',
            progress: 0.0,
            color: Colors.green,
          ),
        ],
      ),
    ).animateScaleEntrance(delayMs: 150);
  }

  Widget _buildInteractiveWaterSection(BuildContext context, ProfileProvider state) {
    final glasses = state.targetGlasses.clamp(4, 20);
    final consumed = state.consumedGlasses;
    final liters = state.consumedWaterLiters;
    final targetLiters = state.profile.waterIntake;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_rounded, color: Colors.blueAccent, size: 20),
                const SizedBox(width: 8),
                const Text('Water Log', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            Row(
              children: [
                Text(
                  '$consumed / $glasses glasses (${liters.toStringAsFixed(1)} / ${targetLiters.toStringAsFixed(1)} L)',
                  style: const TextStyle(color: Colors.blueAccent, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.refresh_rounded, color: Colors.grey, size: 16),
                  onPressed: () => state.recordWaterIntake(0.0),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: List.generate(glasses, (index) {
            final active = index < consumed;
            return GestureDetector(
              onTap: () {
                // Tapping index records index + 1 glasses
                state.recordWaterIntake((index + 1) * 0.25);
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: active ? Colors.blueAccent.withOpacity(0.15) : AppColors.primaryPurple.withOpacity(0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: active ? Colors.blueAccent : Colors.grey.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.local_drink_rounded,
                  color: active ? Colors.blueAccent : Colors.grey.shade400,
                  size: 20,
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGoalProgressRow({
    required IconData icon,
    required String label,
    required String value,
    required double progress,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(value, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY WEIGHT TREND',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          const ProgressChart(
            dataPoints: [72.4, 71.8, 71.5, 71.0, 70.8, 70.4, 70.0],
            labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          ),
        ],
      ),
    ).animateScaleEntrance(delayMs: 300);
  }

  Widget _buildMotivationQuote(BuildContext context, ProfileProvider state) {
    final goal = state.profile.primaryGoal;
    String quote = 'Success is built on small positive habits daily.';
    if (goal == 'Weight Loss') {
      quote = 'Every step forward is one step closer to a lighter, healthier version of you.';
    } else if (goal == 'Muscle Gain') {
      quote = 'Focus on progress, not perfection. Build strength and feed your potential.';
    }
    
    return GlassContainer(
      opacity: 0.04,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          const Icon(Icons.format_quote_rounded, color: AppColors.primaryPurple, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              quote,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    ).animateScaleEntrance(delayMs: 320);
  }

  Widget _buildScheduleSection(BuildContext context) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LESSONS / SCHEDULE TODAY',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryPurple,
                  letterSpacing: 0.5,
                ),
          ),
          const SizedBox(height: 16),
          _buildScheduleItem(Icons.fitness_center_rounded, 'Daily Workout Suggestion', '30 min active cardio session'),
          const SizedBox(height: 12),
          _buildScheduleItem(Icons.water_drop_rounded, 'Hydration Reminder', 'Drink 500ml water now'),
        ],
      ),
    ).animateScaleEntrance(delayMs: 340);
  }

  Widget _buildScheduleItem(IconData icon, String title, String subtitle) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.primaryPurple.withOpacity(0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primaryPurple, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------- NUTRITION TAB VIEW ----------------
  Widget _buildNutritionTab(BuildContext context, ProfileProvider profileState, NutritionProvider nutrition, String activeCoach) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (nutrition.weeklyPlan.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeDayPlan = nutrition.activeDayPlan!;
    final appState = context.watch<AppStateProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Nutrition Planner',
              style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ThemeMode nextMode;
                    String modeName;
                    if (appState.themeMode == ThemeMode.system) {
                      nextMode = ThemeMode.light;
                      modeName = 'Light Mode';
                    } else if (appState.themeMode == ThemeMode.light) {
                      nextMode = ThemeMode.dark;
                      modeName = 'Dark Mode';
                    } else {
                      nextMode = ThemeMode.system;
                      modeName = 'Automated with device (System)';
                    }
                    appState.setThemeMode(nextMode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme: $modeName'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primaryPurple,
                      ),
                    );
                  },
                  icon: Icon(
                    appState.themeMode == ThemeMode.system
                        ? Icons.brightness_auto_rounded
                        : appState.themeMode == ThemeMode.light
                            ? Icons.wb_sunny_rounded
                            : Icons.mode_night_rounded,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple),
                  onPressed: () => _showShoppingListModal(context, nutrition),
                ),
              ],
            ),
          ],
        ).animateEntrance(delayMs: 100),
        const SizedBox(height: 16),

        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nutrition.weeklyPlan.length,
            itemBuilder: (context, index) {
              final plan = nutrition.weeklyPlan[index];
              final isSel = nutrition.selectedDayIndex == index;
              return GestureDetector(
                onTap: () => nutrition.selectDay(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.primaryPurple.withOpacity(0.1)),
                  ),
                  child: Center(
                    child: Text(
                      plan.dayName.substring(0, 3),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSel ? Colors.white : AppColors.primaryPurple,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ).animateEntrance(delayMs: 120),
        const SizedBox(height: 20),

        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'DAILY BUDGET: ${profileState.profile.dailyCalorieEstimate.round() + nutrition.calorieOffset.round()} kcal',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryPurple),
                  ),
                  if (nutrition.cheatMealLogged)
                    const Text('Cheat meal offset active (-250)', style: TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMacroProgress('Protein', '${profileState.profile.recommendedProteinIntake.round()}g', 0.5, Colors.redAccent),
                  _buildMacroProgress('Carbs', '220g', 0.5, Colors.amber),
                  _buildMacroProgress('Fats', '65g', 0.5, Colors.blue),
                ],
              ),
            ],
          ),
        ).animateScaleEntrance(delayMs: 140),
        const SizedBox(height: 20),

        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _showCheatMealDialog(context, nutrition),
                icon: const Icon(Icons.cake_outlined, size: 18),
                label: const Text('Log Cheat Meal', style: TextStyle(fontSize: 12)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _showSmartSuggestionsModal(context, profileState.profile),
                icon: const Icon(Icons.assistant_outlined, size: 18),
                label: const Text('What to eat now?', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ).animateEntrance(delayMs: 160),
        const SizedBox(height: 20),

        if (nutrition.cheatMealLogged) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(nutrition.cheatMealRecoveryTip, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.brown)),
          ),
          const SizedBox(height: 16),
        ],

        _buildMealCard(context, 'Breakfast', activeDayPlan.breakfast),
        _buildMealCard(context, 'Mid-Morning Snack', activeDayPlan.midMorningSnack),
        _buildMealCard(context, 'Lunch', activeDayPlan.lunch),
        _buildMealCard(context, 'Evening Snack', activeDayPlan.eveningSnack),
        _buildMealCard(context, 'Dinner', activeDayPlan.dinner),
      ],
    );
  }

  Widget _buildMealCard(BuildContext context, String mealType, Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassContainer(
        opacity: 0.04,
        padding: const EdgeInsets.all(20),
        child: ExpansionTile(
          shape: const Border(),
          iconColor: AppColors.primaryPurple,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(mealType, style: const TextStyle(fontSize: 12, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
              Text('${meal.calories.round()} kcal', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                Text(meal.portion, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Description', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  Text(meal.description, style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 12),

                  Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.ingredients.map((ing) => Text('• $ing', style: const TextStyle(fontSize: 13))).toList(),
                  ),
                  const SizedBox(height: 12),

                  Text('Preparation', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.instructions.map((ins) => Text('• $ins', style: const TextStyle(fontSize: 13))).toList(),
                  ),
                  const SizedBox(height: 12),

                  Text('Healthy Alternatives / Substitutes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey.shade700)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: meal.substitutions.map((sub) => Text('• $sub', style: const TextStyle(fontSize: 13, color: AppColors.primaryPurple))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WORKOUT PAGE REDESIGN ----------------
  Widget _buildWorkoutTab(BuildContext context, ProfileProvider profileState, WorkoutProvider workout, String activeCoach) {
    if (workout.weeklyWorkoutPlan.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final activeDayWorkout = workout.activeDayWorkout!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appState = context.watch<AppStateProvider>();

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'FITNESS PLANNER',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryPurple,
                        letterSpacing: 1.0,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Training',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ThemeMode nextMode;
                    String modeName;
                    if (appState.themeMode == ThemeMode.system) {
                      nextMode = ThemeMode.light;
                      modeName = 'Light Mode';
                    } else if (appState.themeMode == ThemeMode.light) {
                      nextMode = ThemeMode.dark;
                      modeName = 'Dark Mode';
                    } else {
                      nextMode = ThemeMode.system;
                      modeName = 'Automated with device (System)';
                    }
                    appState.setThemeMode(nextMode);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Theme: $modeName'),
                        duration: const Duration(seconds: 1),
                        backgroundColor: AppColors.primaryPurple,
                      ),
                    );
                  },
                  icon: Icon(
                    appState.themeMode == ThemeMode.system
                        ? Icons.brightness_auto_rounded
                        : appState.themeMode == ThemeMode.light
                            ? Icons.wb_sunny_rounded
                            : Icons.mode_night_rounded,
                    color: AppColors.primaryPurple,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: AppColors.primaryPurple, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        '${workout.workoutHistory.length} Sessions',
                        style: const TextStyle(fontSize: 12, color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ).animateEntrance(delayMs: 100),
        const SizedBox(height: 20),

        // Rotating Week Day Cards Carousel
        SizedBox(
          height: 64,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: workout.weeklyWorkoutPlan.length,
            itemBuilder: (context, index) {
              final plan = workout.weeklyWorkoutPlan[index];
              final isSel = workout.selectedDayIndex == index;
              return GestureDetector(
                onTap: () => workout.selectDay(index),
                child: Container(
                  margin: const EdgeInsets.only(right: 10),
                  width: 58,
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSel ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.12)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        plan.dayName.substring(0, 3).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: isSel ? Colors.white : AppColors.primaryPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ).animateEntrance(delayMs: 120),
        const SizedBox(height: 24),

        // Big Main Guided Panel Card
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      activeDayWorkout.workoutName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Ready',
                      style: TextStyle(color: AppColors.primaryPurple, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text('${activeDayWorkout.durationMinutes} mins', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 16),
                  const Icon(Icons.local_fire_department_rounded, color: Colors.grey, size: 16),
                  const SizedBox(width: 4),
                  Text('~${activeDayWorkout.estimatedCaloriesBurned} kcal', style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 20),
              NeonGradientButton(
                text: 'Start Guided Session Now',
                onPressed: () => workout.startWorkoutSession(activeDayWorkout),
                icon: Icons.play_arrow_rounded,
              ),
            ],
          ),
        ).animateScaleEntrance(delayMs: 140),
        const SizedBox(height: 24),

        // Collapsible Exercise Categories Section
        Text('WARM-UP SPLIT', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ...activeDayWorkout.warmUp.map((ex) => _buildRedesignedExerciseCard(context, ex)),
        
        const SizedBox(height: 20),
        Text('MAIN TRAINING PROGRAM', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ...activeDayWorkout.exercises.map((ex) => _buildRedesignedExerciseCard(context, ex)),

        const SizedBox(height: 20),
        Text('COOL-DOWN & FLEXIBILITY', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
        const SizedBox(height: 10),
        ...activeDayWorkout.coolDown.map((ex) => _buildRedesignedExerciseCard(context, ex)),
      ],
    );
  }

  Widget _buildRedesignedExerciseCard(BuildContext context, Exercise ex) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        opacity: 0.04,
        padding: const EdgeInsets.all(16),
        child: ExpansionTile(
          shape: const Border(),
          iconColor: AppColors.primaryPurple,
          collapsedIconColor: Colors.grey,
          title: Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    ex.targetMuscle.toUpperCase(),
                    style: const TextStyle(fontSize: 9, color: AppColors.primaryPurple, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${ex.sets} Sets x ${ex.reps} Reps',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Instructions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ex.instructions.map((ins) => Text('• $ins', style: const TextStyle(fontSize: 12))).toList(),
                  ),
                  const SizedBox(height: 12),
                  const Text('Safety Guidelines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
                  const SizedBox(height: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: ex.safetyTips.map((tip) => Text('• $tip', style: const TextStyle(fontSize: 12, color: AppColors.primaryPurple))).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- PROFILE & SETTINGS TAB VIEW (REAL-TIME DATA) ----------------
  Widget _buildProfileTab(
    BuildContext context, 
    AuthProvider auth, 
    ProfileProvider profileState, 
    AnalyticsProvider analytics,
    NotificationProvider notif,
    AppStateProvider state,
    EvolutionProvider evolution,
  ) {
    final double targetW = profileState.profile.goalWeight;
    final List<double> weightPoints = analytics.weightHistory.map((e) => e.weight).toList();
    final List<String> labels = analytics.weightHistory.map((e) => '${e.date.day}/${e.date.month}').toList();
    
    // Real progress metrics calculation
    final workoutLogs = analytics.workoutStreak;
    final complPercent = analytics.healthScore;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: Column(
            children: [
              Text(
                profileState.profile.name,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(auth.userEmail ?? '', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
            ],
          ),
        ),

        // Real Profile Completion & Goal Progress Card
        Text('Real-Time Transformation Progress', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProgressMetricRow('Profile Setup Completion', '100% (Onboarded)', 1.0),
              const SizedBox(height: 14),
              _buildProgressMetricRow('Daily Water Goal Log', '${profileState.consumedWaterLiters.toStringAsFixed(1)} / ${profileState.profile.waterIntake.toStringAsFixed(1)} L', (profileState.consumedWaterLiters / profileState.profile.waterIntake).clamp(0.0, 1.0)),
              const SizedBox(height: 14),
              _buildProgressMetricRow('Goal Adherence Score', '$complPercent%', complPercent / 100.0),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Wearable Integration & Biomarkers Sync Panel
        Text('Wearable Sync & Biomarkers Hub', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('SMARTWATCH CONNECTION', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: evolution.isWearableConnected ? AppColors.primaryPurple.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      evolution.isWearableConnected ? 'Connected: ${evolution.connectedDeviceName}' : 'Disconnected',
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryPurple),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (!evolution.isWearableConnected)
                Wrap(
                  spacing: 12,
                  children: [
                    ElevatedButton(
                      onPressed: () => evolution.connectWearable('Apple Watch'),
                      child: const Text('Connect Apple Watch', style: TextStyle(fontSize: 11)),
                    ),
                    ElevatedButton(
                      onPressed: () => evolution.connectWearable('Garmin Fenix'),
                      child: const Text('Connect Garmin', style: TextStyle(fontSize: 11)),
                    ),
                  ],
                )
              else
                OutlinedButton(
                  onPressed: () => evolution.disconnectWearable(),
                  child: const Text('Disconnect Device', style: TextStyle(fontSize: 11)),
                ),
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              const Text('ADVANCED BIO-MARKERS (FETCED SENSOR DATA)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppColors.primaryPurple)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildBiomarkerTile('VO2 Max', '${evolution.vo2Max} ml/kg', 'Good'),
                  _buildBiomarkerTile('Metabolic Age', '${evolution.metabolicAge} yrs', 'Fit'),
                  _buildBiomarkerTile('Body Fat', '${evolution.bodyFatPercentage}%', 'Healthy'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // AI Self-Improvement Loop Console
        Text('AI Self-Improvement & Evolution Console', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('METABOLIC BUDGET MULTIPLIER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
                  Text('${evolution.metabolicMultiplier}x multiplier', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('The AI analysis loop tracks your outcomes and scales caloric/workout multipliers automatically.', style: TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('AI Accuracy: ${evolution.aiRecommendationAccuracy}%', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('API Latency: ${evolution.apiLatencyMs}ms', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text('Friction Score: ${evolution.uxFrictionScore}/10', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  evolution.runAiSelfImprovementLoop(profileState.profile, 0.9); // force slow progress adaptation loop
                },
                child: const Text('Force AI Loop Recalibration', style: TextStyle(fontSize: 11)),
              ),
              const SizedBox(height: 12),
              const Text('Evolution Logs:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
              const SizedBox(height: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: evolution.evolutionLogs.take(2).map((log) => Text('• $log', style: const TextStyle(fontSize: 10, color: Colors.grey))).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Weight chart & Log Form
        Text('Weight Progress Analytics', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('WEIGHT TREND HISTORY', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
                  Text('Target: $targetW kg', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                ],
              ),
              const SizedBox(height: 16),
              ProgressChart(dataPoints: weightPoints, labels: labels),
            ],
          ),
        ).animateScaleEntrance(delayMs: 160),
        const SizedBox(height: 20),

        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: LuxuryTextField(
                  label: 'LOG TODAY\'S WEIGHT (KG)',
                  hint: '70.0',
                  controller: _weightController,
                  prefixIcon: Icons.scale_rounded,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                margin: const EdgeInsets.only(top: 24),
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    final val = double.tryParse(_weightController.text);
                    if (val != null) {
                      analytics.addWeightEntry(val);
                      _weightController.clear();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Weight logged successfully!'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  child: const Text('Log'),
                ),
              ),
            ],
          ),
        ).animateEntrance(delayMs: 180),
        const SizedBox(height: 24),

        // Manual Theme Settings Mode Selector
        Text('App Themes & Preferences', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('THEME MODE PREFERENCE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildThemeOption(context, ThemeMode.system, 'System default', state),
                  _buildThemeOption(context, ThemeMode.light, 'Light Mode', state),
                  _buildThemeOption(context, ThemeMode.dark, 'Dark Mode', state),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Referral Accountability program
        Text('Accountability Referral Program', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('INVITE FRIENDS & GET FREE AI PREMIUM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppColors.primaryPurple)),
              const SizedBox(height: 8),
              const Text('Share your unique invite link. When a friend signs up and logs their first workout, you both get 7 days of premium AI advice free!', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Text('SHAPEUP-${profileState.profile.name.toUpperCase().replaceAll(' ', '')}-9820', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Referral link copied to clipboard! Share it with your friends.'), backgroundColor: AppColors.success),
                      );
                    },
                    child: const Text('Share Code', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Notification Preferences
        Text('Smart Notification Preferences', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 12),
        GlassContainer(
          opacity: 0.05,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Workout reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('AI alerts for training times', style: TextStyle(fontSize: 11)),
                value: notif.workoutReminders,
                activeColor: AppColors.primaryPurple,
                onChanged: (val) => notif.toggleWorkoutReminders(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Meal plan compliance', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: const Text('Reminders to track protein and carbs', style: TextStyle(fontSize: 11)),
                value: notif.mealReminders,
                activeColor: AppColors.primaryPurple,
                onChanged: (val) => notif.toggleMealReminders(val),
              ),
              const Divider(),
              SwitchListTile(
                title: const Text('Quiet Hours (No Disturb)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                subtitle: Text('Current range: ${notif.quietHoursStart} - ${notif.quietHoursEnd}', style: const TextStyle(fontSize: 11)),
                value: notif.quietHoursEnabled,
                activeColor: AppColors.primaryPurple,
                onChanged: (val) => notif.toggleQuietHours(val),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        ElevatedButton.icon(
          onPressed: () async {
            await auth.logout();
          },
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Log Out Session'),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () async {
            await profileState.resetProfileState();
            context.go('/onboarding');
          },
          child: const Text('Retake Health Assessment Wizard', style: TextStyle(color: Colors.redAccent)),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildThemeOption(BuildContext context, ThemeMode mode, String label, AppStateProvider state) {
    final active = state.themeMode == mode;
    return GestureDetector(
      onTap: () => state.setThemeMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryPurple : AppColors.primaryPurple.withOpacity(0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? AppColors.primaryPurple : Colors.grey.withOpacity(0.2)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : AppColors.primaryPurple,
          ),
        ),
      ),
    );
  }

  Widget _buildProgressMetricRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(value, style: const TextStyle(color: AppColors.primaryPurple, fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildBiomarkerTile(String title, String val, String status) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        const SizedBox(height: 2),
        Text(status, style: const TextStyle(color: AppColors.primaryPurple, fontSize: 9, fontWeight: FontWeight.bold)),
      ],
    );
  }


  // ----------------------------------------------------

  Widget _buildActiveWorkoutSessionOverlay(BuildContext context, WorkoutProvider workout) {
    final activeSession = workout.activeWorkoutSession!;
    final totalExercises = activeSession.exercises.length;
    final index = workout.currentExerciseIndex;

    Exercise activeEx = activeSession.warmUp.first;
    String phaseLabel = 'WARM-UP';

    if (index > 0 && index <= totalExercises) {
      activeEx = activeSession.exercises[index - 1];
      phaseLabel = 'EXERCISE $index OF $totalExercises';
    } else if (index > totalExercises) {
      activeEx = activeSession.coolDown.first;
      phaseLabel = 'COOL-DOWN';
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned.fill(
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: isDark ? AppColors.luxuryDarkGradient : AppColors.luxuryLightGradient,
          ),
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 28),
                      onPressed: () => workout.cancelWorkoutSession(),
                    ),
                    Text(
                      phaseLabel,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple, letterSpacing: 1.0),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                Expanded(
                  child: Center(
                    child: GlassContainer(
                      opacity: 0.05,
                      padding: const EdgeInsets.all(32),
                      child: workout.isResting
                          ? Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('REST TIME', style: TextStyle(letterSpacing: 1.5, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                                const SizedBox(height: 16),
                                Text(
                                  '${workout.timerSeconds}s',
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 64, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 16),
                                const Text('Prepare for the next exercise', style: TextStyle(color: Colors.grey)),
                              ],
                            )
                          : Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeEx.name,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Target: ${activeEx.targetMuscle}',
                                  style: const TextStyle(color: AppColors.primaryPurple, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  '${activeEx.sets} Sets x ${activeEx.reps} Reps',
                                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  activeEx.instructions.first,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (!workout.isResting)
                      TextButton(
                        onPressed: () => workout.startRestTimer(activeEx.restTimeSeconds),
                        child: const Text('Rest Timer', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                      )
                    else
                      const SizedBox.shrink(),
                    
                    SizedBox(
                      width: 160,
                      child: NeonGradientButton(
                        text: 'Next Move',
                        onPressed: () => workout.nextExercise(),
                        icon: Icons.check_circle_outline_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooterNavigation(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.black.withOpacity(0.9) : Colors.white.withOpacity(0.9),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.12))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(0, Icons.home_rounded, 'Home'),
          _buildNavItem(1, Icons.fitness_center_rounded, 'Workout'),
          _buildNavItem(2, Icons.restaurant_menu_rounded, 'Nutrition'),
          _buildNavItem(3, Icons.person_rounded, 'Profile'),
        ],
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final active = _activeTab == index;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primaryPurple : Colors.grey.shade500,
          ).animate(target: active ? 1 : 0).scale(begin: const Offset(1, 1), end: const Offset(1.15, 1.15), duration: 200.ms),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: active ? AppColors.primaryPurple : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  double _calculateGoalProgress(double current, double target, String goal) {
    if (goal == 'Weight Loss' || goal == 'Fat Loss') {
      if (current <= target) return 1.0;
      return 0.5;
    } else if (goal == 'Weight Gain' || goal == 'Muscle Gain') {
      if (current >= target) return 1.0;
      return 0.5;
    }
    return 1.0;
  }

  String _getGreetingText() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getBmiLabel(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }

  Widget _buildMacroProgress(String label, String value, double progress, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }

  void _showCheatMealDialog(BuildContext context, NutritionProvider nutrition) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Cheat Meal'),
          content: const Text('This adjusts next-day targets (-250 kcal offset) and provides recovery insights from Dr. Blue and Dr. Pink.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                nutrition.logCheatMeal('Pizza / Burgers');
                Navigator.pop(context);
              },
              child: const Text('Confirm Log'),
            ),
          ],
        );
      },
    );
  }

  void _showSmartSuggestionsModal(BuildContext context, dynamic profile) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return GlassContainer(
          opacity: 0.1,
          blur: 25,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
          child: Container(
            color: isDark ? AppColors.darkCardBg.withOpacity(0.95) : AppColors.lightCardBg.withOpacity(0.95),
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Smart Suggestions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 12),
                const Text('HEALTHY SWAP FOR CRUNCHY CRAVINGS:'),
                const SizedBox(height: 4),
                const Text('• Swap potato chips with roasted chickpeas or air-fried beetroot thin chips.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                const SizedBox(height: 16),
                const Text('SWEET TOOTH FIX:'),
                const SizedBox(height: 4),
                const Text('• Swap biscuits with Greek yogurt topped with fresh dates.', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryPurple)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showShoppingListModal(BuildContext context, NutritionProvider nutrition) {
    final list = nutrition.generateGroceryList();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return GlassContainer(
              opacity: 0.1,
              blur: 25,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: Container(
                color: isDark ? AppColors.darkCardBg.withOpacity(0.95) : AppColors.lightCardBg.withOpacity(0.95),
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.withOpacity(0.5), borderRadius: BorderRadius.circular(10))),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Weekly Shopping List', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.pop(context)),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: list.length,
                        itemBuilder: (context, index) {
                          final item = list[index];
                          return ListTile(
                            leading: const Icon(Icons.check_box_outline_blank_rounded, color: AppColors.primaryPurple),
                            title: Text(item['item']!),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.primaryPurple.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
                              child: Text(item['category']!, style: const TextStyle(fontSize: 10, color: AppColors.primaryPurple, fontWeight: FontWeight.bold)),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
