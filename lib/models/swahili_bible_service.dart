import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/bible_constants.dart';

class SwahiliBibleService {
  static Map<String, dynamic>? _cachedData;

  static Future<Map<String, dynamic>> _loadData() async {
    if (_cachedData != null) return _cachedData!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/swahili.json',
    );
    _cachedData = await compute(_parseJson, jsonString);
    return _cachedData!;
  }

  static Map<String, dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString);
  }

  static Future<List<String>> getBookNames() async {
    return [
      ...BibleConstants.oldTestamentOrderSw,
      ...BibleConstants.newTestamentOrderSw,
    ];
  }

  static Future<List<int>> getChapters(String bookName) async {
    final box = Hive.box('bible_data');
    final key = 'sw_chapters_$bookName';

    if (box.containsKey(key)) {
      final List<dynamic> cached = box.get(key);
      return cached.cast<int>();
    }

    final data = await _loadData();

    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
      orElse: () => null,
    );

    if (book == null) return [];

    final chapters = book['CHAPTER'] as List<dynamic>;
    final result = chapters.map((c) => int.parse(c['chapter_number'])).toList();

    await box.put(key, result);
    return result;
  }

  static Future<List<Map<String, String>>> getVerses(
    String bookName,
    int chapter,
  ) async {
    final box = Hive.box('bible_data');
    final key = 'sw_verses_${bookName}_$chapter';

    if (box.containsKey(key)) {
      final List<dynamic> cached = box.get(key);
      return cached.map((e) => Map<String, String>.from(e)).toList();
    }

    final data = await _loadData();

    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
      orElse: () => null,
    );

    if (book == null) return [];

    final chapterData = (book['CHAPTER'] as List<dynamic>).firstWhere(
      (c) => c['chapter_number'] == chapter.toString(),
      orElse: () => null,
    );

    if (chapterData == null) return [];

    final verses = chapterData['VERSES'] as List<dynamic>;
    final result =
        verses
            .map(
              (v) => {
                'verse_number': v['verse_number'].toString(),
                'verse_text': v['verse_text'].toString(),
              },
            )
            .toList();

    await box.put(key, result);
    return result;
  }

  static Future<Map<int, List<String>>> getVersesForBook(
    String bookName,
  ) async {
    final box = Hive.box('bible_data');
    final key = 'sw_book_verses_$bookName';

    if (box.containsKey(key)) {
      final Map<dynamic, dynamic> cached = box.get(key);
      return cached.map(
        (k, v) => MapEntry(k as int, (v as List).cast<String>()),
      );
    }

    final data = await _loadData();
    final book = (data['BIBLEBOOK'] as List<dynamic>).firstWhere(
      (b) => b['book_name'] == bookName,
      orElse: () => null,
    );

    if (book == null) return {};

    final Map<int, List<String>> result = {};
    final chapters = book['CHAPTER'] as List<dynamic>;

    for (var c in chapters) {
      final chapterNum = int.parse(c['chapter_number']);
      final verses = c['VERSES'] as List<dynamic>;
      result[chapterNum] =
          verses
              .map((v) => '${v['verse_number']}. ${v['verse_text']}')
              .toList();
    }

    await box.put(key, result);
    return result;
  }
}
