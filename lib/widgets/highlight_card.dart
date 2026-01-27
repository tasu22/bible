import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/highlight.dart';
import '../models/swahili_bible_service.dart';
import '../models/strong_bible_services.dart';
import '../constants/bible_constants.dart';
import '../theme.dart';

class HighlightCard extends StatelessWidget {
  final Highlight highlight;
  final double fontSize;
  final bool isSwahili;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final VoidCallback onNote;

  const HighlightCard({
    super.key,
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
        final match = verses.firstWhere((v) {
          final vNum = int.tryParse(v['verse_number'].toString()) ?? -1;
          final hNum = int.tryParse(highlight.verseNumber) ?? -99;
          // Fallback to string comparison if parsing fails
          if (vNum == -1 || hNum == -99) {
            return v['verse_number'].toString() == highlight.verseNumber;
          }
          return vNum == hNum;
        }, orElse: () => {});
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
          if (match != null) {
            final vNum = int.tryParse(match.group(1)!) ?? -1;
            final hNum = int.tryParse(highlight.verseNumber) ?? -99;

            final matches =
                (vNum != -1 && hNum != -99)
                    ? vNum == hNum
                    : match.group(1) == highlight.verseNumber;

            if (matches) {
              final rawText = match.group(2) ?? v;
              // Remove Strong's numbers like {G1577}
              return rawText.replaceAll(RegExp(r'\{[^}]*\}'), '').trim();
            }
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
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
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
                          Expanded(
                            child: Column(
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
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
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Made the Add Note button more prominent and explicit
                              TextButton.icon(
                                onPressed: () {
                                  HapticFeedback.mediumImpact();
                                  onNote();
                                },
                                icon: Icon(
                                  hasNote
                                      ? Icons.edit_note_rounded
                                      : Icons.note_add_rounded,
                                  size: 18,
                                ),
                                label: Text(
                                  hasNote
                                      ? (isSwahili ? 'Hariri' : 'Edit')
                                      : (isSwahili ? 'Maelezo' : 'Add Note'),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Theme.of(context).colorScheme.primary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withValues(alpha: 0.05),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: Icon(
                                  Icons.copy_all_rounded,
                                  size: 20,
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.5),
                                ),
                                onPressed: () async {
                                  await HapticFeedback.mediumImpact();
                                  if (!context.mounted) return;
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
                                constraints: const BoxConstraints(),
                                padding: const EdgeInsets.all(8),
                                icon: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.error.withValues(alpha: 0.7),
                                ),
                                onPressed: () {
                                  HapticFeedback.heavyImpact();
                                  onDelete();
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
            ],
          ),
        ),
      ),
    );
  }
}
