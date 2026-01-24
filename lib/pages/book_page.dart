import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../models/strong_bible_services.dart';
import '../models/swahili_bible_service.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/highlights_provider.dart';
import '../models/highlight.dart';

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

  Future<Map<int, List<String>>> _getFilteredVersesForChapters(
    List<int> chapters,
  ) async {
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final isSwahili = langProvider.isSwahili;

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

    return filteredMap;
  }

  @override
  Widget build(BuildContext context) {
    final langProvider = Provider.of<LanguageProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final fontSize = settingsProvider.fontSize;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              expandedHeight: 120.0,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              systemOverlayStyle: SystemUiOverlayStyle(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness:
                    Theme.of(context).brightness == Brightness.dark
                        ? Brightness.light
                        : Brightness.dark,
                statusBarBrightness: Theme.of(context).brightness,
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  widget.bookName,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                centerTitle: true,
                background: Container(color: Theme.of(context).primaryColor),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _chapterController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: langProvider.isSwahili ? 'SURA' : 'CHAPTER',
                          hintStyle:
                              Theme.of(context).inputDecorationTheme.hintStyle,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _verseController,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        decoration: InputDecoration(
                          hintText: langProvider.isSwahili ? 'MSTARI' : 'VERSE',
                          hintStyle:
                              Theme.of(context).inputDecorationTheme.hintStyle,
                          prefixIcon: Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 20,
                          ),
                          filled: true,
                          fillColor: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.1),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30.0),
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.onSurface,
                              width: 1.5,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            FutureBuilder<List<int>>(
              future: _chaptersFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Text(
                        langProvider.isSwahili
                            ? 'Hakuna hicho kitabu.'
                            : 'No chapters found.',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }

                final chapters = snapshot.data!;
                return FutureBuilder<Map<int, List<String>>>(
                  future: _getFilteredVersesForChapters(chapters),
                  builder: (context, filteredSnapshot) {
                    if (!filteredSnapshot.hasData) {
                      return SliverFillRemaining(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      );
                    }

                    final filteredMap = filteredSnapshot.data!;
                    final visibleChapters =
                        chapters
                            .where((c) => filteredMap[c]!.isNotEmpty)
                            .toList();

                    if (visibleChapters.isEmpty) {
                      return SliverFillRemaining(
                        child: Center(
                          child: Text(
                            langProvider.isSwahili
                                ? 'Hakuna hicho kitabu.'
                                : 'No results found.',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
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
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: fontSize + 2,
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

                                // Extract verse number and text
                                final match = RegExp(
                                  r'^(\d+)\.\s*(.*)',
                                  dotAll: true,
                                ).firstMatch(cleanText);
                                final verseNum = match?.group(1) ?? '';
                                final verseContent =
                                    match?.group(2) ?? cleanText;

                                return Consumer<HighlightsProvider>(
                                  builder: (
                                    context,
                                    highlightsProvider,
                                    child,
                                  ) {
                                    final isHighlighted = highlightsProvider
                                        .isHighlighted(
                                          widget.bookName,
                                          chapter,
                                          verseNum,
                                          langProvider.isSwahili,
                                        );

                                    return GestureDetector(
                                      onLongPress: () {
                                        HapticFeedback.heavyImpact();
                                        highlightsProvider.toggleHighlight(
                                          Highlight(
                                            bookName: widget.bookName,
                                            chapter: chapter,
                                            verseNumber: verseNum,
                                            verseText: verseContent,
                                            isSwahili: langProvider.isSwahili,
                                          ),
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              isHighlighted
                                                  ? (langProvider.isSwahili
                                                      ? 'Mstari umeondolewa'
                                                      : 'Verse removed')
                                                  : (langProvider.isSwahili
                                                      ? 'Mstari umepigiwa mstari'
                                                      : 'Verse highlighted'),
                                            ),
                                            duration: const Duration(
                                              seconds: 1,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        color:
                                            isHighlighted
                                                ? const Color(
                                                  0xFFFFD700,
                                                ).withValues(alpha: 0.2)
                                                : Colors.transparent,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 8.0,
                                          horizontal: 24.0,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if (verseNum.isNotEmpty) ...[
                                              SizedBox(
                                                width: 30,
                                                child: Text(
                                                  verseNum,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .titleSmall
                                                      ?.copyWith(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .onSurface
                                                            .withValues(
                                                              alpha: 0.7,
                                                            ),
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 14,
                                                      ),
                                                  textAlign: TextAlign.end,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                            ],
                                            Expanded(
                                              child: Text(
                                                verseContent,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .onSurface,
                                                      fontSize: fontSize,
                                                      height: 1.6,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }),
                            ],
                          ),
                        );
                      }, childCount: visibleChapters.length),
                    );
                  },
                );
              },
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.of(context).padding.bottom + 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
