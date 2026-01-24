import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class LanguageProvider with ChangeNotifier {
  String _language = 'English'; // default

  String get language => _language;

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
    Hive.box('settings').put('selected_language', lang);
  }

  bool get isSwahili => _language == 'Swahili';

  void loadLanguage() {
    final box = Hive.box('settings');
    final savedLang = box.get('selected_language');
    if (savedLang != null && savedLang != _language) {
      _language = savedLang;
      notifyListeners();
    }
  }
}
