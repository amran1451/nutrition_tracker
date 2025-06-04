import 'food_item.dart';

class MealPlan {
  final int? id;
  final String name;
  final List<PlanItem> items;

  MealPlan({this.id, required this.name, required this.items});

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
      };

  factory MealPlan.fromMap(Map<String, dynamic> m, List<PlanItem> items) =>
      MealPlan(id: m['id'] as int?, name: m['name'] as String, items: items);
}

class PlanItem {
  final int? id;
  final int planId;
  final String name;
  final double grams;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  PlanItem({
    this.id,
    required this.planId,
    required this.name,
    required this.grams,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'planId': planId,
        'name': name,
        'grams': grams,
        'calories': calories,
        'protein': protein,
        'fat': fat,
        'carbs': carbs,
      };

  factory PlanItem.fromMap(Map<String, dynamic> m) => PlanItem(
        id: m['id'] as int?,
        planId: m['planId'] as int,
        name: m['name'] as String,
        grams: (m['grams'] as num).toDouble(),
        calories: (m['calories'] as num).toDouble(),
        protein: (m['protein'] as num).toDouble(),
        fat: (m['fat'] as num).toDouble(),
        carbs: (m['carbs'] as num).toDouble(),
      );

  PlanItem copyWith({
    int? id,
    int? planId,
    String? name,
    double? grams,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) {
    return PlanItem(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      name: name ?? this.name,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
    );
  }
}
