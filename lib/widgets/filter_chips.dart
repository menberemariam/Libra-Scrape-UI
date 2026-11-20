// lib/widgets/filter_chips.dart
import 'package:flutter/material.dart';
import '../models/search_filters.dart';
import '../models/item_model.dart';

class FilterChips extends StatelessWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;
  final double horizontalPadding;

  const FilterChips({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
    this.horizontalPadding = 20,
  });

  static const List<String> popularGenres = [
    'Classic Literature',
    'Mystery',
    'Romance',
    'Science Fiction',
    'Fantasy',
    'Biography',
    'History',
    'Philosophy',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              _Pill(
                label: 'All formats',
                icon: Icons.grid_view_rounded,
                selected: currentFilters.type == null,
                onTap: () =>
                    onFiltersChanged(currentFilters.copyWith(type: null)),
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'E-books',
                icon: Icons.menu_book_rounded,
                selected: currentFilters.type == ItemType.book,
                onTap: () => onFiltersChanged(
                  currentFilters.copyWith(
                    type: ItemType.book,
                    clearType: currentFilters.type == ItemType.book,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _Pill(
                label: 'Audiobooks',
                icon: Icons.headphones_rounded,
                selected: currentFilters.type == ItemType.audiobook,
                onTap: () => onFiltersChanged(
                  currentFilters.copyWith(
                    type: ItemType.audiobook,
                    clearType: currentFilters.type == ItemType.audiobook,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Row(
            children: [
              _Pill(
                label: 'All genres',
                selected: currentFilters.genre == null,
                onTap: () =>
                    onFiltersChanged(currentFilters.copyWith(genre: null)),
              ),
              ...popularGenres.map(
                (genre) => Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _Pill(
                    label: genre,
                    selected: currentFilters.genre == genre,
                    onTap: () => onFiltersChanged(
                      currentFilters.copyWith(
                        genre: genre,
                        clearGenre: currentFilters.genre == genre,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _Pill({
    required this.label,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 13),
          decoration: BoxDecoration(
            color: selected ? scheme.primary : scheme.surface,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 14,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
