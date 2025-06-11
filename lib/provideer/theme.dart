import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 2;
    _themeMode = ThemeMode.values[themeIndex];
    notifyListeners();
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  String get themeText {
    switch (_themeMode) {
      case ThemeMode.light:
        return "Mode Clair ☀️";
      case ThemeMode.dark:
        return "Mode Sombre 🌙";
      case ThemeMode.system:
      return "Mode Système 📱";
    }
  }

  IconData get iconData {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
      return Icons.phone_android;
    }
  }

  Color get iconColor {
    switch (_themeMode) {
      case ThemeMode.light:
        return Colors.blue;
      case ThemeMode.dark:
        return Colors.yellow;
      case ThemeMode.system:
      return Colors.green;
    }
  }
}
