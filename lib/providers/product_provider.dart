import 'package:flutter/foundation.dart';
import '../database/db_helper.dart';
import '../models/product.dart';
import '../utils/food_api.dart';

class ProductProvider extends ChangeNotifier {
  final DBHelper _db = DBHelper();
  final List<Product> _products = [];

  List<Product> get products => List.unmodifiable(_products);

  ProductProvider() {
    loadAll();
  }

  Future<void> loadAll() async {
    final list = await _db.fetchAllProducts();
    _products
      ..clear()
      ..addAll(list);
    notifyListeners();
  }

  Future<void> addProduct(Product p) async {
    final id = await _db.insertProduct(p);
    _products.insert(0, p.copyWith(id: id));
    notifyListeners();
  }

  Future<void> updateProduct(Product p) async {
    await _db.updateProduct(p);
    final idx = _products.indexWhere((x) => x.id == p.id);
    if (idx != -1) _products[idx] = p;
    notifyListeners();
  }

  Future<void> deleteProduct(int id) async {
    await _db.deleteProduct(id);
    _products.removeWhere((x) => x.id == id);
    notifyListeners();
  }

  /// Гибридный поиск: сначала локально, потом онлайн и кеширование
  Future<List<Product>> searchProducts(String query) async {
    final lower = query.toLowerCase();
    final local = _products
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
    if (local.isNotEmpty) return local;

    // Онлайн-поиск через USDA API
    final online = await FoodApi.searchFoods(query);
    for (var p in online) {
      final id = await _db.insertProduct(p);
      final cached = p.copyWith(id: id);
      _products.insert(0, cached);
    }
    notifyListeners();
    return online;
  }
}
