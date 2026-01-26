import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/highlights_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../models/highlight.dart';
import '../theme.dart';
import 'book_page.dart';
import '../constants/bible_constants.dart';
import '../models/swahili_bible_service.dart';
import '../models/strong_bible_services.dart';

class HighlightsPage extends StatelessWidget {
  const HighlightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final highlightsProvider = Provider.of<HighlightsProvider>(context);
    final langProvider = Provider.of<LanguageProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isSwahili = langProvider.isSwahili;
    final List<Highlight> highlights = highlightsProvider.highlights;
    final fontSize = settingsProvider.fontSize;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isSwahili ? 'MISTARI PENDWA' : 'HIGHLIGHTS',
          style: theme.appBarTheme.titleTextStyle?.copyWith(
            letterSpacing: 3,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body:
          highlights.isEmpty
              ? _buildEmptyState(context, isSwahili)
              : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: highlights.length,
                itemBuilder: (context, index) {
                  final highlight = highlights[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _HighlightCard(
                      highlight: highlight,
                      fontSize: fontSize,
                      isSwahili: isSwahili,
                      onDelete: () {
                        highlightsProvider.toggleHighlight(highlight);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => BookPage(
                                  bookName: BibleConstants.getBookName(
                                    highlight.bookName,
                                    isSwahili,
                                  ),
                                ),
                          ),
                        );
                      },
                      onNote:
                          () => _showNoteDialog(
                            context,
                            highlight,
                            highlightsProvider,
                            isSwahili,
                          ),
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isSwahili) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.03),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 64,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.2),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              isSwahili ? 'Hakuna Kilichohifadhiwa' : 'No Highlights Yet',
              style: AppTheme.titleStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isSwahili
                  ? 'Mistari unayopenda itaonekana hapa. Anza kusoma na weka alama mistari unayopenda.'
                  : 'Verses you highlight will appear here. Start reading and mark passages that speak to you.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.5),
                fontSize: 15,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 48),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.2),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Text(
                isSwahili ? 'ANZA KUSOMA' : 'START READING',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: 2,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDialog(
    BuildContext context,
    Highlight highlight,
    HighlightsProvider provider,
    bool isSwahili,
  ) {
    final controller = TextEditingController(text: highlight.note ?? '');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.fromLTRB(
              24,
              24,
              24,
              MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isSwahili ? 'Ongeza Maelezo' : 'Add Note',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 3,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText:
                        isSwahili
                            ? 'Andika maelezo yako hapa...'
                            : 'Write your thoughts here...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.05),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      provider.updateNote(highlight, controller.text.trim());
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    ),
                    child: Text(isSwahili ? 'Hifadhi' : 'Save Note'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _HighlightCard extends StatelessWidget {
  final Highlight highlight;
  final double fontSize;
  final bool isSwahili;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onNote;

  const _HighlightCard({
    required this.highlight,
    required this.fontSize,
    required this.isSwahili,
    required this.onDelete,
    required this.onTap,
    required this.onNote,
  });

  Future<String> _resolveText() async {
    if (highlight.isSwahili == isSwahili) return highlight.verseText;

    try {
      final targetBook = BibleConstants.getBookName(
        highlight.bookName,
        isSwahili,
      );

      if (isSwahili) {
        final verses = await SwahiliBibleService.getVerses(
          targetBook,
          highlight.chapter,
        );
        final match = verses.firstWhere(
          (v) => v['verse_number'] == highlight.verseNumber,
          orElse: () => {},
        );
        if (match.isNotEmpty && match['verse_text'] != null) {
          return match['verse_text']!;
        }
      } else {
        final verses = await StrongBibleService.getVersesForBookChapter(
          targetBook,
          highlight.chapter,
        );
        for (var v in verses) {
          // Robust parsing for "1. Text" or "10. Text"
          final match = RegExp(r'^(\d+)\.\s+(.*)').firstMatch(v);
          if (match != null &&
              match.group(1) == highlight.verseNumber.toString()) {
            // Convert highlight.verseNumber to string for comparison
            final rawText = match.group(2) ?? v;
            // Remove Strong's numbers like {G1577}
            return rawText.replaceAll(RegExp(r'\{[^}]*\}'), '').trim();
          }
        }
      }
    } catch (e) {
      debugPrint('Error resolving verse text: $e');
    }
    // Clean potential artifacts from stored text too
    return highlight.verseText.replaceAll(RegExp(r'\{[^}]*\}'), '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final hasNote = highlight.note != null && highlight.note!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.05),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Gold accent strip
              Container(width: 4, color: const Color(0xFFFFD700)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFFFFD700,
                              ).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.format_quote_rounded,
                              size: 16,
                              color: Color(0xFFFFD700),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FutureBuilder<String>(
                                  future: _resolveText(),
                                  initialData: highlight.verseText,
                                  builder: (context, snapshot) {
                                    return Text(
                                      snapshot.data ?? highlight.verseText,
                                      style: AppTheme.bodyStyle.copyWith(
                                        fontSize: fontSize,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onSurface
                                            .withValues(alpha: 0.9),
                                        height: 1.6,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (hasNote) ...[
                        const SizedBox(height: 16),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.edit_note,
                                    size: 16,
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.7),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    isSwahili ? 'Maelezo' : 'Note',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary
                                          .withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                highlight.note!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                BibleConstants.getBookName(
                                  highlight.bookName,
                                  isSwahili,
                                ).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${isSwahili ? 'Sura' : 'Chap'} ${highlight.chapter} : ${highlight.verseNumber}',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  hasNote
                                      ? Icons.edit_note_rounded
                                      : Icons.note_add_outlined,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.7),
                                ),
                                onPressed: onNote,
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.copy_all_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                onPressed: () {
                                  Clipboard.setData(
                                    ClipboardData(
                                      text:
                                          '${highlight.verseText}\n${highlight.bookName} ${highlight.chapter}:${highlight.verseNumber}',
                                    ),
                                  );
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        isSwahili ? 'Imenakiliwa' : 'Copied',
                                      ),
                                      duration: const Duration(seconds: 1),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.7),
                                ),
                                onPressed: onDelete,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
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
