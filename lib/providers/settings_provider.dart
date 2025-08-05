import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _engineerPercentage = 0.0;
  ThemeMode _themeMode = ThemeMode.system; // Default theme
  bool _isLoaded = false;

  static const String _engineerPercentageKey = 'engineerPercentage';
  static const String _themePreferenceKey = 'theme_mode';

  double get engineerPercentage => _engineerPercentage;
  ThemeMode get themeMode => _themeMode;

  SettingsProvider() {
    _loadSettings();
  }

  // تحميل الإعدادات من التخزين المحلي
  Future<void> _loadSettings() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    _engineerPercentage = prefs.getDouble(_engineerPercentageKey) ?? 0.0;

    String? themeModeString = prefs.getString(_themePreferenceKey);
    if (themeModeString == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (themeModeString == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode =
          ThemeMode.system; // Default if nothing saved or 'system' was saved
    }

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> _saveThemePreference(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeModeString = 'system';
    if (mode == ThemeMode.dark) {
      themeModeString = 'dark';
    } else if (mode == ThemeMode.light) {
      themeModeString = 'light';
    }
    await prefs.setString(_themePreferenceKey, themeModeString);
  }

  // تعيين نسبة المهندس وحفظها
  Future<void> setEngineerPercentage(double percentage) async {
    _engineerPercentage = percentage;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_engineerPercentageKey, percentage);
    notifyListeners();
  }

  void toggleThemeMode() {
    if (_themeMode == ThemeMode.light) {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.light;
    }
    _saveThemePreference(_themeMode);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _saveThemePreference(_themeMode);
    notifyListeners();
  }
}
