import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

  void _loadSettings() {
    final box = Hive.box('settings');
    _fontSize = box.get('font_size', defaultValue: 18.0);
    _isDarkMode = box.get('is_dark_mode', defaultValue: true);
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

  void _persistFontSize(double size) {
    Hive.box('settings').put('font_size', size);
  }

  void _persistTheme(bool isDark) {
    Hive.box('settings').put('is_dark_mode', isDark);
  }
}
