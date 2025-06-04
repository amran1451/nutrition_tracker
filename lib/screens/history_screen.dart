import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/meal_type_ext.dart';
import '../providers/food_provider.dart';
import '../widgets/food_tile.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    // загрузим данные за сегодня
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodProvider>().loadForDate(_selectedDay);
    });
  }

  void _onDaySelected(DateTime selected, DateTime focused) {
    setState(() {
      _selectedDay = selected;
      _focusedDay = focused;
    });
    context.read<FoodProvider>().loadForDate(selected);
  }

  @override
  Widget build(BuildContext context) {
    final foodItems = context.watch<FoodProvider>().foodItems;

    return Scaffold(
      appBar: AppBar(title: const Text('История питания')),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2100, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) =>
                isSameDay(day, _selectedDay),
            onDaySelected: _onDaySelected,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: foodItems.isEmpty
                ? const Center(child: Text('Нет записей за этот день'))
                : ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (_, i) =>
                        FoodTile(item: foodItems[i]),
                  ),
          ),
        ],
      ),
    );
  }
}
