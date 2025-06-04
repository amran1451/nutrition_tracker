// lib/src/models/meal_type_ext.dart

import 'meal_type.dart';   // здесь у вас определён enum MealType
import 'goal_type.dart';   // здесь определён enum GoalType (если нужно)

/// Расширение для MealType: даёт человекочитаемый текст
extension MealTypeDisplay on MealType {
  String get displayName {
    switch (this) {
      case MealType.breakfast:
        return 'Завтрак';
      case MealType.lunch:
        return 'Обед';
      case MealType.dinner:
        return 'Ужин';
      case MealType.snack1:
        return 'Перекус 1';
      case MealType.snack2:
        return 'Перекус 2';
    }
  }
}

/// Расширение для GoalType: даёт человекочитаемый текст
extension GoalTypeDisplay on GoalType {
  String get displayName {
    switch (this) {
      case GoalType.maintain:
        return 'Поддержание';
      case GoalType.gain:
        return 'Набор массы';
      case GoalType.lose:
        return 'Похудение';
    }
  }
}
