import '../database/db_helper.dart';
import '../models/food_item.dart';

class WeeklyReport {
  final DateTime start;
  final DateTime end;
  final List<FoodItem> items;
  final Map<String, double> totals;
  WeeklyReport(this.start, this.end, this.items, this.totals);
}

Future<WeeklyReport> generateWeeklyReport(DateTime anyDay) async {
  final monday = anyDay.subtract(Duration(days: anyDay.weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  final allItems = <FoodItem>[];
  for (int i = 0; i < 7; i++) {
    final day = monday.add(Duration(days: i));
    allItems.addAll(await DBHelper().fetchFoodsByDate(day));
  }
  double cal = 0, prot = 0, fat = 0, carb = 0;
  for (var f in allItems) {
    cal += f.calories;
    prot += f.protein;
    fat += f.fat;
    carb += f.carbs;
  }
  return WeeklyReport(
    monday,
    sunday,
    allItems,
    {'cal': cal, 'prot': prot, 'fat': fat, 'carb': carb},
  );
}
