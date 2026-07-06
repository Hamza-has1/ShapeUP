import 'package:flutter/material.dart';
import '../models/user_profile.dart';

class Meal {
  final String name;
  final String description;
  final String portion;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final List<String> ingredients;
  final List<String> instructions;
  final List<String> substitutions;

  Meal({
    required this.name,
    required this.description,
    required this.portion,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.ingredients,
    required this.instructions,
    required this.substitutions,
  });
}

class DailyMealPlan {
  final String dayName;
  final Meal breakfast;
  final Meal midMorningSnack;
  final Meal lunch;
  final Meal eveningSnack;
  final Meal dinner;

  DailyMealPlan({
    required this.dayName,
    required this.breakfast,
    required this.midMorningSnack,
    required this.lunch,
    required this.eveningSnack,
    required this.dinner,
  });
}

class NutritionProvider extends ChangeNotifier {
  List<DailyMealPlan> _weeklyPlan = [];
  int _selectedDayIndex = 0;
  bool _cheatMealLogged = false;
  double _calorieOffset = 0.0;
  String _cheatMealRecoveryTip = '';

  List<DailyMealPlan> get weeklyPlan => _weeklyPlan;
  int get selectedDayIndex => _selectedDayIndex;
  DailyMealPlan? get activeDayPlan => _weeklyPlan.isNotEmpty ? _weeklyPlan[_selectedDayIndex] : null;
  bool get cheatMealLogged => _cheatMealLogged;
  double get calorieOffset => _calorieOffset;
  String get cheatMealRecoveryTip => _cheatMealRecoveryTip;

  void selectDay(int index) {
    if (index >= 0 && index < _weeklyPlan.length) {
      _selectedDayIndex = index;
      notifyListeners();
    }
  }

  void logCheatMeal(String type) {
    _cheatMealLogged = true;
    _calorieOffset = -250.0; // Offset calorie targets for the following day
    _cheatMealRecoveryTip = 'Recovery tip: Increase water intake by 1L, perform 20 mins brisk walking, and stick to clean proteins tomorrow.';
    notifyListeners();
  }

  void clearCheatMeal() {
    _cheatMealLogged = false;
    _calorieOffset = 0.0;
    _cheatMealRecoveryTip = '';
    notifyListeners();
  }

  void generateWeeklyMealPlan(UserProfile profile, String activeCoach) {
    final double baseCalories = profile.dailyCalorieEstimate + _calorieOffset;
    final double protein = profile.recommendedProteinIntake;

    // Macro distributions
    double fatVal = (baseCalories * 0.25) / 9.0;
    double carbVal = (baseCalories - (protein * 4) - (fatVal * 9)) / 4.0;

    final String pref = profile.foodPreference; // Vegetarian, Non-vegetarian, Vegan
    final bool isPakistani = true;

    // Create 7 rotation plans
    final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    _weeklyPlan = days.map((day) {
      return DailyMealPlan(
        dayName: day,
        breakfast: _generateMeal(
          mealName: 'Breakfast',
          pref: pref,
          isPakistani: isPakistani,
          calories: baseCalories * 0.25,
          protein: protein * 0.25,
          carbs: carbVal * 0.25,
          fat: fatVal * 0.25,
          activeCoach: activeCoach,
        ),
        midMorningSnack: _generateMeal(
          mealName: 'Mid-Morning Snack',
          pref: pref,
          isPakistani: isPakistani,
          calories: baseCalories * 0.10,
          protein: protein * 0.10,
          carbs: carbVal * 0.10,
          fat: fatVal * 0.10,
          activeCoach: activeCoach,
        ),
        lunch: _generateMeal(
          mealName: 'Lunch',
          pref: pref,
          isPakistani: isPakistani,
          calories: baseCalories * 0.30,
          protein: protein * 0.30,
          carbs: carbVal * 0.30,
          fat: fatVal * 0.30,
          activeCoach: activeCoach,
        ),
        eveningSnack: _generateMeal(
          mealName: 'Evening Snack',
          pref: pref,
          isPakistani: isPakistani,
          calories: baseCalories * 0.10,
          protein: protein * 0.10,
          carbs: carbVal * 0.10,
          fat: fatVal * 0.10,
          activeCoach: activeCoach,
        ),
        dinner: _generateMeal(
          mealName: 'Dinner',
          pref: pref,
          isPakistani: isPakistani,
          calories: baseCalories * 0.25,
          protein: protein * 0.25,
          carbs: carbVal * 0.25,
          fat: fatVal * 0.25,
          activeCoach: activeCoach,
        ),
      );
    }).toList();

    notifyListeners();
  }

