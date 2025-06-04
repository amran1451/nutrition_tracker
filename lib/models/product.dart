class Product {
  final int? id;
  final String name;
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  Product({
    this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'protein': protein,
      'fat': fat,
      'carbs': carbs,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      calories: map['calories'] as double,
      protein: map['protein'] as double,
      fat: map['fat'] as double,
      carbs: map['carbs'] as double,
    );
  }
}

extension ProductCopy on Product {
  Product copyWith({
    int? id,
    String? name,
    double? calories,
    double? protein,
    double? fat,
    double? carbs,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      calories: calories ?? this.calories,
      protein: protein ?? this.protein,
      fat: fat ?? this.fat,
      carbs: carbs ?? this.carbs,
    );
  }
}
