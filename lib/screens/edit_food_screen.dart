import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_type_ext.dart';
import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../utils/labels.dart';

class EditFoodScreen extends StatefulWidget {
  final FoodItem original;
  const EditFoodScreen({Key? key, required this.original}) : super(key: key);

  @override
  State<EditFoodScreen> createState() => _EditFoodScreenState();
}

class _EditFoodScreenState extends State<EditFoodScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _gramsCtrl;
  late TextEditingController _calCtrl;
  late TextEditingController _proteinCtrl;
  late TextEditingController _fatCtrl;
  late TextEditingController _carbCtrl;
  late MealType _selectedMeal;

  @override
  void initState() {
    super.initState();
    final o = widget.original;
    _nameCtrl    = TextEditingController(text: o.name);
    _gramsCtrl   = TextEditingController(text: o.grams.toString());
    _calCtrl     = TextEditingController(text: o.calories.toString());
    _proteinCtrl = TextEditingController(text: o.protein.toString());
    _fatCtrl     = TextEditingController(text: o.fat.toString());
    _carbCtrl    = TextEditingController(text: o.carbs.toString());
    _selectedMeal = o.mealType;
  }

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
    if (_formKey.currentState!.validate()) {
      final edited = widget.original.copyWith(
        name: _nameCtrl.text.trim(),
        grams: double.parse(_gramsCtrl.text),
        calories: double.parse(_calCtrl.text),
        protein: double.parse(_proteinCtrl.text),
        fat: double.parse(_fatCtrl.text),
        carbs: double.parse(_carbCtrl.text),
        mealType: _selectedMeal,
      );
      await context.read<FoodProvider>().editFood(edited);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
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
    TextInputType type,
  ) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать приём пищи')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildMealTypeField(),
              _buildField(_nameCtrl, 'Название', 'Яблоко', TextInputType.text),
              _buildField(_gramsCtrl, 'Граммы', '150', TextInputType.number),
              _buildField(_calCtrl, 'Калории', '90', TextInputType.number),
              _buildField(_proteinCtrl, 'Белки (г)', '0.3', TextInputType.number),
              _buildField(_fatCtrl, 'Жиры (г)', '0.2', TextInputType.number),
              _buildField(_carbCtrl, 'Углеводы (г)', '20', TextInputType.number),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
