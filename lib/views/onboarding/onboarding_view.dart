import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/glass_container.dart';
import '../../core/widgets/design_system.dart';
import '../../providers/app_state.dart';
import '../../providers/profile_provider.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();

  // Controllers for Step 1: Basic Information
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _heightFeetController = TextEditingController();
  final TextEditingController _heightInchesController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _goalWeightController = TextEditingController();
  String _gender = 'Male';
  String _heightUnit = 'cm'; // cm, m, ft/in

  // Step 2: Fitness Level (Unchanged)
  String _activityLevel = 'Moderately Active';
  String _experience = 'Beginner';
  bool _gymAccess = false;
  final TextEditingController _equipmentController = TextEditingController();

  // Step 3: Lifestyle (Simplified)
  String _jobType = 'Mixed';
  double _sleepHours = 8.0;
  double _waterIntake = 2.0;

  // Step 4: Goal Setting (Simplified)
  String _primaryGoal = 'Weight Loss';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();
      _goalWeightController.text = profile.goalWeight.toString();
      _gender = profile.gender;

      _activityLevel = profile.activityLevel;
      _experience = profile.workoutExperience;
      _gymAccess = profile.gymAccess;
      _equipmentController.text = profile.homeEquipment;

      _jobType = profile.jobType;
      _sleepHours = profile.sleepHours;
      _waterIntake = profile.waterIntake;
      _primaryGoal = profile.primaryGoal;

      setState(() {
        _currentStep = context.read<ProfileProvider>().currentStep;
      });
      if (_currentStep > 0 && _currentStep < 4) {
        _pageController.jumpToPage(_currentStep);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _heightFeetController.dispose();
    _heightInchesController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    _equipmentController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
      double heightCm = 170.0;
      if (_heightUnit == 'cm') {
        heightCm = double.tryParse(_heightController.text) ?? 170.0;
      } else if (_heightUnit == 'm') {
        heightCm = (double.tryParse(_heightController.text) ?? 1.7) * 100;
      } else {
        final ft = double.tryParse(_heightFeetController.text) ?? 5.0;
        final inch = double.tryParse(_heightInchesController.text) ?? 7.0;
        heightCm = (ft * 12 + inch) * 2.54;
      }
      context.read<ProfileProvider>().updateBasicInfo(
            name: _nameController.text,
            age: int.tryParse(_ageController.text) ?? 25,
            gender: _gender,
            height: heightCm,
            weight: double.tryParse(_weightController.text) ?? 70.0,
            goalWeight: double.tryParse(_goalWeightController.text) ?? 70.0,
          );
    } else if (_currentStep == 1) {
      context.read<ProfileProvider>().updateFitnessLevel(
            activityLevel: _activityLevel,
            workoutExperience: _experience,
            gymAccess: _gymAccess,
            homeEquipment: _equipmentController.text,
          );
    } else if (_currentStep == 2) {
      context.read<ProfileProvider>().updateLifestyle(
            jobType: _jobType,
            sleep: _sleepHours,
            water: _waterIntake,
          );
    }

    if (_currentStep < 3) {
      setState(() {
        _currentStep++;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      context.read<ProfileProvider>().saveCurrentStep(_currentStep);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
      context.read<ProfileProvider>().saveCurrentStep(_currentStep);
    }
  }

  void _onSubmit() async {
    final profileProvider = context.read<ProfileProvider>();
    final appStateProvider = context.read<AppStateProvider>();
    profileProvider.updateGoals(
          goal: _primaryGoal,
        );
    final success = await profileProvider.submitProfile();
    if (success && mounted) {
      await appStateProvider.saveProfile(
            name: _nameController.text,
            goal: _primaryGoal,
            activity: _activityLevel,
          );
      if (mounted) {
        context.go('/');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = context.watch<ProfileProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Assessment Wizard'),
        centerTitle: true,
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
                // Top Progress indicator bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Column(
                    children: [
                      LinearProgressIndicator(
                        value: (_currentStep + 1) / 4,
                        backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentStep + 1} of 4',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            _getStepTitle(_currentStep),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.primaryPurple),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildStep1(),
                      _buildStep2(),
                      _buildStep3(),
                      _buildStep4(),
                    ],
                  ),
                ),

                // Lower control buttons
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        OutlinedButton(
                          onPressed: _previousStep,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryPurple),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Back', style: TextStyle(color: AppColors.primaryPurple)),
                        )
                      else
                        const SizedBox.shrink(),

                      if (_currentStep < 3)
                        SizedBox(
                          width: 140,
                          child: NeonGradientButton(
                            text: 'Next',
                            onPressed: _nextStep,
                            icon: Icons.arrow_forward_rounded,
                          ),
                        )
                      else
                        SizedBox(
                          width: 180,
                          child: state.isSaving
                              ? const CircularProgressIndicator()
                              : NeonGradientButton(
                                  text: 'Submit & Setup',
                                  onPressed: _onSubmit,
                                  icon: Icons.check_circle_outline_rounded,
                                ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Basic Information';
      case 1:
        return 'Fitness Level';
      case 2:
        return 'Lifestyle Info';
      case 3:
      default:
        return 'Goals Setting';
    }
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Basic Info', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'FULL NAME',
              hint: 'Alex Mercer',
              controller: _nameController,
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'AGE',
              hint: '25',
              controller: _ageController,
              prefixIcon: Icons.calendar_today_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            // Gender Dropdown
            Text('GENDER', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _gender,
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.primaryPurple.withOpacity(0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: ['Male', 'Female', 'Other'].map((String val) {
                return DropdownMenuItem<String>(value: val, child: Text(val));
              }).toList(),
              onChanged: (val) => setState(() => _gender = val ?? 'Male'),
            ),
            const SizedBox(height: 16),
            // Height Unit Selector
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('HEIGHT UNIT', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'cm', label: Text('cm')),
                    ButtonSegment(value: 'm', label: Text('m')),
                    ButtonSegment(value: 'ft/in', label: Text('ft/in')),
                  ],
                  selected: {_heightUnit},
                  onSelectionChanged: (val) => setState(() => _heightUnit = val.first),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_heightUnit != 'ft/in')
              LuxuryTextField(
                label: 'HEIGHT (${_heightUnit.toUpperCase()})',
                hint: _heightUnit == 'cm' ? '175' : '1.75',
                controller: _heightController,
                prefixIcon: Icons.height,
                keyboardType: TextInputType.number,
              )
            else
              Row(
                children: [
                  Expanded(
                    child: LuxuryTextField(
                      label: 'FEET',
                      hint: '5',
                      controller: _heightFeetController,
                      prefixIcon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: LuxuryTextField(
                      label: 'INCHES',
                      hint: '7',
                      controller: _heightInchesController,
                      prefixIcon: Icons.height,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'CURRENT WEIGHT (KG)',
              hint: '70',
              controller: _weightController,
              prefixIcon: Icons.scale_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'TARGET GOAL WEIGHT (KG)',
              hint: '65',
              controller: _goalWeightController,
              prefixIcon: Icons.track_changes_outlined,
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Fitness Level', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('ACTIVITY LEVEL', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _activityLevel,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: [
              'Sedentary (Little to no exercise)',
              'Lightly Active (1-3 days/week)',
              'Moderately Active',
              'Very Active (6-7 days/week)',
            ].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _activityLevel = val ?? 'Moderately Active'),
          ),
          const SizedBox(height: 16),
          Text('WORKOUT EXPERIENCE', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _experience,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Beginner', 'Intermediate', 'Advanced'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _experience = val ?? 'Beginner'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Do you have access to a Gym?', style: TextStyle(fontWeight: FontWeight.bold)),
              Switch(
                value: _gymAccess,
                activeColor: AppColors.primaryPurple,
                onChanged: (val) => setState(() => _gymAccess = val),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'AVAILABLE HOME EQUIPMENT',
            hint: 'Dumbbells, resistance bands, None',
            controller: _equipmentController,
            prefixIcon: Icons.fitness_center_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lifestyle Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('JOB TYPE', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _jobType,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Desk Job (Sitting)', 'Active', 'Mixed'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _jobType = val ?? 'Mixed'),
          ),
          const SizedBox(height: 16),
          Text('SLEEP HOURS: ${_sleepHours.toInt()} hours', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Slider(
            value: _sleepHours,
            min: 4,
            max: 12,
            divisions: 8,
            activeColor: AppColors.primaryPurple,
            onChanged: (val) => setState(() => _sleepHours = val),
          ),
          const SizedBox(height: 16),
          Text('DAILY WATER INTAKE: ${_waterIntake.toStringAsFixed(1)} Liters', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          Slider(
            value: _waterIntake,
            min: 1,
            max: 5,
            divisions: 8,
            activeColor: AppColors.primaryPurple,
            onChanged: (val) => setState(() => _waterIntake = val),
          ),
        ],
      ),
    );
  }

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Goal Setting', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('PRIMARY GOAL', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _primaryGoal,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Weight Loss', 'Weight Gain', 'Muscle Gain', 'Fat Loss', 'Maintenance'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _primaryGoal = val ?? 'Weight Loss'),
          ),
          const SizedBox(height: 40),
          Center(
            child: GlassContainer(
              opacity: 0.05,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(Icons.format_quote_rounded, color: AppColors.primaryPurple, size: 36),
                  const SizedBox(height: 12),
                  Text(
                    '\"Small daily improvements create remarkable long-term results.\"',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontStyle: FontStyle.italic,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryPurple,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
