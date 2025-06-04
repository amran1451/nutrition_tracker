import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/goal_type.dart';
import '../providers/goal_provider.dart';
import '../utils/nutrition_calculator.dart';  // теперь только функции, без своего enum
import '../utils/labels.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({Key? key}) : super(key: key);

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _ageCtrl    = TextEditingController();

  bool _isMale = true;
  GoalType _goalType = GoalType.maintain;
  double _activityFactor = 1.2;

  double? _bmrValue;
  double? _tdeeValue;
  double? _adjustedCalories;
  MacroTargets? _result;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _heightCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;

    final w = double.parse(_weightCtrl.text);
    final h = double.parse(_heightCtrl.text);
    final a = int.parse(_ageCtrl.text);

    final bmr = calculateBMR(
      weightKg: w, heightCm: h, ageYears: a, isMale: _isMale,
    );
    final tdee = calculateTDEE(bmr: bmr, activityFactor: _activityFactor);
    final adj = adjustCalories(tdee: tdee, goalType: _goalType);
    final macros = calculateMacros(
      calories: adj, weightKg: w, goalType: _goalType,
    );

    setState(() {
      _bmrValue = bmr;
      _tdeeValue = tdee;
      _adjustedCalories = adj;
      _result = macros;
    });
  }

  void _save() {
    if (_result == null) return;
    context.read<GoalProvider>().setGoals(_result!);
    Navigator.of(context).pop();
  }

  Widget _field(TextEditingController ctrl, String label, TextInputType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: type,
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Введите $label';
          if (type == TextInputType.number && double.tryParse(v) == null) {
            return 'Нужно число';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gp = context.watch<GoalProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Калькулятор нормы')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Expanded(
                child: ListView(
                  children: [
                    _field(_weightCtrl, 'Вес (кг)', TextInputType.number),
                    _field(_heightCtrl, 'Рост (см)', TextInputType.number),
                    _field(_ageCtrl,    'Возраст',   TextInputType.number),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Мужчина'),
                      value: _isMale,
                      onChanged: (v) => setState(() => _isMale = v),
                    ),
                    DropdownButtonFormField<double>(
                      value: _activityFactor,
                      decoration: const InputDecoration(labelText: 'Активность'),
                      items: const [
                        DropdownMenuItem(value: 1.2, child: Text('Сидячий')),
                        DropdownMenuItem(value: 1.375, child: Text('Лёгкая')),
                        DropdownMenuItem(value: 1.55, child: Text('Умеренная')),
                        DropdownMenuItem(value: 1.725, child: Text('Высокая')),
                        DropdownMenuItem(value: 1.9, child: Text('Очень высокая')),
                      ],
                      onChanged: (v) => setState(() => _activityFactor = v!),
                    ),
                    DropdownButtonFormField<GoalType>(
                      value: _goalType,
                      decoration: const InputDecoration(labelText: 'Цель'),
                      items: GoalType.values.map((gt) {
                        final text = goalTypeLabel(gt);
                        return DropdownMenuItem(value: gt, child: Text(text));
                      }).toList(),
                      onChanged: (v) => setState(() => _goalType = v!),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Рассчитать'),
                    ),

                    if (_bmrValue != null) ...[
                      const SizedBox(height: 24),
                      Text('BMR: ${_bmrValue!.toStringAsFixed(0)} ккал'),
                    ],
                    if (_tdeeValue != null) ...[
                      const SizedBox(height: 8),
                      Text('TDEE: ${_tdeeValue!.toStringAsFixed(0)} ккал'),
                    ],
                    if (_adjustedCalories != null) ...[
                      const SizedBox(height: 8),
                      Text('Скорректировано: ${_adjustedCalories!.toStringAsFixed(0)} ккал'),
                    ],

                    if (_result != null) ...[
                      const SizedBox(height: 24),
                      Text('Белки: ${_result!.proteinGrams.toStringAsFixed(1)} г'),
                      Text('Жиры: ${_result!.fatGrams.toStringAsFixed(1)} г'),
                      Text('Углеводы: ${_result!.carbGrams.toStringAsFixed(1)} г'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _save,
                        child: const Text('Сохранить цель'),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            if (gp.calories > 0) ...[
              const Divider(),
              Text(
                'Текущая цель: ${gp.calories.toStringAsFixed(0)} ккал, '
                '${gp.protein.toStringAsFixed(1)}Б '
                '${gp.fat.toStringAsFixed(1)}Ж '
                '${gp.carbs.toStringAsFixed(1)}У',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
