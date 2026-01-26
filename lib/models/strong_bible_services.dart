import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../constants/bible_constants.dart';

class StrongBibleService {
  static List<dynamic>? _cachedVerses;

  static Future<List<dynamic>> _loadVerses() async {
    if (_cachedVerses != null) return _cachedVerses!;
    final String jsonString = await rootBundle.loadString(
      'assets/bibles/english.json',
    );
    _cachedVerses = await compute(_parseJson, jsonString);
    return _cachedVerses!;
  }

  static List<dynamic> _parseJson(String jsonString) {
    return json.decode(jsonString);
  }

  static Future<List<String>> getBookNames() async {
    return [
      ...BibleConstants.oldTestamentOrderEn,
      ...BibleConstants.newTestamentOrderEn,
    ];
  }

  static Future<List<int>> getChaptersForBook(String bookName) async {
    final box = Hive.box('bible_data');
    final key = 'en_chapters_$bookName';

    if (box.containsKey(key)) {
      final List<dynamic> cached = box.get(key);
      return cached.cast<int>();
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

    await box.put(key, chapters);
    return chapters;
  }

  static Future<List<String>> getVersesForBookChapter(
    String bookName,
    int chapter,
  ) async {
    final box = Hive.box('bible_data');
    final key = 'en_verses_${bookName}_$chapter';

    if (box.containsKey(key)) {
      final List<dynamic> cached = box.get(key);
      return cached.cast<String>();
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

    await box.put(key, result);
    return result;
  }

  static Future<Map<int, List<String>>> getVersesForBook(
    String bookName,
  ) async {
    final box = Hive.box('bible_data');
    final key = 'en_book_verses_$bookName';

    if (box.containsKey(key)) {
      final Map<dynamic, dynamic> cached = box.get(key);
      // specific casting to ensure correct types
      return cached.map(
        (k, v) => MapEntry(k as int, (v as List).cast<String>()),
      );
    }

    final verses = await _loadVerses();
    final Map<int, List<String>> result = {};

    // Single pass optimization
    for (var verse in verses) {
      if (verse['book_name'] == bookName) {
        final chapter = verse['chapter'] as int;
        final text = '${verse['verse']}. ${verse['text']}';
        result.putIfAbsent(chapter, () => []).add(text);
      }
    }

    await box.put(key, result);
    return result;
  }
}
