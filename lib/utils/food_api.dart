import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config.dart';

class FoodApi {
  /// Ищет продукты в USDA FoodData Central
  static Future<List<Product>> searchFoods(String query) async {
    final url = Uri.https(
      'api.nal.usda.gov',
      '/fdc/v1/foods/search',
      {
        'api_key': USDA_API_KEY,
        'query': query,
        'pageSize': '10',
      },
    );
    final res = await http.get(url);
    if (res.statusCode != 200) {
      throw Exception('Ошибка API: ${res.statusCode}');
    }
    final body = json.decode(res.body) as Map<String, dynamic>;
    final List foods = body['foods'] ?? [];

    return foods.map((f) {
      // Находим нужные нутриенты
      double kcal = 0, prot = 0, fat = 0, carbs = 0;
      for (var n in f['foodNutrients'] as List) {
        final name = (n['nutrientName'] as String).toLowerCase();
        final val  = (n['value'] as num).toDouble();
        if (name.contains('energy'))       kcal  = val;
        else if (name.contains('protein')) prot  = val;
        else if (name.contains('total lipid')) fat  = val;
        else if (name.contains('carbohydrate')) carbs = val;
      }
      return Product(
        name: f['description'] as String,
        calories: kcal,
        protein: prot,
        fat: fat,
        carbs: carbs,
      );
    }).toList();
  }
}
