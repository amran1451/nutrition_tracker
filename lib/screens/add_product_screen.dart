import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../providers/product_provider.dart';
import '../models/meal_type_ext.dart';

class AddProductScreen extends StatefulWidget {
  final Product? original;
  const AddProductScreen({Key? key, this.original}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _caloriesCtrl;
  late TextEditingController _proteinCtrl;
  late TextEditingController _fatCtrl;
  late TextEditingController _carbsCtrl;

  @override
  void initState() {
    super.initState();
    final o = widget.original;
    _nameCtrl     = TextEditingController(text: o?.name ?? '');
    _caloriesCtrl = TextEditingController(text: o?.calories.toString() ?? '');
    _proteinCtrl  = TextEditingController(text: o?.protein.toString() ?? '');
    _fatCtrl      = TextEditingController(text: o?.fat.toString() ?? '');
    _carbsCtrl    = TextEditingController(text: o?.carbs.toString() ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _caloriesCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _carbsCtrl.dispose();
    super.dispose();
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    final p = Product(
      id: widget.original?.id,
      name: _nameCtrl.text.trim(),
      calories: double.parse(_caloriesCtrl.text),
      protein: double.parse(_proteinCtrl.text),
      fat: double.parse(_fatCtrl.text),
      carbs: double.parse(_carbsCtrl.text),
    );
    final prov = context.read<ProductProvider>();
    if (widget.original == null) {
      await prov.addProduct(p);
    } else {
      await prov.updateProduct(p);
    }
    Navigator.of(context).pop();
  }

  Widget _field(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
        validator: (v) {
          if (v == null || v.isEmpty) return 'Введите $label';
          if (label != 'Название' && double.tryParse(v) == null) {
            return 'Нужно число';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.original != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Редактировать продукт' : 'Новый продукт')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _field(_nameCtrl, 'Название'),
              _field(_caloriesCtrl, 'Калории'),
              _field(_proteinCtrl, 'Белки (г)'),
              _field(_fatCtrl, 'Жиры (г)'),
              _field(_carbsCtrl, 'Углеводы (г)'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _save,
                child: Text(isEdit ? 'Сохранить' : 'Добавить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
