import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/highlight.dart';
import '../providers/highlights_provider.dart';
import '../constants/bible_constants.dart';

class AddNoteSheet extends StatefulWidget {
  final Highlight highlight;
  final HighlightsProvider provider;
  final bool isSwahili;

  const AddNoteSheet({
    super.key,
    required this.highlight,
    required this.provider,
    required this.isSwahili,
  });

  static void show(
    BuildContext context, {
    required Highlight highlight,
    required HighlightsProvider provider,
    required bool isSwahili,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder:
          (context) => AddNoteSheet(
            highlight: highlight,
            provider: provider,
            isSwahili: isSwahili,
          ),
    );
  }

  @override
  State<AddNoteSheet> createState() => _AddNoteSheetState();
}

class _AddNoteSheetState extends State<AddNoteSheet> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.highlight.note ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Header with context
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isSwahili ? 'Ongeza Maelezo' : 'Personal Note',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    Text(
                      '${BibleConstants.getBookName(widget.highlight.bookName, widget.isSwahili).toUpperCase()} ${widget.highlight.chapter}:${widget.highlight.verseNumber}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.5,
                        ),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Text Field
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.05),
              ),
            ),
            child: TextField(
              controller: _controller,
              maxLines: 4,
              minLines: 2,
              autofocus: true,
              style: theme.textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText:
                    widget.isSwahili
                        ? 'Andika mawazo yako hapa...'
                        : 'Write your thoughts/reflections here...',
                hintStyle: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(20),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Save Button
          ElevatedButton(
            onPressed: () {
              HapticFeedback.mediumImpact();
              widget.provider.updateNote(
                widget.highlight,
                _controller.text.trim(),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              shadowColor: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
            child: Text(
              widget.isSwahili ? 'Hifadhi Maelezo' : 'Save Note',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
