import '../models/goal_type.dart';


double calculateBMR({
  required double weightKg,
  required double heightCm,
  required int ageYears,
  required bool isMale,
}) {
  final s = isMale ? 5 : -161;
  return 10 * weightKg + 6.25 * heightCm - 5 * ageYears + s;
}

double calculateTDEE({
  required double bmr,
  required double activityFactor,
}) {
  return bmr * activityFactor;
}

double adjustCalories({
  required double tdee,
  required GoalType goalType,
}) {
  switch (goalType) {
    case GoalType.gain:
      return tdee * 1.10;  // +10%
    case GoalType.lose:
      return tdee * 0.90;  // –10%
    case GoalType.maintain:
    default:
      return tdee;
  }
}

class MacroTargets {
  final double calories;
  final double proteinGrams;
  final double fatGrams;
  final double carbGrams;

  MacroTargets({
    required this.calories,
    required this.proteinGrams,
    required this.fatGrams,
    required this.carbGrams,
  });
}

/// Рассчитывает граммы макросов на основе ISSN-рекомендаций
MacroTargets calculateMacros({
  required double calories,
  required double weightKg,
  required GoalType goalType,
}) {
  double proteinG;
  double fatPct;
  switch (goalType) {
    case GoalType.gain:
      proteinG = weightKg * 2.0;
      fatPct = 0.25;
      break;
    case GoalType.lose:
      proteinG = weightKg * 2.2;
      fatPct = 0.225;
      break;
    case GoalType.maintain:
    default:
      proteinG = weightKg * 1.6;
      fatPct = 0.275;
      break;
  }
  final fatCals = calories * fatPct;
  final fatG = fatCals / 9;
  final remainingCals = calories - (proteinG * 4) - fatCals;
  final carbG = remainingCals / 4;
  return MacroTargets(
    calories: calories,
    proteinGrams: proteinG,
    fatGrams: fatG,
    carbGrams: carbG,
  );
}
