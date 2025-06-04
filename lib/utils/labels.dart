// lib/src/utils/labels.dart

import '../models/food_item.dart';  // где MealType лежит
import '../providers/goal_provider.dart'; // где GoalType лежит (или )
import '../models/goal_type.dart';

/// Преобразует MealType в русскоязычную строку
String mealTypeLabel(MealType mt) {
  switch (mt) {
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

/// Преобразует GoalType в строку
String goalTypeLabel(GoalType gt) {
  switch (gt) {
    case GoalType.maintain:
      return 'Поддержание';
    case GoalType.gain:
      return 'Набор массы';
    case GoalType.lose:
      return 'Похудение';
  }
}
