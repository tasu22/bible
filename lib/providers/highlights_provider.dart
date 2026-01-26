import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/highlight.dart';
import '../constants/bible_constants.dart';

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
    // Normalizing book names to English for comparison ensures highlights sync across languages
    final currentBookEn = BibleConstants.getBookName(bookName, false);

    return _highlights.any((h) {
      final highlightBookEn = BibleConstants.getBookName(h.bookName, false);
      return highlightBookEn == currentBookEn &&
          h.chapter == chapter &&
          h.verseNumber == verseNumber;
    });
  }

  void toggleHighlight(Highlight highlight) {
    final targetBookEn = BibleConstants.getBookName(highlight.bookName, false);

    final index = _highlights.indexWhere((h) {
      final hBookEn = BibleConstants.getBookName(h.bookName, false);
      return hBookEn == targetBookEn &&
          h.chapter == highlight.chapter &&
          h.verseNumber == highlight.verseNumber;
    });

    if (index >= 0) {
      _highlights.removeAt(index);
    } else {
      _highlights.add(highlight);
    }
    notifyListeners();
    _persistHighlights();
  }

  void updateNote(Highlight highlight, String note) {
    final index = _highlights.indexWhere(
      (h) =>
          h.bookName == highlight.bookName &&
          h.chapter == highlight.chapter &&
          h.verseNumber == highlight.verseNumber &&
          h.isSwahili == highlight.isSwahili,
    );

    if (index >= 0) {
      _highlights[index] = _highlights[index].copyWith(note: note);
      notifyListeners();
      _persistHighlights();
    }
  }

  void _persistHighlights() {
    final box = Hive.box('highlights');
    final encoded = _highlights.map((h) => h.toJson()).toList();
    box.put(_storageKey, encoded);
  }
}
