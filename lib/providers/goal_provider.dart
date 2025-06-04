import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/nutrition_calculator.dart';

class GoalProvider extends ChangeNotifier {
  double _calories = 0;
  double _protein = 0;
  double _fat = 0;
  double _carbs = 0;

  double get calories => _calories;
  double get protein  => _protein;
  double get fat      => _fat;
  double get carbs    => _carbs;

  GoalProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _calories = prefs.getDouble('goal_calories') ?? 0;
    _protein  = prefs.getDouble('goal_protein')  ?? 0;
    _fat      = prefs.getDouble('goal_fat')      ?? 0;
    _carbs    = prefs.getDouble('goal_carbs')    ?? 0;
    notifyListeners();
  }

  Future<void> setGoals(MacroTargets targets) async {
    _calories = targets.calories;
    _protein  = targets.proteinGrams;
    _fat      = targets.fatGrams;
    _carbs    = targets.carbGrams;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('goal_calories', _calories);
    await prefs.setDouble('goal_protein',  _protein);
    await prefs.setDouble('goal_fat',      _fat);
    await prefs.setDouble('goal_carbs',    _carbs);
    notifyListeners();
  }
}
