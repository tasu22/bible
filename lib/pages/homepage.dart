import 'package:bible/models/strong_bible_services.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bible/providers/language_provider.dart';

import '../models/swahili_bible_service.dart';
import '../constants/bible_constants.dart';
import '../utils/bible_utils.dart';
import '../widgets/bible_book_list.dart';
import '../widgets/bible_search_bar.dart';
import 'settings_page.dart';
import 'highlights_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _searchQuery = '';
  bool _isSearchExpanded = false; // Initially collapsed (FAB)
  late Future<List<String>> _booksFuture;
  bool? _lastIsSwahili;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isSwahili = Provider.of<LanguageProvider>(context).isSwahili;
    if (_lastIsSwahili != isSwahili) {
      _lastIsSwahili = isSwahili;
      _booksFuture =
          isSwahili
              ? SwahiliBibleService.getBookNames()
              : StrongBibleService.getBookNames();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isSwahili = Provider.of<LanguageProvider>(context).isSwahili;

    final oldTestamentOrder =
        isSwahili
            ? BibleConstants.oldTestamentOrderSw
            : BibleConstants.oldTestamentOrderEn;
    final newTestamentOrder =
        isSwahili
            ? BibleConstants.newTestamentOrderSw
            : BibleConstants.newTestamentOrderEn;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          if (_isSearchExpanded && _searchQuery.isEmpty) {
            setState(() {
              _isSearchExpanded = false;
            });
          }
        },
        child: Stack(
          children: [
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  primary: true,
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: MediaQuery.of(context).padding.top + 20.0,
                  toolbarHeight: 0.0,
                  automaticallyImplyLeading: false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        Theme.of(context).brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    statusBarBrightness: Theme.of(context).brightness,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 8.0,
                          left: 16.0,
                          right: 16.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isSwahili ? 'BIBLIA' : 'BIBLE',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.copyWith(
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2.0,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.bookmark_outline_rounded,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                        size: 34,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) =>
                                                    const HighlightsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.settings,
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.onSurface,
                                        size: 34,
                                      ),
                                      onPressed: () {
                                        HapticFeedback.mediumImpact();
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (context) => SettingsPage(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: FutureBuilder<List<String>>(
                    future: _booksFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(
                          height: 100,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      } else if (snapshot.hasError) {
                        return SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              isSwahili
                                  ? 'Kosa la kupakua vitabu'
                                  : 'Error loading books',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(
                          height: 100,
                          child: Center(
                            child: Text(
                              isSwahili
                                  ? 'Hakuna vitabu vilivyopatikana'
                                  : 'No books found',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }

                      final allBooks = snapshot.data!;

                      // Filter books by search query
                      List<String> filteredBooks = allBooks;
                      if (_searchQuery.isNotEmpty) {
                        filteredBooks =
                            allBooks
                                .where(
                                  (b) => b.toLowerCase().contains(_searchQuery),
                                )
                                .toList();
                      }

                      final oldTestamentBooks = BibleUtils.orderBooks(
                        filteredBooks
                            .where((b) => oldTestamentOrder.contains(b))
                            .toList(),
                        oldTestamentOrder,
                      );
                      final newTestamentBooks = BibleUtils.orderBooks(
                        filteredBooks
                            .where((b) => newTestamentOrder.contains(b))
                            .toList(),
                        newTestamentOrder,
                      );

                      return IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: BibleBookList(
                                title:
                                    isSwahili ? 'Agano Kale' : 'Old Testament',
                                books: oldTestamentBooks,
                              ),
                            ),
                            VerticalDivider(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.3),
                              thickness: 1,
                              width: 32,
                              indent: 20,
                              endIndent: 20,
                            ),
                            Expanded(
                              child: BibleBookList(
                                title:
                                    isSwahili ? 'Agano Jipya' : 'New Testament',
                                books: newTestamentBooks,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 100), // Space for floating bar
                ),
              ],
            ),
            Positioned(
              bottom: 32,
              right: 16,
              child: BibleSearchBar(
                isExpanded: _isSearchExpanded,
                isSwahili: isSwahili,
                onSearchChanged: (value) {
                  setState(() {
                    _searchQuery = value.trim().toLowerCase();
                  });
                },
                onToggle: () {
                  HapticFeedback.mediumImpact();
                  setState(() {
                    _isSearchExpanded = true;
                  });
                },
                onClose: () {
                  setState(() {
                    _isSearchExpanded = false;
                    _searchQuery = '';
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
