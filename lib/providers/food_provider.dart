import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/food_item.dart';

class FoodProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final List<FoodItem> _items = [];

  List<FoodItem> get foodItems => List.unmodifiable(_items);

  FoodProvider() {
    loadForDate(DateTime.now());
  }

  Future<void> loadForDate(DateTime date) async {
    final list = await _db.fetchFoodsByDate(date);
    _items
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> addFood(FoodItem item) async {
    final id = await _db.insertFood(item);
    // сохраним id для возможности update
    final newItem = item.copyWith(id: id);
    _items.insert(0, newItem);
    notifyListeners();
  }

  Future<void> deleteFood(int id) async {
    await _db.deleteFood(id);
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  Future<void> editFood(FoodItem item) async {
    if (item.id == null) return;
    await _db.updateFood(item);
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx != -1) {
      _items[idx] = item;
      notifyListeners();
    }
  }

  Map<String, double> get totals {
    double c = 0, p = 0, f = 0, cb = 0;
    for (var i in _items) {
      c += i.calories;
      p += i.protein;
      f += i.fat;
      cb += i.carbs;
    }
    return {'calories': c, 'protein': p, 'fat': f, 'carbs': cb};
  }
}
