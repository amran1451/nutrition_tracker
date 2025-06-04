import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'providers/theme_provider.dart';
import 'providers/food_provider.dart';
import 'providers/goal_provider.dart';
import 'providers/product_provider.dart';
import 'providers/plan_provider.dart';
import 'models/goal_type.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // инициализируем intl для ru_RU
  await initializeDateFormatting('ru_RU', null);

  // загружаем сохранённую тему один раз
  final themeProv = await ThemeProvider.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => themeProv),
        ChangeNotifierProvider(create: (_) => FoodProvider()),
        ChangeNotifierProvider(create: (_) => GoalProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => PlanProvider()),
      ],
      child: const NutritionTrackerApp(),
    ),
  );
}
