import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:bible/providers/language_provider.dart';
import 'package:bible/providers/bible_provider.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/bible_constants.dart';
import '../utils/bible_utils.dart';
import '../widgets/bible_book_list.dart';
import '../widgets/bible_search_bar.dart';
import 'settings_page.dart';
import 'highlights_page.dart';
import '../theme.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  String _searchQuery = '';
  bool _isSearchExpanded = false;
  bool? _lastIsSwahili;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isSwahili = Provider.of<LanguageProvider>(context).isSwahili;
    if (_lastIsSwahili != isSwahili) {
      _lastIsSwahili = isSwahili;
      // Defer the provider call to the next frame to avoid build conflicts
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<BibleProvider>(context, listen: false).loadBooks(isSwahili);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final isSwahili = languageProvider.isSwahili;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final oldTestamentOrder =
        isSwahili
            ? BibleConstants.oldTestamentOrderSw
            : BibleConstants.oldTestamentOrderEn;
    final newTestamentOrder =
        isSwahili
            ? BibleConstants.newTestamentOrderSw
            : BibleConstants.newTestamentOrderEn;
    final bibleProvider = Provider.of<BibleProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // Allow gradient to show behind status bar
      backgroundColor: theme.scaffoldBackgroundColor,
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
            // Main content
            CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  snap: true,
                  backgroundColor: theme.scaffoldBackgroundColor.withValues(
                    alpha: 0.95,
                  ),
                  surfaceTintColor: Colors.transparent,
                  expandedHeight: MediaQuery.of(context).padding.top + 80.0,
                  toolbarHeight: 0.0,
                  automaticallyImplyLeading: false,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        theme.brightness == Brightness.dark
                            ? Brightness.light
                            : Brightness.dark,
                    statusBarBrightness: theme.brightness,
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.scaffoldBackgroundColor,
                            theme.scaffoldBackgroundColor.withValues(
                              alpha: 0.8,
                            ),
                          ],
                        ),
                      ),
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
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isSwahili ? 'NENO LA' : 'WORD OF',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 4.0,
                                            color: colorScheme.onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                    ),
                                    Text(
                                      isSwahili ? 'MUNGU' : 'GOD',
                                      style: AppTheme.bodyStyle.copyWith(
                                        // Playfair Display
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                        color: colorScheme.onSurface,
                                        height: 1.1,
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.bookmark_outline_rounded,
                                        color: colorScheme.onSurface,
                                        size: 30,
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
                                        color: colorScheme.onSurface,
                                        size: 30,
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
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _StickyHeaderDelegate(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor.withValues(
                          alpha: 0.95,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.scaffoldBackgroundColor,
                            blurRadius: 4,
                            spreadRadius: 2,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: _buildColumnHeader(
                              context,
                              isSwahili ? 'Agano Kale' : 'Old Testament',
                            ),
                          ),
                          Container(
                            width: 1,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.transparent,
                          ),
                          Expanded(
                            child: _buildColumnHeader(
                              context,
                              isSwahili ? 'Agano Jipya' : 'New Testament',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      if (bibleProvider.isLoading) {
                        return Padding(
                          padding: const EdgeInsets.only(
                            top: 8.0,
                            left: 8.0,
                            right: 8.0,
                          ),
                          child: _buildShimmerLoading(context),
                        );
                      }

                      if (bibleProvider.error != null) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.cloud_off_rounded,
                                  size: 48,
                                  color: colorScheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  isSwahili
                                      ? 'Kosa la kupakua vitabu'
                                      : 'Error loading books',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    bibleProvider.loadBooks(isSwahili);
                                  },
                                  icon: const Icon(Icons.refresh),
                                  label: Text(
                                    isSwahili ? 'Jaribu Tena' : 'Retry',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final allBooks = bibleProvider.books;
                      if (allBooks.isEmpty) {
                        return SizedBox(
                          height: 200,
                          child: Center(
                            child: Text(
                              isSwahili
                                  ? 'Hakuna vitabu vilivyopatikana'
                                  : 'No books found',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                        );
                      }

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

                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: IntrinsicHeight(
                          key: ValueKey(_searchQuery),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: _buildBookListSection(
                                  context,
                                  '',
                                  oldTestamentBooks,
                                ),
                              ),
                              Container(
                                width: 1,
                                height: double.infinity,
                                margin: const EdgeInsets.symmetric(
                                  vertical: 20,
                                ),
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.1,
                                ),
                              ),
                              Expanded(
                                child: _buildBookListSection(
                                  context,
                                  '',
                                  newTestamentBooks,
                                ),
                              ),
                            ],
                          ),
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

            // Search Bar
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

  Widget _buildBookListSection(
    BuildContext context,
    String title,
    List<String> books,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(
          context,
        ).cardColor.withValues(alpha: 0.03), // Very subtle background
        borderRadius: BorderRadius.circular(16),
      ),
      child: BibleBookList(title: title, books: books),
    );
  }

  Widget _buildColumnHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 2,
            width: 30, // Small centered underline instead of full width
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerLoading(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.onSurface.withValues(alpha: 0.1),
      highlightColor: colorScheme.onSurface.withValues(alpha: 0.05),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildShimmerColumn()),
            Container(
              width: 1,
              height: double.infinity,
              margin: const EdgeInsets.symmetric(vertical: 20),
              color: colorScheme.onSurface.withValues(alpha: 0.1),
            ),
            Expanded(child: _buildShimmerColumn()),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerColumn() {
    return Column(
      children: List.generate(
        15,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 8.0),
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double minHeight;
  final double maxHeight;

  _StickyHeaderDelegate({
    required this.child,
    this.minHeight = 50.0,
    this.maxHeight = 50.0,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox.expand(child: child);
  }

  @override
  double get maxExtent => maxHeight;

  @override
  double get minExtent => minHeight;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}
