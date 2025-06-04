import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/meal_type_ext.dart';
import '../models/food_item.dart';
import '../models/meal_plan.dart';
import '../providers/food_provider.dart';
import '../providers/goal_provider.dart';
import '../providers/plan_provider.dart';
import '../widgets/food_tile.dart';
import 'add_food_screen.dart';
import 'calculator_screen.dart';
import 'history_screen.dart';
import 'meal_plans_screen.dart';
import 'products_screen.dart';
import 'weekly_report_screen.dart';

import '../providers/theme_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final foodProv = context.watch<FoodProvider>();
    final goalProv = context.watch<GoalProvider>();
    final planProv = context.read<PlanProvider>();
    final totals   = foodProv.totals;
    final dateStr  = DateFormat.yMMMMd('ru_RU').format(DateTime.now());

    Widget progressBar(String label, double value, double goal, Color color) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${value.toStringAsFixed(0)} / ${goal.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: goal > 0 ? (value / goal).clamp(0, 1) : 0,
            minHeight: 8,
            color: color,
            backgroundColor: color.withOpacity(0.2),
          ),
          const SizedBox(height: 8),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Еда • $dateStr'),
        leading: IconButton(
          icon: const Icon(Icons.history),
          tooltip: 'История',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),
        actions: [
         IconButton(
   icon: context.watch<ThemeProvider>().isDarkMode
     ? const Icon(Icons.dark_mode)
     : const Icon(Icons.light_mode),
   tooltip: 'Переключить тему',
   onPressed: () => context.read<ThemeProvider>().toggle(),
 ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Мои продукты',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.event_note),
            tooltip: 'Планы питания',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const MealPlansScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calendar_month),
            tooltip: 'Отчет недели',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.calculate),
            tooltip: 'Норма питания',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const CalculatorScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AddFoodScreen()),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            progressBar('Калории',  totals['calories']!, goalProv.calories, Colors.orange),
            progressBar('Белки',    totals['protein']!,  goalProv.protein,  Colors.green),
            progressBar('Жиры',     totals['fat']!,      goalProv.fat,      Colors.redAccent),
            progressBar('Углеводы', totals['carbs']!,    goalProv.carbs,    Colors.blue),
            const SizedBox(height: 12),
            Expanded(
              child: foodProv.foodItems.isEmpty
                  ? const Center(child: Text('Записей пока нет'))
                  : ListView.builder(
                      itemCount: foodProv.foodItems.length,
                      itemBuilder: (_, i) =>
                          FoodTile(item: foodProv.foodItems[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
