import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/highlights_provider.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../models/highlight.dart';
import '../theme.dart';
import 'book_page.dart';
import '../constants/bible_constants.dart';
import '../widgets/highlight_card.dart';
import '../widgets/add_note_sheet.dart';

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
      body: highlights.isEmpty
          ? _buildEmptyState(context, isSwahili)
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: highlights.length,
              itemBuilder: (context, index) {
                final highlight = highlights[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: HighlightCard(
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
                          builder: (context) => BookPage(
                            bookName: BibleConstants.getBookName(
                              highlight.bookName,
                              isSwahili,
                            ),
                          ),
                        ),
                      );
                    },
                    onNote: () => AddNoteSheet.show(
                      context,
                      highlight: highlight,
                      provider: highlightsProvider,
                      isSwahili: isSwahili,
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
}
