import '../providers/language_provider.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/strong_bible_services.dart';
import '../models/swahili_bible_service.dart';

class _VerseListSkeleton extends StatelessWidget {
  final int count;
  const _VerseListSkeleton({this.count = 5});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 32.0),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 24,
                color: Colors.white.withAlpha(51),
                margin: const EdgeInsets.only(right: 8.0, top: 2.0),
              ),
              Expanded(
                child: Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(51),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class BookPage extends StatefulWidget {
  final String bookName;

  const BookPage({super.key, required this.bookName});

  @override
  State<BookPage> createState() => _BookPageState();
}

class _BookPageState extends State<BookPage> {
  late Future<List<int>> _chaptersFuture = Future.value(
    [],
  ); // <-- Add this default
  final TextEditingController _chapterController = TextEditingController();
  final TextEditingController _verseController = TextEditingController();
  String _chapterQuery = '';
  String _verseQuery = '';

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Delay using context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final langProvider = Provider.of<LanguageProvider>(
        context,
        listen: false,
      );
      setState(() {
        _chaptersFuture =
            langProvider.isSwahili
                ? SwahiliBibleService.getChapters(widget.bookName)
                : StrongBibleService.getChaptersForBook(widget.bookName);
      });
    });

    _chapterController.addListener(_onSearchChanged);
    _verseController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _chapterQuery = _chapterController.text.trim();
        _verseQuery = _verseController.text.trim();
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _chapterController.dispose();
    _verseController.dispose();
    super.dispose();
  }

  bool _verseMatches(String verse, int chapter) {
    if (_chapterQuery.isEmpty && _verseQuery.isEmpty) return true;

    if (_chapterQuery.isNotEmpty && _verseQuery.isEmpty) {
      return chapter.toString() == _chapterQuery;
    }

    if (_chapterQuery.isNotEmpty && _verseQuery.isNotEmpty) {
      if (chapter.toString() != _chapterQuery) return false;
      final verseNumMatch = RegExp(r'^(\d+)\.').firstMatch(verse);
      return verseNumMatch != null && verseNumMatch.group(1) == _verseQuery;
    }

    if (_chapterQuery.isEmpty && _verseQuery.isNotEmpty) {
      final verseNumMatch = RegExp(r'^(\d+)\.').firstMatch(verse);
      return verseNumMatch != null && verseNumMatch.group(1) == _verseQuery;
    }

    return false;
  }

  // Simple in-memory cache for filtered verses
  final Map<String, Map<int, List<String>>> _filteredVersesCache = {};

  Future<Map<int, List<String>>> _getFilteredVersesForChapters(
    List<int> chapters,
  ) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSwahili = langProvider.isSwahili;
    final cacheKey =
        '${widget.bookName}|${isSwahili ? 'sw' : 'en'}|$_chapterQuery|$_verseQuery';
    if (_filteredVersesCache.containsKey(cacheKey)) {
      return _filteredVersesCache[cacheKey]!;
    }

    final Map<int, List<String>> filteredMap = {};

    for (final chapter in chapters) {
      List<String> verses;

      if (isSwahili) {
        final verseObjs = await SwahiliBibleService.getVerses(
          widget.bookName,
          chapter,
        );
        verses =
            verseObjs
                .map((v) => '${v['verse_number']}. ${v['verse_text']}')
                .toList();
      } else {
        verses = await StrongBibleService.getVersesForBookChapter(
          widget.bookName,
          chapter,
        );
      }

      if (_chapterQuery.isNotEmpty &&
          _verseQuery.isEmpty &&
          chapter.toString() == _chapterQuery) {
        filteredMap[chapter] = verses;
      } else {
        final filteredVerses =
            verses.where((v) => _verseMatches(v, chapter)).toList();
        filteredMap[chapter] = filteredVerses;
      }
    }

    _filteredVersesCache[cacheKey] = filteredMap;
    return filteredMap;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1D503A),
      appBar: AppBar(
        title: Text(widget.bookName),
        backgroundColor: const Color(0xFF1D503A),
        foregroundColor: const Color(0xFFFAF5EE),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _chapterController,
                      style: const TextStyle(color: Color(0xFFFAF5EE)),
                      decoration: InputDecoration(
                        hintText:
                            langProvider.isSwahili
                                ? 'S U R A'
                                : 'C H A P T E R',
                        hintStyle: const TextStyle(color: Color(0xFFFAF5EE)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFFAF5EE),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1D503A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFAF5EE),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFAF5EE),
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  Expanded(
                    child: TextField(
                      controller: _verseController,
                      style: const TextStyle(color: Color(0xFFFAF5EE)),
                      decoration: InputDecoration(
                        hintText:
                            langProvider.isSwahili
                                ? 'M S T A R I'
                                : 'V E R S E',
                        hintStyle: const TextStyle(color: Color(0xFFFAF5EE)),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFFFAF5EE),
                        ),
                        filled: true,
                        fillColor: const Color(0xFF1D503A),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFAF5EE),
                            width: 2.0,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: Color(0xFFFAF5EE),
                            width: 2.0,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FutureBuilder<List<int>>(
                future: _chaptersFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFAF5EE),
                      ),
                    );
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(
                        langProvider.isSwahili
                            ? 'Hakuna hicho kitabu.'
                            : 'No chapters found.',
                        style: const TextStyle(color: Color(0xFFFAF5EE)),
                      ),
                    );
                  }

                  final chapters = snapshot.data!;

                  return FutureBuilder<Map<int, List<String>>>(
                    future: _getFilteredVersesForChapters(chapters),
                    builder: (context, filteredSnapshot) {
                      if (!filteredSnapshot.hasData) {
                        // Show skeletons for each chapter
                        return ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: chapters.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16.0,
                                      vertical: 8.0,
                                    ),
                                    child: Container(
                                      width: 120,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withAlpha(51),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                  const _VerseListSkeleton(count: 5),
                                ],
                              ),
                            );
                          },
                        );
                      }

                      final filteredMap = filteredSnapshot.data!;
                      final visibleChapters =
                          chapters
                              .where((c) => filteredMap[c]!.isNotEmpty)
                              .toList();

                      if (visibleChapters.isEmpty) {
                        return Center(
                          child: Text(
                            langProvider.isSwahili
                                ? 'Hakuna hicho kitabu.'
                                : 'No results found.',
                            style: const TextStyle(color: Color(0xFFFAF5EE)),
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        itemCount: visibleChapters.length,
                        itemBuilder: (context, index) {
                          final chapter = visibleChapters[index];
                          final filteredVerses = filteredMap[chapter]!;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 24.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    langProvider.isSwahili
                                        ? 'Sura $chapter'
                                        : 'Chapter $chapter',
                                    style: const TextStyle(
                                      color: Color(0xFFFAF5EE),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                ...filteredVerses.map((v) {
                                  final cleanText =
                                      langProvider.isSwahili
                                          ? v
                                          : v
                                              .replaceAll(
                                                RegExp(r'\{[^}]*\}'),
                                                '',
                                              )
                                              .replaceAll('  ', ' ')
                                              .trim();

                                  return Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 2.0,
                                      horizontal: 32.0,
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 3,
                                          height: 24,
                                          color: const Color(0xFFFAF5EE),
                                          margin: const EdgeInsets.only(
                                            right: 8.0,
                                            top: 2.0,
                                          ),
                                        ),
                                        Expanded(
                                          child: Text(
                                            cleanText,
                                            style: const TextStyle(
                                              color: Color(0xFFFAF5EE),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
