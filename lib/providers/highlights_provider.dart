import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/highlight.dart';

class HighlightsProvider with ChangeNotifier {
  List<Highlight> _highlights = [];
  static const String _storageKey = 'highlighted_verses';

  List<Highlight> get highlights => _highlights;

  HighlightsProvider() {
    _loadHighlights();
  }

  Future<void> _loadHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? saved = prefs.getStringList(_storageKey);
    if (saved != null) {
      _highlights = saved.map((s) => Highlight.fromJson(s)).toList();
      notifyListeners();
    }
  }

  bool isHighlighted(
    String bookName,
    int chapter,
    String verseNumber,
    bool isSwahili,
  ) {
    return _highlights.any(
      (h) =>
          h.bookName == bookName &&
          h.chapter == chapter &&
          h.verseNumber == verseNumber &&
          h.isSwahili == isSwahili,
    );
  }

  void toggleHighlight(Highlight highlight) {
    final index = _highlights.indexWhere(
      (h) =>
          h.bookName == highlight.bookName &&
          h.chapter == highlight.chapter &&
          h.verseNumber == highlight.verseNumber &&
          h.isSwahili == highlight.isSwahili,
    );

    if (index >= 0) {
      _highlights.removeAt(index);
    } else {
      _highlights.add(highlight);
    }
    notifyListeners();
    _persistHighlights();
  }

  Future<void> _persistHighlights() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> encoded = _highlights.map((h) => h.toJson()).toList();
    await prefs.setStringList(_storageKey, encoded);
  }
}
