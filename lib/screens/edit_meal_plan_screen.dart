import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/meal_type_ext.dart';
import '../models/meal_plan.dart';
import '../providers/plan_provider.dart';

class EditMealPlanScreen extends StatefulWidget {
  final MealPlan? original;
  const EditMealPlanScreen({Key? key, this.original}) : super(key: key);

  @override
  State<EditMealPlanScreen> createState() => _EditMealPlanScreenState();
}

class _EditMealPlanScreenState extends State<EditMealPlanScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late List<PlanItem> _items;

  @override
  void initState() {
    super.initState();
    final orig = widget.original;
    _nameCtrl = TextEditingController(text: orig?.name ?? '');
    _items = orig?.items.map((e) => e).toList() ?? [];
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _savePlan() {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<PlanProvider>();
    final plan = MealPlan(
      id: widget.original?.id,
      name: _nameCtrl.text.trim(),
      items: _items,
    );
    if (widget.original == null) {
      provider.addPlan(plan);
    } else {
      provider.updatePlan(plan);
    }
    Navigator.of(context).pop();
  }

  Future<void> _openItemDialog({PlanItem? item, int? index}) async {
    final nameCtrl  = TextEditingController(text: item?.name ?? '');
    final gramsCtrl = TextEditingController(text: item?.grams.toString() ?? '');
    final calCtrl   = TextEditingController(text: item?.calories.toString() ?? '');
    final protCtrl  = TextEditingController(text: item?.protein.toString() ?? '');
    final fatCtrl   = TextEditingController(text: item?.fat.toString() ?? '');
    final carbCtrl  = TextEditingController(text: item?.carbs.toString() ?? '');

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(item == null ? 'Новая позиция' : 'Редактировать позицию'),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: nameCtrl,  decoration: const InputDecoration(labelText: 'Название')),
              TextField(controller: gramsCtrl, decoration: const InputDecoration(labelText: 'Граммы'),    keyboardType: TextInputType.number),
              TextField(controller: calCtrl,   decoration: const InputDecoration(labelText: 'Калории'),   keyboardType: TextInputType.number),
              TextField(controller: protCtrl,  decoration: const InputDecoration(labelText: 'Белки'),     keyboardType: TextInputType.number),
              TextField(controller: fatCtrl,   decoration: const InputDecoration(labelText: 'Жиры'),      keyboardType: TextInputType.number),
              TextField(controller: carbCtrl,  decoration: const InputDecoration(labelText: 'Углеводы'),  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text('Отмена')),
          TextButton(
            onPressed: () {
              final newItem = PlanItem(
                id: item?.id,
                planId: widget.original?.id ?? 0,
                name: nameCtrl.text.trim(),
                grams: double.parse(gramsCtrl.text),
                calories: double.parse(calCtrl.text),
                protein: double.parse(protCtrl.text),
                fat: double.parse(fatCtrl.text),
                carbs: double.parse(carbCtrl.text),
              );
              setState(() {
                if (index != null) _items[index] = newItem;
                else _items.add(newItem);
              });
              Navigator.pop(ctx);
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.original == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Новый план питания' : 'Редактировать план'),
        actions: [
          IconButton(icon: const Icon(Icons.save), tooltip: 'Сохранить', onPressed: _savePlan),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Название плана'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Введите название' : null,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _items.isEmpty
                  ? const Center(child: Text('Позиции не добавлены'))
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (_, i) {
                        final pi = _items[i];
                        return ListTile(
                          title: Text(pi.name),
                          subtitle: Text('${pi.grams} г — ${pi.calories.toStringAsFixed(0)} ккал'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openItemDialog(item: pi, index: i)),
                              IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => setState(() => _items.removeAt(i))),
                            ],
                          ),
                        );
                      },
                    ),
            ),
            ElevatedButton.icon(
              onPressed: () => _openItemDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Добавить позицию'),
            ),
          ],
        ),
      ),
    );
  }
}
