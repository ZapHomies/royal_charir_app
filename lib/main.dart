import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:window_manager/window_manager.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/database/database_seeder.dart';
import 'features/employees/data/repositories/employee_repository.dart';
import 'features/onboarding/providers/onboarding_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite for Windows
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize date formatting for Indonesian locale
  await initializeDateFormatting('id_ID', null);

  // Initialize SharedPreferences for onboarding
  final sharedPreferences = await SharedPreferences.getInstance();

  // Initialize Window Manager for Desktop
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    await windowManager.ensureInitialized();
    WindowOptions windowOptions = const WindowOptions(
      size: Size(1280, 720),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Seed sample data on first run
  try {
    await DatabaseSeeder().seedAll();
  } catch (e) {
    debugPrint('Seeding error (may be normal if data exists): $e');
  }

  // Initialize employee tables
  try {
    await EmployeeRepository().initializeTables();
    debugPrint('Employee tables initialized successfully');
  } catch (e) {
    debugPrint('Employee table init error: $e');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Override SharedPreferences provider
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const RoyalCharirApp(),
    ),
  );
}
