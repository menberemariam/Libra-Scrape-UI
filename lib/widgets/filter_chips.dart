// lib/widgets/filter_chips.dart
import 'package:flutter/material.dart';
import '../models/search_filters.dart';
import '../models/item_model.dart';

class FilterChips extends StatelessWidget {
  final SearchFilters currentFilters;
  final Function(SearchFilters) onFiltersChanged;

  const FilterChips({
    super.key,
    required this.currentFilters,
    required this.onFiltersChanged,
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
    return Container(
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Filter
          Row(
            children: [
              Text(
                'Type: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('All'),
                selected: currentFilters.type == null,
                onSelected: (_) => onFiltersChanged(
                  currentFilters.copyWith(type: null),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Books'),
                selected: currentFilters.type == ItemType.book,
                onSelected: (_) => onFiltersChanged(
                  currentFilters.copyWith(
                    type: currentFilters.type == ItemType.book ? null : ItemType.book,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Audiobooks'),
                selected: currentFilters.type == ItemType.audiobook,
                onSelected: (_) => onFiltersChanged(
                  currentFilters.copyWith(
                    type: currentFilters.type == ItemType.audiobook ? null : ItemType.audiobook,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Genre Filter
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Genres: ',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('All Genres'),
                          selected: currentFilters.genre == null,
                          onSelected: (_) => onFiltersChanged(
                            currentFilters.copyWith(genre: null),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ...popularGenres.map((genre) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(genre),
                            selected: currentFilters.genre == genre,
                            onSelected: (_) => onFiltersChanged(
                              currentFilters.copyWith(
                                genre: currentFilters.genre == genre ? null : genre,
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}