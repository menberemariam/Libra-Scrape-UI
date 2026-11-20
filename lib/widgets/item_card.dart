// lib/widgets/item_card.dart
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import '../config/app_theme.dart';
import 'book_cover.dart';

class ItemCard extends StatefulWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _hovered
                ? scheme.primary.withValues(alpha: 0.28)
                : scheme.outline,
          ),
          boxShadow: [
            BoxShadow(
              color: scheme.shadow.withValues(
                alpha: _hovered ? 0.16 : 0.06,
              ),
              blurRadius: _hovered ? 22 : 10,
              offset: Offset(0, _hovered ? 10 : 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: BookCover(
                      title: widget.item.title,
                      author: widget.item.author,
                      isAudiobook: widget.item.isAudiobook,
                      imageUrl: widget.item.coverUrl,
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(5, 9, 5, 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontSize: 13,
                              height: 1.25,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.item.author,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 11.5,
                            ),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: scheme.primaryContainer
                                        .withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    widget.item.primaryGenre,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 0.2,
                                      color: scheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                widget.item.isAudiobook
                                    ? Icons.headphones_rounded
                                    : Icons.auto_stories_outlined,
                                size: 13,
                                color: AppTheme.mutedColor,
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
        ),
      ),
    );
  }
}
