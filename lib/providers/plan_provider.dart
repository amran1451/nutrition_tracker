import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/meal_plan.dart';

class PlanProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final List<MealPlan> _plans = [];

  List<MealPlan> get plans => List.unmodifiable(_plans);

  PlanProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    final db = await _db.database;
    final planMaps = await db.query('meal_plans');
    _plans.clear();
    for (var pm in planMaps) {
      final planId = pm['id'] as int;
      final itemMaps =
          await db.query('plan_items', where: 'planId = ?', whereArgs: [planId]);
      final items = itemMaps.map((im) => PlanItem.fromMap(im)).toList();
      _plans.add(MealPlan.fromMap(pm, items));
    }
    notifyListeners();
  }

  Future<int> addPlan(MealPlan p) async {
    final db = await _db.database;
    final newId = await db.insert('meal_plans', p.toMap());
    for (var item in p.items) {
      await db.insert('plan_items', item.copyWith(planId: newId).toMap());
    }
    await loadAll();
    return newId;
  }

  Future<void> updatePlan(MealPlan p) async {
    if (p.id == null) return;
    final db = await _db.database;
    await db.update(
      'meal_plans',
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
    await db.delete('plan_items', where: 'planId = ?', whereArgs: [p.id]);
    for (var item in p.items) {
      await db.insert('plan_items', item.copyWith(planId: p.id!).toMap());
    }
    await loadAll();
  }

  Future<void> deletePlan(int id) async {
    final db = await _db.database;
    await db.delete('plan_items', where: 'planId = ?', whereArgs: [id]);
    await db.delete('meal_plans', where: 'id = ?', whereArgs: [id]);
    await loadAll();
  }
}
