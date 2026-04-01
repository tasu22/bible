import 'package:flutter/material.dart';

class BibleSearchBar extends StatefulWidget {
  final Function(String) onSearchChanged;
  final bool isSwahili;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onClose;

  const BibleSearchBar({
    super.key,
    required this.onSearchChanged,
    required this.isSwahili,
    required this.isExpanded,
    required this.onToggle,
    required this.onClose,
  });

  @override
  State<BibleSearchBar> createState() => _BibleSearchBarState();
}

class _BibleSearchBarState extends State<BibleSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(BibleSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If it was collapsed from outside, clear and unfocus
    if (oldWidget.isExpanded && !widget.isExpanded) {
      _controller.clear();
      _focusNode.unfocus();
    } else if (!oldWidget.isExpanded && widget.isExpanded) {
      // If it's being expanded, request focus after a small delay to allow animation
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_focusNode.canRequestFocus) {
          _focusNode.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: widget.isExpanded ? MediaQuery.of(context).size.width - 32 : 56,
      height: 56,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color:
            widget.isExpanded
                ? Theme.of(context).colorScheme.surface
                : Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(30),
            onTap: widget.isExpanded ? null : widget.onToggle,
            child: Stack(
              children: [
                // Expanded Search Bar Content
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: widget.isExpanded ? 1.0 : 0.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 32,
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          const SizedBox(width: 8),
                          Icon(
                            Icons.search,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              focusNode: _focusNode,
                              autofocus: widget.isExpanded,
                              onChanged: widget.onSearchChanged,
                              style: Theme.of(context).textTheme.titleMedium,
                              decoration: InputDecoration(
                                hintText:
                                    widget.isSwahili
                                        ? 'Tafuta kitabu'
                                        : 'Search a Book',
                                hintStyle:
                                    Theme.of(
                                      context,
                                    ).inputDecorationTheme.hintStyle,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                            onPressed: widget.onClose,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Collapsed Search Icon (FAB state)
                if (!widget.isExpanded)
                  Center(
                    child: Icon(
                      Icons.search,
                      color: Theme.of(context).colorScheme.onSurface,
                      size: 24,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