  Meal _generateMeal({
    required String mealName,
    required String pref,
    required bool isPakistani,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required String activeCoach,
  }) {
    String name = '';
    String description = '';
    String portion = '';
    List<String> ingredients = [];
    List<String> instructions = [];
    List<String> substitutions = [];

    // Simple procedural generation rules based on preferences
    if (mealName == 'Breakfast') {
      if (pref == 'Vegetarian') {
        name = isPakistani ? 'Oatmeal with Almonds & Honey' : 'Greek Yogurt Berry Bowl';
        description = 'A fiber-rich morning meal with calcium toppings.';
        portion = '1 Bowl';
        ingredients = ['40g rolled oats', '150ml almond milk', '15g almonds', '1 tsp organic honey'];
        instructions = ['Boil oats in almond milk.', 'Stir and top with chopped almonds and honey.'];
        substitutions = ['Chia seed pudding', 'Tofu scramble toast'];
      } else if (pref == 'Vegan') {
        name = 'Protein Tofu Scramble Toast';
        description = 'Scrambled tofu with herbs served on whole wheat crusts.';
        portion = '2 Slices';
        ingredients = ['150g firm tofu', '2 slices whole wheat bread', '1/2 tsp turmeric', 'Spinach'];
        instructions = ['Mash tofu in skillet with turmeric.', 'Sauté with spinach and serve on toast.'];
        substitutions = ['Soy milk oatmeal', 'Peanut butter banana wrap'];
      } else {
        // Non-veg
        name = isPakistani ? 'Egg White Omelet with Whole Wheat Roti' : 'Avocado Egg Toast';
        description = 'High protein morning booster to fuel recovery.';
        portion = '1 Plate';
        ingredients = ['3 egg whites', '1 whole egg', '1 medium whole wheat roti', 'Onions & tomatoes'];
        instructions = ['Whisk eggs and pan-cook with low spray oil.', 'Serve warm with hot roti.'];
        substitutions = ['Protein pancake', 'Whey protein fruit smoothie'];
      }
    } else if (mealName == 'Lunch') {
      if (pref == 'Vegetarian') {
        name = isPakistani ? 'Daal Chawal with Cucumber Salad' : 'Brown Rice & Bean Bowl';
        description = 'A classic complete-protein profile grain bowl.';
        portion = '1 Plate';
        ingredients = ['100g cooked lentils (Daal)', '150g boiled brown rice', 'Salad greens'];
        instructions = ['Serve cooked yellow lentils over brown rice.', 'Pair with lemon-infused cucumber salad.'];
        substitutions = ['Paneer tikka wrap', 'Chickpea quinoa bowl'];
      } else if (pref == 'Vegan') {
        name = 'Spiced Chickpea Quinoa Salad';
        description = 'High fiber quinoa mixed with roasted chickpeas.';
        portion = '1 Bowl';
        ingredients = ['120g canned chickpeas', '100g cooked quinoa', 'Lemon juice', 'Olive oil'];
        instructions = ['Mix cooked quinoa and roasted chickpeas.', 'Toss with lemon olive oil dressing.'];
        substitutions = ['Lentil soup with crusty bread', 'Tofu broccoli stir fry'];
      } else {
        name = isPakistani ? 'Grilled Chicken Karahi with Roti' : 'Grilled Chicken & Brown Rice';
        description = 'Clean, lean chicken breast preparation with complex carbs.';
        portion = '1 Plate';
        ingredients = ['180g skinless chicken breast', '1 whole wheat roti', 'Spices & tomato paste'];
        instructions = ['Cook chicken with spices, ginger, and minimal oil.', 'Serve alongside warm roti.'];
        substitutions = ['Baked fish with sweet potato', 'Beef steak with quinoa'];
      }
    } else if (mealName == 'Dinner') {
      if (pref == 'Vegetarian') {
        name = isPakistani ? 'Palak Paneer with Bran Roti' : 'Stir-fried Tofu & Mixed Veggies';
        description = 'Micronutrient-rich dinner to support hormonal balance.';
        portion = '1 Plate';
        ingredients = ['100g cottage cheese (Paneer)', '150g blended spinach (Palak)', '1 bran roti'];
        instructions = ['Sauté paneer cubes.', 'Simmer in spiced spinach gravy and serve with bran roti.'];
        substitutions = ['Mushroom salad toast', 'Baked sweet potato with cottage cheese'];
      } else if (pref == 'Vegan') {
        name = 'Baked Tempeh with Sweet Potato';
        description = 'High-protein tempeh served with beta-carotene sweet potato cubes.';
        portion = '1 Plate';
        ingredients = ['150g organic tempeh', '150g sweet potato', 'Green beans'];
        instructions = ['Bake tempeh and sweet potato cubes at 200°C for 25 mins.', 'Serve hot with steamed green beans.'];
        substitutions = ['Vegetable lentil curry', 'Quinoa stuffed bell peppers'];
      } else {
        name = isPakistani ? 'Baked Fish Tikka with Mint Raita' : 'Baked Salmon & Broccoli';
        description = 'Lean fish loaded with omega-3 fatty acids for muscle repair.';
        portion = '150g Fish';
        ingredients = ['180g local fish fillet (e.g. Rahu/Sole)', 'Tikka spice mix', 'Low-fat yogurt raita'];
        instructions = ['Marinate fish in tikka spices.', 'Bake or air-fry until flaky, serve with raita.'];
        substitutions = ['Grilled chicken breast with asparagus', 'Lean minced beef with broccoli'];
      }
    } else {
      // Snacks
      name = 'Mixed Nuts & Fruit';
      description = 'Healthy fats and rapid fuel to carry you between meals.';
      portion = '1 Handful';
      ingredients = ['15g walnuts', '15g almonds', '1 green apple'];
      instructions = ['Serve raw.'];
      substitutions = ['Rice cake with peanut butter', 'Low-fat Greek yogurt bowl'];
    }

    // Dr. Pink adjustments: elevate iron for deficiency
    if (activeCoach == 'Dr. Pink' && pref != 'Vegan') {
      substitutions.add('Iron-rich boiled beef strips');
    }

    return Meal(
      name: name,
      description: description,
      portion: portion,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      ingredients: ingredients,
      instructions: instructions,
      substitutions: substitutions,
    );
  }

  List<Map<String, String>> generateGroceryList() {
    final List<Map<String, String>> items = [];
    if (_weeklyPlan.isEmpty) return items;

    // Collate first 3 days to simulate shopping list content without duplicating strings
    for (int i = 0; i < 3; i++) {
      final day = _weeklyPlan[i];
      for (final ing in day.breakfast.ingredients) {
        items.add({'item': ing, 'category': 'Breakfast & Fruits'});
      }
      for (final ing in day.lunch.ingredients) {
        items.add({'item': ing, 'category': 'Proteins & Grains'});
      }
      for (final ing in day.dinner.ingredients) {
        items.add({'item': ing, 'category': 'Veggies & Extras'});
      }
    }

    // De-duplicate items list
    final seen = <String>{};
    return items.where((element) => seen.add(element['item']!)).toList();
  }
}
