import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/highlight.dart';

class HighlightsProvider with ChangeNotifier {
  List<Highlight> _highlights = [];
  static const String _storageKey = 'highlighted_verses';

  List<Highlight> get highlights => _highlights;

  HighlightsProvider() {
    _loadHighlights();
  }

  void _loadHighlights() {
    final box = Hive.box('highlights');
    final saved = box.get(_storageKey);
    if (saved != null) {
      final List<String> savedList = List<String>.from(saved);
      _highlights = savedList.map((s) => Highlight.fromJson(s)).toList();
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

  void _persistHighlights() {
    final box = Hive.box('highlights');
    final encoded = _highlights.map((h) => h.toJson()).toList();
    box.put(_storageKey, encoded);
  }
}
