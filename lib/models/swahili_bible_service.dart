import 'dart:convert';
import 'package:flutter/services.dart';

class SwahiliBibleService {
  static Future<List<String>> getBookNames() async {
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

    final books = data['BIBLEBOOK'] as List<dynamic>;
    return books.map((b) => b['book_name'] as String).toList();
  }

  static Future<List<int>> getChapters(String bookName) async {
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

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
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    final Map<String, dynamic> data = json.decode(jsonString);

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
