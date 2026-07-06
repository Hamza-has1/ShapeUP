import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/design_system.dart';
import '../../core/utils/animations.dart';
import '../../core/utils/responsive_layout.dart';
import '../../providers/app_state.dart';
import '../../providers/profile_provider.dart';
import '../../providers/dr_blue_provider.dart';
import '../../providers/dr_pink_provider.dart';

class CoachesView extends StatefulWidget {
  const CoachesView({super.key});

  @override
  State<CoachesView> createState() => _CoachesViewState();
}

class _CoachesViewState extends State<CoachesView> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showDrBluePlanModal(BuildContext context, DrBluePlan plan) {
    _showPlanModalGeneric(
      context: context,
      title: 'Dr. Blue\'s Structured Plan',
      quote: plan.motivationalQuote,
      warnings: plan.warnings,
      sections: [
        _PlanSectionData('Goal Focus', plan.goalClassification, Icons.track_changes_rounded),
        _PlanSectionData('Caloric & Macro Targets', 
          'Daily target: ${plan.caloriesTarget.round()} kcal\n'
          'Protein: ${plan.proteinTarget.round()}g | Carbs: ${plan.carbsTarget.round()}g | Fat: ${plan.fatTarget.round()}g', 
          Icons.restaurant_menu_rounded),
        _PlanSectionData('Workout Structure', plan.workoutStructure, Icons.fitness_center_rounded),
        _PlanSectionData('Diet Plan Guide', plan.dietPlan, Icons.apple_rounded),
        _PlanSectionData('Rest & Cardio', plan.restAndCardioPlan, Icons.favorite_rounded),
        _PlanSectionData('Sleep & Hydration', plan.sleepAndHydrationPlan, Icons.water_drop_rounded),
        _PlanSectionData('Weekly Schedule', plan.weeklySchedule, Icons.calendar_today_rounded),
        _PlanSectionData('Priority Focus Items', plan.priorityFocus, Icons.star_rounded),
      ],
    );
  }

  void _showDrPinkPlanModal(BuildContext context, DrPinkPlan plan) {
    _showPlanModalGeneric(
      context: context,
      title: 'Dr. Pink\'s Cycle-Aware Plan',
      quote: plan.empatheticMotivation,
      warnings: plan.safetyWarnings,
      sections: [
        _PlanSectionData('Goal Focus', plan.goalClassification, Icons.track_changes_rounded),
        _PlanSectionData('Hormonal Calorie & Protein Targets', 
          'Daily target: ${plan.caloriesTarget.round()} kcal\n'
          'Protein: ${plan.proteinTarget.round()}g | Iron needs: ${plan.ironTargetMg.round()} mg', 
          Icons.restaurant_menu_rounded),
        _PlanSectionData('Active Cycle Phase', plan.activeCyclePhase, Icons.pregnant_woman_rounded),
        _PlanSectionData('Workout Adaptations', plan.phaseWorkoutIntensity, Icons.fitness_center_rounded),
        _PlanSectionData('Hormonal Diet Plan', plan.hormonalDietPlan, Icons.spa_rounded),
        _PlanSectionData('Sleep & Stress Control', plan.sleepAndStressPlan, Icons.bedtime_rounded),
        _PlanSectionData('Weekly Schedule', plan.weeklySchedule, Icons.calendar_today_rounded),
        _PlanSectionData('Hormonal Priority Focus', plan.priorityFocus, Icons.stars_rounded),
      ],
    );
  }

  void _showPlanModalGeneric({
    required BuildContext context,
    required String title,
    required String quote,
    required List<String> warnings,
    required List<_PlanSectionData> sections,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return GlassContainer(
              opacity: 0.1,
              blur: 25,
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
              child: Container(
                color: isDark ? AppColors.darkCardBg.withOpacity(0.9) : AppColors.lightCardBg.withOpacity(0.95),
                padding: const EdgeInsets.all(24),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),

                    ...sections.map((sec) => _buildPlanSection(context, sec.title, sec.content, sec.icon)),

                    if (warnings.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('SAFETY INSTRUCTIONS', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                      const SizedBox(height: 8),
                      Column(
                        children: warnings.map((w) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                              const SizedBox(width: 12),
                              Expanded(child: Text(w, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
                            ],
                          ),
                        )).toList(),
                      ),
                    ],

                    const SizedBox(height: 24),
                    Text(
                      '"$quote"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryPurple,
                          ),
                      textAlign: TextAlign.center,
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

  Widget _buildPlanSection(BuildContext context, String title, String content, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryPurple.withOpacity(0.06),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primaryPurple, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(content, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppStateProvider>();
    final profile = context.watch<ProfileProvider>().profile;
    final drBlue = context.watch<DrBlueProvider>();
    final drPink = context.watch<DrPinkProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Coach ${state.selectedCoach} Consult'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
      ),
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
                // Coach Select Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Active Advisor',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      // Quick Coach Toggle
                      DropdownButton<String>(
                        value: state.selectedCoach,
                        items: ['Dr. Blue', 'Dr. Pink'].map((String coach) {
                          return DropdownMenuItem<String>(value: coach, child: Text(coach));
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            context.read<AppStateProvider>().selectCoach(val);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                // Body area based on selected coach
                Expanded(
                  child: state.selectedCoach == 'Dr. Blue'
                      ? _buildDrBlueWorkspace(context, drBlue, profile)
                      : _buildDrPinkWorkspace(context, drPink, profile),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrBlueWorkspace(BuildContext context, DrBlueProvider drBlue, dynamic profile) {
    return Column(
      children: [
        if (drBlue.activePlan != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GlassContainer(
              opacity: 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Plan active for your goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ElevatedButton(
                    onPressed: () => _showDrBluePlanModal(context, drBlue.activePlan!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('View Generated Plan', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GlassContainer(
              opacity: 0.08,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Get your tailored health, diet, & gym workout plan customized dynamically based on your physical metrics.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  drBlue.isGenerating
                      ? const CircularProgressIndicator()
                      : NeonGradientButton(
                          text: 'Generate My Plan',
                          onPressed: () => drBlue.generatePlan(profile),
                        ),
                ],
              ),
            ),
          ),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: drBlue.chatHistory.length,
            itemBuilder: (context, index) {
              final msg = drBlue.chatHistory[index];
              return _buildChatBubble(context, msg['text'], msg['isMe']);
            },
          ),
        ),

        if (drBlue.isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text('Dr. Blue is typing...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),

        _buildMessageInputBar((txt) {
          drBlue.sendMessage(txt, profile);
          _scrollToBottom();
        }),
      ],
    );
  }

  Widget _buildDrPinkWorkspace(BuildContext context, DrPinkProvider drPink, dynamic profile) {
    return Column(
      children: [
        if (drPink.activePlan != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GlassContainer(
              opacity: 0.08,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Cycle plan active', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ElevatedButton(
                    onPressed: () => _showDrPinkPlanModal(context, drPink.activePlan!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      minimumSize: Size.zero,
                    ),
                    child: const Text('View Generated Plan', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: GlassContainer(
              opacity: 0.08,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text(
                    'Get cycle-aware training schedules, hormone-friendly diets, and wellness guides dynamically designed for you.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  drPink.isGenerating
                      ? const CircularProgressIndicator()
                      : NeonGradientButton(
                          text: 'Generate My Female Health Plan',
                          onPressed: () => drPink.generateFemalePlan(profile),
                        ),
                ],
              ),
            ),
          ),

        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            itemCount: drPink.chatHistory.length,
            itemBuilder: (context, index) {
              final msg = drPink.chatHistory[index];
              return _buildChatBubble(context, msg['text'], msg['isMe']);
            },
          ),
        ),

        if (drPink.isTyping)
          Padding(
            padding: const EdgeInsets.only(left: 24, bottom: 8),
            child: Row(
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 10),
                Text('Dr. Pink is typing...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),

        _buildMessageInputBar((txt) {
          drPink.sendMessage(txt, profile);
          _scrollToBottom();
        }),
      ],
    );
  }

  Widget _buildMessageInputBar(Function(String) onSend) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: LuxuryTextField(
              label: '',
              hint: 'Type a message...',
              controller: _msgController,
              prefixIcon: Icons.psychology_outlined,
            ),
          ),
          const SizedBox(width: 16),
          Container(
            height: 52,
            width: 52,
            decoration: const BoxDecoration(
              gradient: AppColors.purpleGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.send_rounded, color: Colors.white),
              onPressed: () {
                final txt = _msgController.text.trim();
                if (txt.isNotEmpty) {
                  onSend(txt);
                  _msgController.clear();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(BuildContext context, String text, bool isMe) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 12, left: isMe ? 48 : 0, right: isMe ? 0 : 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.primaryPurple
              : Theme.of(context).colorScheme.primary.withOpacity(0.08),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomRight: Radius.circular(isMe ? 0 : 16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
          ),
          border: isMe
              ? null
              : Border.all(color: AppColors.primaryPurple.withOpacity(0.1)),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isMe ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 13,
            height: 1.4,
          ),
        ),
      ),
    ).animateScaleEntrance(delayMs: 50);
  }
}

class _PlanSectionData {
  final String title;
  final String content;
  final IconData icon;

  _PlanSectionData(this.title, this.content, this.icon);
}
