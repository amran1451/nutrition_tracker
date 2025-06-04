// В самое начало (до объявления FoodItem):
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack1,
  snack2,
}

class FoodItem {
  final int? id;
  final String name;
  final double grams;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;
  final DateTime consumedAt;
  final MealType mealType;


   FoodItem({
     this.id,
     required this.name,
     required this.grams,
     required this.calories,
     required this.protein,
     required this.fat,
     required this.carbs,
     required this.consumedAt,
     required this.mealType,
   });

   Map<String, dynamic> toMap() {
     return {
       'id': id,
       'name': name,
       'grams': grams,
       'calories': calories,
       'protein': protein,
       'fat': fat,
       'carbs': carbs,
       'consumedAt': consumedAt.toIso8601String(),
       'mealType': mealType.index,
     };
   }

   factory FoodItem.fromMap(Map<String, dynamic> map) {
     return FoodItem(
       id: map['id'] as int?,
       name: map['name'] as String,
       grams: map['grams'] as double,
       calories: map['calories'] as double,
       protein: map['protein'] as double,
       fat: map['fat'] as double,
       carbs: map['carbs'] as double,
       consumedAt: DateTime.parse(map['consumedAt'] as String),
       mealType: MealType.values[map['mealType'] as int],
     );
   }
 }

 extension FoodItemCopy on FoodItem {
  FoodItem copyWith({
    int? id,
    String? name,
    double? grams,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
    DateTime? consumedAt,
    MealType? mealType,
  }) {
    return FoodItem(
      id: id ?? this.id,
      name: name ?? this.name,
      grams: grams ?? this.grams,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
      consumedAt: consumedAt ?? this.consumedAt,
      mealType: mealType ?? this.mealType,
    );
  }
}
