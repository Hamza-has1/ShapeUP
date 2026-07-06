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

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();

  // Controllers for Step 1
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  String _gender = 'Male';

  // Controllers for Step 2
  final TextEditingController _goalWeightController = TextEditingController();
  final TextEditingController _conditionsController = TextEditingController();
  final TextEditingController _injuriesController = TextEditingController();
  final TextEditingController _medsController = TextEditingController();
  String _bodyType = 'Average';

  // Step 3
  String _activityLevel = 'Moderately Active';
  String _experience = 'Beginner';
  bool _gymAccess = false;
  final TextEditingController _equipmentController = TextEditingController();

  // Step 4
  final TextEditingController _routineController = TextEditingController();
  String _jobType = 'Mixed';
  double _sleepHours = 8.0;
  String _stressLevel = 'Medium';
  double _waterIntake = 2.0;

  // Step 5
  String _foodPref = 'Non-vegetarian';
  final TextEditingController _allergiesController = TextEditingController();
  final TextEditingController _restrictionsController = TextEditingController();
  String _budgetRange = 'Medium';
  final TextEditingController _foodHintController = TextEditingController();

  // Step 6
  String _primaryGoal = 'Weight Loss';
  final TextEditingController _secondaryGoalsController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();
  final TextEditingController _motivationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate fields from draft state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = context.read<ProfileProvider>().profile;
      _nameController.text = profile.name;
      _ageController.text = profile.age.toString();
      _countryController.text = profile.country;
      _heightController.text = profile.height.toString();
      _weightController.text = profile.weight.toString();

      _goalWeightController.text = profile.goalWeight.toString();
      _conditionsController.text = profile.medicalConditions;
      _injuriesController.text = profile.injuries;
      _medsController.text = profile.medications;
      _bodyType = profile.bodyType;

      _activityLevel = profile.activityLevel;
      _experience = profile.workoutExperience;
      _gymAccess = profile.gymAccess;
      _equipmentController.text = profile.homeEquipment;

      _routineController.text = profile.routineDescription;
      _jobType = profile.jobType;
      _sleepHours = profile.sleepHours;
      _stressLevel = profile.stressLevel;
      _waterIntake = profile.waterIntake;

      _foodPref = profile.foodPreference;
      _allergiesController.text = profile.allergies;
      _restrictionsController.text = profile.dietRestrictions;
      _budgetRange = profile.budgetRange;
      _foodHintController.text = profile.countryFoodHint;

      _primaryGoal = profile.primaryGoal;
      _secondaryGoalsController.text = profile.secondaryGoals;
      _timelineController.text = profile.targetTimelineWeeks.toString();
      _motivationController.text = profile.motivation;

      setState(() {
        _currentStep = context.read<ProfileProvider>().currentStep;
      });
      if (_currentStep > 0) {
        _pageController.jumpToPage(_currentStep);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _goalWeightController.dispose();
    _conditionsController.dispose();
    _injuriesController.dispose();
    _medsController.dispose();
    _equipmentController.dispose();
    _routineController.dispose();
    _allergiesController.dispose();
    _restrictionsController.dispose();
    _foodHintController.dispose();
    _secondaryGoalsController.dispose();
    _timelineController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_formKey1.currentState!.validate()) return;
      context.read<ProfileProvider>().updateBasicInfo(
            name: _nameController.text,
            age: int.tryParse(_ageController.text) ?? 25,
            gender: _gender,
            country: _countryController.text,
            height: double.tryParse(_heightController.text) ?? 170.0,
            weight: double.tryParse(_weightController.text) ?? 70.0,
          );
    } else if (_currentStep == 1) {
      context.read<ProfileProvider>().updateBodyMetrics(
            goalWeight: double.tryParse(_goalWeightController.text) ?? double.tryParse(_weightController.text) ?? 70.0,
            bodyType: _bodyType,
            conditions: _conditionsController.text,
            injuries: _injuriesController.text,
            medications: _medsController.text,
          );
    } else if (_currentStep == 2) {
      context.read<ProfileProvider>().updateFitnessLevel(
            activityLevel: _activityLevel,
            workoutExperience: _experience,
            gymAccess: _gymAccess,
            homeEquipment: _equipmentController.text,
          );
    } else if (_currentStep == 3) {
      context.read<ProfileProvider>().updateLifestyle(
            routine: _routineController.text,
            jobType: _jobType,
            sleep: _sleepHours,
            stress: _stressLevel,
            water: _waterIntake,
          );
    } else if (_currentStep == 4) {
      context.read<ProfileProvider>().updateNutrition(
            preference: _foodPref,
            allergies: _allergiesController.text,
            restrictions: _restrictionsController.text,
            budget: _budgetRange,
            foodHint: _foodHintController.text,
          );
    } else if (_currentStep == 5) {
      context.read<ProfileProvider>().updateGoals(
            goal: _primaryGoal,
            secondary: _secondaryGoalsController.text,
            timeline: int.tryParse(_timelineController.text) ?? 12,
            motivation: _motivationController.text,
          );
    }

    if (_currentStep < 6) {
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
    final success = await context.read<ProfileProvider>().submitProfile();
    if (success && mounted) {
      // Complete appState onboarding status flag to navigate out
      await context.read<AppStateProvider>().saveProfile(
            name: _nameController.text,
            goal: _primaryGoal,
            activity: _activityLevel,
          );
      context.go('/');
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
                        value: (_currentStep + 1) / 7,
                        backgroundColor: AppColors.primaryPurple.withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryPurple),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Step ${_currentStep + 1} of 7',
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
                      _buildStep5(),
                      _buildStep6(),
                      _buildStep7(state),
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
                      
                      if (_currentStep < 6)
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
        return 'Health Metrics';
      case 2:
        return 'Fitness Level';
      case 3:
        return 'Lifestyle Info';
      case 4:
        return 'Nutrition Preference';
      case 5:
        return 'Goals Setting';
      case 6:
      default:
        return 'Summary & Calculations';
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
            LuxuryTextField(
              label: 'HEIGHT (CM)',
              hint: '175',
              controller: _heightController,
              prefixIcon: Icons.height,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'WEIGHT (KG)',
              hint: '70',
              controller: _weightController,
              prefixIcon: Icons.scale_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            LuxuryTextField(
              label: 'COUNTRY',
              hint: 'United States',
              controller: _countryController,
              prefixIcon: Icons.map_outlined,
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
          Text('Health Metrics', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'TARGET GOAL WEIGHT (KG)',
            hint: '65',
            controller: _goalWeightController,
            prefixIcon: Icons.track_changes_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          Text('BODY TYPE', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _bodyType,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Lean', 'Average', 'Heavy'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _bodyType = val ?? 'Average'),
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'MEDICAL CONDITIONS',
            hint: 'PCOS, Diabetes, None',
            controller: _conditionsController,
            prefixIcon: Icons.medical_services_outlined,
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'INJURIES',
            hint: 'Knee injury, None',
            controller: _injuriesController,
            prefixIcon: Icons.healing_outlined,
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'MEDICATIONS (OPTIONAL)',
            hint: 'Metformin, None',
            controller: _medsController,
            prefixIcon: Icons.medication_outlined,
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

  Widget _buildStep4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Lifestyle Information', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'DAILY ROUTINE DESCRIPTION',
            hint: 'Describe your routine briefly',
            controller: _routineController,
            prefixIcon: Icons.notes_rounded,
          ),
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
          Text('STRESS LEVEL', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _stressLevel,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Low', 'Medium', 'High'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _stressLevel = val ?? 'Medium'),
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

  Widget _buildStep5() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nutrition Preferences', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Text('FOOD PREFERENCE', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _foodPref,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Vegetarian', 'Non-vegetarian', 'Vegan'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _foodPref = val ?? 'Non-vegetarian'),
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'ALLERGIES',
            hint: 'Peanuts, Gluten, None',
            controller: _allergiesController,
            prefixIcon: Icons.warning_amber_rounded,
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'DIETARY RESTRICTIONS',
            hint: 'Keto, Halal, None',
            controller: _restrictionsController,
            prefixIcon: Icons.restaurant_menu_rounded,
          ),
          const SizedBox(height: 16),
          Text('BUDGET RANGE FOR FOOD', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _budgetRange,
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.primaryPurple.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
            items: ['Low', 'Medium', 'High'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) => setState(() => _budgetRange = val ?? 'Medium'),
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'LOCAL DISH PREFERENCES OR HINTS',
            hint: 'Prefers Mediterranean dishes',
            controller: _foodHintController,
            prefixIcon: Icons.location_on_outlined,
          ),
        ],
      ),
    );
  }

  Widget _buildStep6() {
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
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'SECONDARY GOALS (OPTIONAL)',
            hint: 'Improve stamina, better sleep',
            controller: _secondaryGoalsController,
            prefixIcon: Icons.playlist_add_check_rounded,
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'TARGET TIMELINE (WEEKS)',
            hint: '12',
            controller: _timelineController,
            prefixIcon: Icons.timer_outlined,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          LuxuryTextField(
            label: 'WHAT MOTIVATES YOU?',
            hint: 'Wanting to stay fit for my family',
            controller: _motivationController,
            prefixIcon: Icons.favorite_border_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildStep7(ProfileProvider state) {
    final bmi = state.profile.bmi;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review & Calculations', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          const Text('Below are the diagnostic calibrations calculated from your assessment inputs.', style: TextStyle(fontSize: 13)),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildCalculatedMetricCard(
                  title: 'CALCULATED BMI',
                  value: bmi.toStringAsFixed(1),
                  subtitle: _getBmiCategory(bmi),
                  color: _getBmiColor(bmi),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCalculatedMetricCard(
                  title: 'DAILY CALORIES',
                  value: '${state.profile.dailyCalorieEstimate.round()} kcal',
                  subtitle: 'Target limit estimate',
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCalculatedMetricCard(
                  title: 'DAILY PROTEIN',
                  value: '${state.profile.recommendedProteinIntake.round()} g',
                  subtitle: 'Estimated active intake',
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCalculatedMetricCard(
                  title: 'BODY FAT EST.',
                  value: '${state.profile.estimatedBodyFatRangeMin.round()}%-${state.profile.estimatedBodyFatRangeMax.round()}%',
                  subtitle: 'Baseline distribution',
                  color: AppColors.info,
                ),
              ),
            ],
          ),

          if (state.profile.healthRiskFlags.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'HEALTH WARNING FLAGS',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
            ),
            const SizedBox(height: 8),
            Column(
              children: state.profile.healthRiskFlags.map((flag) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          flag,
                          style: const TextStyle(fontSize: 12, color: Colors.redAccent, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCalculatedMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return GlassContainer(
      opacity: 0.05,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _getBmiColor(double bmi) {
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return AppColors.success;
    if (bmi < 30) return AppColors.warning;
    return AppColors.error;
  }
}
