import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_type_ext.dart';
import '../models/meal_plan.dart';
import '../providers/plan_provider.dart';
import 'edit_meal_plan_screen.dart';

class MealPlansScreen extends StatelessWidget {
  const MealPlansScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final planProv = context.watch<PlanProvider>();
    final plans = planProv.plans;

    return Scaffold(
      appBar: AppBar(title: const Text('Планы питания')),
      body: plans.isEmpty
          ? const Center(child: Text('Нет сохранённых планов'))
          : ListView.builder(
              itemCount: plans.length,
              itemBuilder: (_, i) {
                final plan = plans[i];
                return Dismissible(
                  key: ValueKey(plan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (_) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Удалить план?'),
                        actions: [
                          TextButton(onPressed: ()=>Navigator.pop(ctx,false), child: const Text('Нет')),
                          TextButton(onPressed: ()=>Navigator.pop(ctx,true), child: const Text('Да')),
                        ],
                      ),
                    );
                  },
                  onDismissed: (_) => planProv.deletePlan(plan.id!),
                  child: ListTile(
                    title: Text(plan.name),
                    subtitle: Text('${plan.items.length} позиций'),
                    onTap: () => Navigator.of(context)
                        .push(MaterialPageRoute(
                          builder: (_) => EditMealPlanScreen(original: plan),
                        ))
                        .then((_) => planProv.loadAll()),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        tooltip: 'Новый план',
        onPressed: () => Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const EditMealPlanScreen()))
            .then((_) => context.read<PlanProvider>().loadAll()),
      ),
    );
  }
}
