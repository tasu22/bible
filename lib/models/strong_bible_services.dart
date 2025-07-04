import 'dart:convert';
import 'package:flutter/services.dart';

class StrongBibleService {
  static List<dynamic>? _cachedVerses;

  static Future<List<dynamic>> _loadVerses() async {
    if (_cachedVerses != null) return _cachedVerses!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/english.json',
    );
    _cachedVerses = json.decode(jsonString);
    return _cachedVerses!;
  }

  static Future<List<String>> getBookNames() async {
    final verses = await _loadVerses();
    final bookSet = <String>{};
    for (var verse in verses) {
      bookSet.add(verse['book_name']);
    }
    final List<String> bookNames = bookSet.toList();
    bookNames.sort();
    return bookNames;
  }

  static Future<List<int>> getChaptersForBook(String bookName) async {
    final verses = await _loadVerses();
    final chapterSet = <int>{};
    for (var verse in verses) {
      if (verse['book_name'] == bookName) {
        chapterSet.add(verse['chapter'] as int);
      }
    }
    final List<int> chapters = chapterSet.toList();
    chapters.sort();
    return chapters;
  }

  static Future<List<String>> getVersesForBookChapter(
    String bookName,
    int chapter,
  ) async {
    final verses = await _loadVerses();
    return verses
        .where(
          (verse) =>
              verse['book_name'] == bookName && verse['chapter'] == chapter,
        )
        .map<String>((verse) => '${verse['verse']}. ${verse['text']}')
        .toList();
  }
}
