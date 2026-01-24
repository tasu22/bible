import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  double _fontSize = 18.0;
  bool _isDarkMode = true; // Default to dark mode
  static const double minFontSize = 14.0;
  static const double maxFontSize = 32.0;

  double get fontSize => _fontSize;
  bool get isDarkMode => _isDarkMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedSize = prefs.getDouble('font_size');
    if (savedSize != null && savedSize != _fontSize) {
      _fontSize = savedSize;
    }

    final savedDarkMode = prefs.getBool('is_dark_mode');
    if (savedDarkMode != null) {
      _isDarkMode = savedDarkMode;
    }

    notifyListeners();
  }

  void setFontSize(double size) {
    if (size >= minFontSize && size <= maxFontSize && size != _fontSize) {
      _fontSize = size;
      notifyListeners();
      _persistFontSize(size);
    }
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    _persistTheme(_isDarkMode);
  }

  Future<void> _persistFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('font_size', size);
  }

  Future<void> _persistTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', isDark);
  }
}
