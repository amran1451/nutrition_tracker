import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../models/meal_type_ext.dart';
import '../utils/report_utils.dart';

class WeeklyReportScreen extends StatefulWidget {
  const WeeklyReportScreen({Key? key}) : super(key: key);

  @override
  State<WeeklyReportScreen> createState() => _WeeklyReportScreenState();
}

class _WeeklyReportScreenState extends State<WeeklyReportScreen> {
  DateTime _selectedDate = DateTime.now();
  WeeklyReport? _report;
  bool _isLoading = false;

  Future<void> _generateReport() async {
    setState(() { _isLoading = true; });
    final rep = await generateWeeklyReport(_selectedDate);
    setState(() { _report = rep; _isLoading = false; });
  }

  void _pickDate() async {
    final dt = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (dt != null) {
      setState(() { _selectedDate = dt; _report = null; });
    }
  }

  void _shareReport() {
    if (_report == null) return;
    final sb = StringBuffer();
    sb.writeln('Дата,Название,Гр,Ккал,Белки,Жиры,Углеводы');
    for (var f in _report!.items) {
      final d = DateFormat('yyyy-MM-dd').format(f.consumedAt);
      sb.writeln(
        '$d,${f.name},${f.grams.toStringAsFixed(0)},'
        '${f.calories.toStringAsFixed(0)},'
        '${f.protein.toStringAsFixed(1)},'
        '${f.fat.toStringAsFixed(1)},'
        '${f.carbs.toStringAsFixed(1)}'
      );
    }
    Share.share(sb.toString(), subject: 'Отчет за неделю');
  }

  @override
  Widget build(BuildContext context) {
    final weekLabel = _report != null
        ? '${DateFormat.yMMMd('ru_RU').format(_report!.start)} – ${DateFormat.yMMMd('ru_RU').format(_report!.end)}'
        : DateFormat.yMMMd('ru_RU').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(title: const Text('Отчет за неделю')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Text('Неделя: $weekLabel'),
                const Spacer(),
                IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDate),
              ],
            ),
            ElevatedButton(
              onPressed: _generateReport,
              child: const Text('Сформировать отчет'),
            ),
            if (_isLoading) const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
            if (_report != null && !_isLoading) ...[
              const SizedBox(height: 12),
              Text(
                'Всего: ${_report!.totals['cal']!.toStringAsFixed(0)} ккал, '
                '${_report!.totals['prot']!.toStringAsFixed(1)}P '
                '${_report!.totals['fat']!.toStringAsFixed(1)}F '
                '${_report!.totals['carb']!.toStringAsFixed(1)}C',
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.builder(
                  itemCount: _report!.items.length,
                  itemBuilder: (_, i) {
                    final f = _report!.items[i];
                    return ListTile(
                      title: Text('${DateFormat.Hm().format(f.consumedAt)} ${f.name}'),
                      subtitle: Text('${f.grams} г — ${f.calories.toStringAsFixed(0)} ккал'),
                    );
                  },
                ),
              ),
              ElevatedButton.icon(
                onPressed: _shareReport,
                icon: const Icon(Icons.share),
                label: const Text('Экспорт CSV'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
