import 'dart:convert';
import 'package:flutter/services.dart';

class StrongBibleService {
  static List<dynamic>? _cachedVerses;
  static List<String>? _cachedBookNames;
  static final Map<String, List<int>> _cachedChapters = {};
  static final Map<String, Map<int, List<String>>> _cachedVersesByBookChapter =
      {};

  static Future<List<dynamic>> _loadVerses() async {
    if (_cachedVerses != null) return _cachedVerses!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/english.json',
    );
    _cachedVerses = json.decode(jsonString);
    return _cachedVerses!;
  }

  static Future<List<String>> getBookNames() async {
    if (_cachedBookNames != null) return _cachedBookNames!;
    final verses = await _loadVerses();
    final bookSet = <String>{};
    for (var verse in verses) {
      bookSet.add(verse['book_name']);
    }
    final List<String> bookNames = bookSet.toList();
    bookNames.sort();
    _cachedBookNames = bookNames;
    return _cachedBookNames!;
  }

  static Future<List<int>> getChaptersForBook(String bookName) async {
    if (_cachedChapters.containsKey(bookName)) {
      return _cachedChapters[bookName]!;
    }
    final verses = await _loadVerses();
    final chapterSet = <int>{};
    for (var verse in verses) {
      if (verse['book_name'] == bookName) {
        chapterSet.add(verse['chapter'] as int);
      }
    }
    final List<int> chapters = chapterSet.toList();
    chapters.sort();
    _cachedChapters[bookName] = chapters;
    return chapters;
  }

  static Future<List<String>> getVersesForBookChapter(
    String bookName,
    int chapter,
  ) async {
    if (_cachedVersesByBookChapter[bookName] != null &&
        _cachedVersesByBookChapter[bookName]![chapter] != null) {
      return _cachedVersesByBookChapter[bookName]![chapter]!;
    }
    final verses = await _loadVerses();
    final result =
        verses
            .where(
              (verse) =>
                  verse['book_name'] == bookName && verse['chapter'] == chapter,
            )
            .map<String>((verse) => '${verse['verse']}. ${verse['text']}')
            .toList();
    _cachedVersesByBookChapter[bookName] ??= {};
    _cachedVersesByBookChapter[bookName]![chapter] = result;
    return result;
  }
}
