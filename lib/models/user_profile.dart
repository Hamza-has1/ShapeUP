class UserProfile {
  // Step 1
  String name;
  int age;
  String gender;
  String country;
  double height; // cm
  double weight; // kg

  // Step 2
  double goalWeight;
  String bodyType;
  double bmi;
  String medicalConditions;
  String injuries;
  String medications;

  // Female-specific Physiological Parameters
  String menstrualCycleStage; // Menstrual, Follicular, Ovulation, Luteal
  bool hasPcos;
  bool isPregnant;
  bool isPostpartum;
  bool hasIronDeficiency;

  // Step 3
  String activityLevel;
  String workoutExperience;
  bool gymAccess;
  String homeEquipment;

  // Step 4
  String routineDescription;
  String jobType;
  double sleepHours;
  String stressLevel;
  double waterIntake;

  // Step 5
  String foodPreference;
  String allergies;
  String dietRestrictions;
  String budgetRange;
  String countryFoodHint;

  // Step 6
  String primaryGoal;
  String secondaryGoals;
  int targetTimelineWeeks;
  String motivation;

  // Generated Metrics
  double estimatedBodyFatRangeMin;
  double estimatedBodyFatRangeMax;
  double dailyCalorieEstimate;
  double recommendedProteinIntake;
  List<String> healthRiskFlags;

  UserProfile({
    this.name = '',
    this.age = 25,
    this.gender = 'Male',
    this.country = '',
    this.height = 170.0,
    this.weight = 70.0,
    this.goalWeight = 70.0,
    this.bodyType = 'Average',
    this.bmi = 24.2,
    this.medicalConditions = '',
    this.injuries = '',
    this.medications = '',
    this.menstrualCycleStage = 'Follicular',
    this.hasPcos = false,
    this.isPregnant = false,
    this.isPostpartum = false,
    this.hasIronDeficiency = false,
    this.activityLevel = 'Moderately Active',
    this.workoutExperience = 'Beginner',
    this.gymAccess = false,
    this.homeEquipment = '',
    this.routineDescription = '',
    this.jobType = 'Mixed',
    this.sleepHours = 8.0,
    this.stressLevel = 'Medium',
    this.waterIntake = 2.0,
    this.foodPreference = 'Non-vegetarian',
    this.allergies = '',
    this.dietRestrictions = '',
    this.budgetRange = 'Medium',
    this.countryFoodHint = '',
    this.primaryGoal = 'Weight Loss',
    this.secondaryGoals = '',
    this.targetTimelineWeeks = 12,
    this.motivation = '',
    this.estimatedBodyFatRangeMin = 15.0,
    this.estimatedBodyFatRangeMax = 22.0,
    this.dailyCalorieEstimate = 2000.0,
    this.recommendedProteinIntake = 120.0,
    this.healthRiskFlags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
      'country': country,
      'height': height,
      'weight': weight,
      'goalWeight': goalWeight,
      'bodyType': bodyType,
      'bmi': bmi,
      'medicalConditions': medicalConditions,
      'injuries': injuries,
      'medications': medications,
      'menstrualCycleStage': menstrualCycleStage,
      'hasPcos': hasPcos,
      'isPregnant': isPregnant,
      'isPostpartum': isPostpartum,
      'hasIronDeficiency': hasIronDeficiency,
      'activityLevel': activityLevel,
      'workoutExperience': workoutExperience,
      'gymAccess': gymAccess,
      'homeEquipment': homeEquipment,
      'routineDescription': routineDescription,
      'jobType': jobType,
      'sleepHours': sleepHours,
      'stressLevel': stressLevel,
      'waterIntake': waterIntake,
      'foodPreference': foodPreference,
      'allergies': allergies,
      'dietRestrictions': dietRestrictions,
      'budgetRange': budgetRange,
      'countryFoodHint': countryFoodHint,
      'primaryGoal': primaryGoal,
      'secondaryGoals': secondaryGoals,
      'targetTimelineWeeks': targetTimelineWeeks,
      'motivation': motivation,
      'estimatedBodyFatRangeMin': estimatedBodyFatRangeMin,
      'estimatedBodyFatRangeMax': estimatedBodyFatRangeMax,
      'dailyCalorieEstimate': dailyCalorieEstimate,
      'recommendedProteinIntake': recommendedProteinIntake,
      'healthRiskFlags': healthRiskFlags,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      name: json['name'] ?? '',
      age: json['age'] ?? 25,
      gender: json['gender'] ?? 'Male',
      country: json['country'] ?? '',
      height: (json['height'] ?? 170.0).toDouble(),
      weight: (json['weight'] ?? 70.0).toDouble(),
      goalWeight: (json['goalWeight'] ?? 70.0).toDouble(),
      bodyType: json['bodyType'] ?? 'Average',
      bmi: (json['bmi'] ?? 24.2).toDouble(),
      medicalConditions: json['medicalConditions'] ?? '',
      injuries: json['injuries'] ?? '',
      medications: json['medications'] ?? '',
      menstrualCycleStage: json['menstrualCycleStage'] ?? 'Follicular',
      hasPcos: json['hasPcos'] ?? false,
      isPregnant: json['isPregnant'] ?? false,
      isPostpartum: json['isPostpartum'] ?? false,
      hasIronDeficiency: json['hasIronDeficiency'] ?? false,
      activityLevel: json['activityLevel'] ?? 'Moderately Active',
      workoutExperience: json['workoutExperience'] ?? 'Beginner',
      gymAccess: json['gymAccess'] ?? false,
      homeEquipment: json['homeEquipment'] ?? '',
      routineDescription: json['routineDescription'] ?? '',
      jobType: json['jobType'] ?? 'Mixed',
      sleepHours: (json['sleepHours'] ?? 8.0).toDouble(),
      stressLevel: json['stressLevel'] ?? 'Medium',
      waterIntake: (json['waterIntake'] ?? 2.0).toDouble(),
      foodPreference: json['foodPreference'] ?? 'Non-vegetarian',
      allergies: json['allergies'] ?? '',
      dietRestrictions: json['dietRestrictions'] ?? '',
      budgetRange: json['budgetRange'] ?? 'Medium',
      countryFoodHint: json['countryFoodHint'] ?? '',
      primaryGoal: json['primaryGoal'] ?? 'Weight Loss',
      secondaryGoals: json['secondaryGoals'] ?? '',
      targetTimelineWeeks: json['targetTimelineWeeks'] ?? 12,
      motivation: json['motivation'] ?? '',
      estimatedBodyFatRangeMin: (json['estimatedBodyFatRangeMin'] ?? 15.0).toDouble(),
      estimatedBodyFatRangeMax: (json['estimatedBodyFatRangeMax'] ?? 22.0).toDouble(),
      dailyCalorieEstimate: (json['dailyCalorieEstimate'] ?? 2000.0).toDouble(),
      recommendedProteinIntake: (json['recommendedProteinIntake'] ?? 120.0).toDouble(),
      healthRiskFlags: List<String>.from(json['healthRiskFlags'] ?? []),
    );
  }
}
