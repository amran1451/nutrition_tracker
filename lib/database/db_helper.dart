import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../models/food_item.dart';
import '../models/product.dart';

class DBHelper {
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static const _dbName = 'nutrition.db';
  static const _dbVersion = 4;
  static const _tableFood = 'food_items';
  static const _tableProducts = 'products';
  static const _tablePlans = 'meal_plans';
  static const _tablePlanItems = 'plan_items';

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Таблица приёмов пищи
    await db.execute('''
      CREATE TABLE $_tableFood(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        consumedAt TEXT NOT NULL,
        mealType INTEGER NOT NULL
      )
    ''');

    // Локальная база продуктов
    await db.execute('''
      CREATE TABLE $_tableProducts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL
      )
    ''');

    // Таблица планов
    await db.execute('''
      CREATE TABLE $_tablePlans(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL
      )
    ''');

    // Пункты плана
    await db.execute('''
      CREATE TABLE $_tablePlanItems(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        planId INTEGER NOT NULL,
        name TEXT NOT NULL,
        grams REAL NOT NULL,
        calories REAL NOT NULL,
        protein REAL NOT NULL,
        fat REAL NOT NULL,
        carbs REAL NOT NULL,
        FOREIGN KEY(planId) REFERENCES $_tablePlans(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      await db.execute(
        'ALTER TABLE $_tableFood ADD COLUMN mealType INTEGER NOT NULL DEFAULT 0'
      );
    }
    if (oldV < 3) {
      await db.execute('''
        CREATE TABLE $_tableProducts(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          fat REAL NOT NULL,
          carbs REAL NOT NULL
        )
      ''');
    }
    if (oldV < 4) {
      await db.execute('''
        CREATE TABLE $_tablePlans(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE $_tablePlanItems(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          planId INTEGER NOT NULL,
          name TEXT NOT NULL,
          grams REAL NOT NULL,
          calories REAL NOT NULL,
          protein REAL NOT NULL,
          fat REAL NOT NULL,
          carbs REAL NOT NULL,
          FOREIGN KEY(planId) REFERENCES $_tablePlans(id) ON DELETE CASCADE
        )
      ''');
    }
  }

  // --- Методы CRUD для food_items ---
  Future<int> insertFood(FoodItem item) async {
    final db = await database;
    return db.insert(_tableFood, item.toMap());
  }

  Future<List<FoodItem>> fetchFoodsByDate(DateTime date) async {
    final db = await database;
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final maps = await db.query(
      _tableFood,
      where: 'consumedAt >= ? AND consumedAt < ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'consumedAt DESC',
    );
    return maps.map((m) => FoodItem.fromMap(m)).toList();
  }

  Future<int> deleteFood(int id) async {
    final db = await database;
    return db.delete(_tableFood, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateFood(FoodItem item) async {
    final db = await database;
    return db.update(
      _tableFood,
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  // --- Методы CRUD для products ---
  Future<int> insertProduct(Product p) async {
    final db = await database;
    return db.insert(_tableProducts, p.toMap());
  }

  Future<List<Product>> fetchAllProducts() async {
    final db = await database;
    final maps = await db.query(_tableProducts, orderBy: 'name COLLATE NOCASE');
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<int> updateProduct(Product p) async {
    final db = await database;
    return db.update(
      _tableProducts,
      p.toMap(),
      where: 'id = ?',
      whereArgs: [p.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return db.delete(_tableProducts, where: 'id = ?', whereArgs: [id]);
  }
}
