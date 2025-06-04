import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/food_item.dart';
import '../providers/food_provider.dart';
import '../screens/edit_food_screen.dart';
import '../utils/labels.dart';

class FoodTile extends StatelessWidget {
  final FoodItem item;
  const FoodTile({Key? key, required this.item}) : super(key: key);

  String get _mealLabel {
    String mealLabel = mealTypeLabel(item.mealType);
    return mealLabel;
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(item.id),
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
            title: const Text('Удалить запись?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Нет')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Да')),
            ],
          ),
        );
      },
      onDismissed: (_) {
        context.read<FoodProvider>().deleteFood(item.id!);
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        child: ListTile(
          onLongPress: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => EditFoodScreen(original: item),
              ),
            );
          },
          title: Text(item.name),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_mealLabel),
              const SizedBox(height: 4),
              Text(
                '${item.calories.toStringAsFixed(0)} ккал, '
                '${item.protein.toStringAsFixed(1)}Б '
                '${item.fat.toStringAsFixed(1)}Ж '
                '${item.carbs.toStringAsFixed(1)}У',
              ),
            ],
          ),
          trailing: Text('${item.grams.toStringAsFixed(0)} г'),
        ),
      ),
    );
  }
}
