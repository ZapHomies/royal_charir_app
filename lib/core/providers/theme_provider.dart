import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme State Notifier for managing dark/light mode
class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  static const String _themeKey = 'royal_charir_theme_mode';

  /// Load saved theme preference
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeName = prefs.getString(_themeKey);
      if (themeName != null) {
        state = ThemeMode.values.firstWhere(
          (e) => e.name == themeName,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
  }

  /// Save theme preference
  Future<void> _saveTheme(ThemeMode mode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.name);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  /// Set theme mode
  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _saveTheme(mode);
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newMode);
  }

  /// Check if current theme is dark
  bool get isDarkMode => state == ThemeMode.dark;
}

/// Theme Provider
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Helper to get if dark mode is enabled based on context
bool isDarkMode(BuildContext context) {
  final brightness = Theme.of(context).brightness;
  return brightness == Brightness.dark;
}
