import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import 'add_product_screen.dart';
import '../models/meal_type_ext.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final items = provider.products;

    return Scaffold(
      appBar: AppBar(title: const Text('Мои продукты')),
      body: items.isEmpty
          ? const Center(child: Text('Пока нет ни одного продукта'))
          : ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) {
                final p = items[i];
                return Dismissible(
                  key: ValueKey(p.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.redAccent,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (_) => provider.deleteProduct(p.id!),
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      '${p.calories.toStringAsFixed(0)} ккал, '
                      '${p.protein.toStringAsFixed(1)}P '
                      '${p.fat.toStringAsFixed(1)}F '
                      '${p.carbs.toStringAsFixed(1)}C',
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AddProductScreen(original: p),
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddProductScreen()),
        ),
      ),
    );
  }
}
