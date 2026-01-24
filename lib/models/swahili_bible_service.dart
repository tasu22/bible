import 'dart:convert';
import 'package:flutter/services.dart';

class SwahiliBibleService {
  static Map<String, dynamic>? _cachedData;

  static Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) return _cachedData!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    _cachedData = json.decode(jsonString);
    return _cachedData!;
  }

  static Future<List<String>> getBookNames() async {
    final data = await _loadData();
    final books = data['BIBLEBOOK'] as List<dynamic>;
    return books.map((b) => b['book_name'] as String).toList();
  }

  static Future<List<int>> getChapters(String bookName) async {
    final data = await _loadData();

    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
    );

    final chapters = book['CHAPTER'] as List<dynamic>;
    return chapters.map((c) => int.parse(c['chapter_number'])).toList();
  }

  static Future<List<Map<String, String>>> getVerses(
    String bookName,
    int chapter,
  ) async {
    final data = await _loadData();

    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
    );

    final chapterData = (book['CHAPTER'] as List<dynamic>).firstWhere(
      (c) => c['chapter_number'] == chapter.toString(),
    );

    final verses = chapterData['VERSES'] as List<dynamic>;
    return verses
        .map(
          (v) => {
            'verse_number': v['verse_number'].toString(),
            'verse_text': v['verse_text'].toString(),
          },
        )
        .toList();
  }
}
