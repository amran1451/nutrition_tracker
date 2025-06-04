import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import '../utils/labels.dart';
import '../models/food_item.dart';
import '../models/product.dart';
import '../providers/food_provider.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';
import '../models/meal_type_ext.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({Key? key}) : super(key: key);

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _gramsCtrl   = TextEditingController();
  final _calCtrl     = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl     = TextEditingController();
  final _carbCtrl    = TextEditingController();
  MealType _selectedMeal = MealType.breakfast;
  Product? _selectedProduct;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _gramsCtrl.dispose();
    _calCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _carbCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final item = FoodItem(
      name: _nameCtrl.text.trim(),
      grams: double.parse(_gramsCtrl.text),
      calories: double.parse(_calCtrl.text),
      protein: double.parse(_proteinCtrl.text),
      fat: double.parse(_fatCtrl.text),
      carbs: double.parse(_carbCtrl.text),
      consumedAt: DateTime.now(),
      mealType: _selectedMeal,
    );
    await context.read<FoodProvider>().addFood(item);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // Пересчёт КБЖУ при изменении граммов
  void _onGramsChanged(String value) {
    final grams = double.tryParse(value);
    if (_selectedProduct != null && grams != null) {
      final factor = grams / 100;
      _calCtrl.text     = (_selectedProduct!.calories * factor).toStringAsFixed(1);
      _proteinCtrl.text = (_selectedProduct!.protein  * factor).toStringAsFixed(1);
      _fatCtrl.text     = (_selectedProduct!.fat      * factor).toStringAsFixed(1);
      _carbCtrl.text    = (_selectedProduct!.carbs    * factor).toStringAsFixed(1);
    }
  }

  Widget _buildProductField() {
    final prodProv = context.read<ProductProvider>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TypeAheadFormField<Product>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: _nameCtrl,
          decoration: InputDecoration(
            labelText: 'Название продукта',
            hintText: 'Начните вводить название',
            suffixIcon: IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => const AddProductScreen()))
                  .then((_) => prodProv.loadAll()),
            ),
          ),
        ),
        suggestionsCallback: (pattern) => prodProv.searchProducts(pattern),
        itemBuilder: (context, suggestion) => ListTile(
          title: Text(suggestion.name),
          subtitle: Text(
            '${suggestion.calories.toStringAsFixed(0)} ккал, '
            '${suggestion.protein.toStringAsFixed(1)}Б '
            '${suggestion.fat.toStringAsFixed(1)}Ж '
            '${suggestion.carbs.toStringAsFixed(1)}У',
          ),
        ),
        onSuggestionSelected: (Product p) {
          _selectedProduct = p;
          _nameCtrl.text   = p.name;
          const initialGrams = 100.0;
          _gramsCtrl.text   = initialGrams.toStringAsFixed(0);
          _onGramsChanged(_gramsCtrl.text);
        },
        noItemsFoundBuilder: (_) => const ListTile(title: Text('Ничего не найдено')),
        validator: (v) => v == null || v.isEmpty ? 'Введите название' : null,
      ),
    );
  }

  Widget _buildMealTypeField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<MealType>(
        value: _selectedMeal,
        decoration: const InputDecoration(labelText: 'Тип приёма пищи'),
        items: MealType.values.map((mt) {
          final label = mealTypeLabel(mt);
          return DropdownMenuItem(value: mt, child: Text(label));
        }).toList(),
        onChanged: (v) => setState(() => _selectedMeal = v!),
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    String hint,
    TextInputType type, {
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(labelText: label, hintText: hint),
        validator: (val) {
          if (val == null || val.trim().isEmpty) return 'Введите $label';
          if (type == TextInputType.number && double.tryParse(val) == null) {
            return 'Нужно число';
          }
          return null;
        },
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Добавить приём пищи')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildMealTypeField(),
              _buildProductField(),
              _buildField(
                _gramsCtrl, 'Граммы', '150', TextInputType.number,
                onChanged: _onGramsChanged,
              ),
              _buildField(_calCtrl, 'Калории', '0', TextInputType.number),
              _buildField(_proteinCtrl, 'Белки (г)', '0', TextInputType.number),
              _buildField(_fatCtrl, 'Жиры (г)', '0', TextInputType.number),
              _buildField(_carbCtrl, 'Углеводы (г)', '0', TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _save, child: const Text('Сохранить')),
            ],
          ),
        ),
      ),
    );
  }
}
