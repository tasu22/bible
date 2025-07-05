import 'dart:convert';
import 'package:flutter/services.dart';

class SwahiliBibleService {
  static Map<String, dynamic>? _cachedData;
  static List<String>? _cachedBookNames;
  static final Map<String, List<int>> _cachedChapters = {};
  static final Map<String, Map<int, List<Map<String, String>>>> _cachedVerses =
      {};

  static Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) return _cachedData!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    _cachedData = json.decode(jsonString);
    return _cachedData!;
  }

  static Future<List<String>> getBookNames() async {
    if (_cachedBookNames != null) return _cachedBookNames!;
    final data = await _loadData();
    final books = data['BIBLEBOOK'] as List<dynamic>;
    _cachedBookNames = books.map((b) => b['book_name'] as String).toList();
    return _cachedBookNames!;
  }

  static Future<List<int>> getChapters(String bookName) async {
    if (_cachedChapters.containsKey(bookName))
      return _cachedChapters[bookName]!;
    final data = await _loadData();
    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
    );
    final chapters = book['CHAPTER'] as List<dynamic>;
    final chapterList =
        chapters.map((c) => int.parse(c['chapter_number'])).toList();
    _cachedChapters[bookName] = chapterList;
    return chapterList;
  }

  static Future<List<Map<String, String>>> getVerses(
    String bookName,
    int chapter,
  ) async {
    if (_cachedVerses[bookName] != null &&
        _cachedVerses[bookName]![chapter] != null) {
      return _cachedVerses[bookName]![chapter]!;
    }
    final data = await _loadData();
    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
    );
    final chapterData = (book['CHAPTER'] as List<dynamic>).firstWhere(
      (c) => c['chapter_number'] == chapter.toString(),
    );
    final verses = chapterData['VERSES'] as List<dynamic>;
    final verseList =
        verses
            .map(
              (v) => {
                'verse_number': v['verse_number'].toString(),
                'verse_text': v['verse_text'].toString(),
              },
            )
            .toList();
    _cachedVerses[bookName] ??= {};
    _cachedVerses[bookName]![chapter] = verseList;
    return verseList;
  }
}
