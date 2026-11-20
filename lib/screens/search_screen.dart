// lib/screens/search_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../blocs/search/search_bloc.dart';
import '../models/search_filters.dart';
import '../models/item_model.dart';
import '../utils/responsive.dart';
import '../widgets/item_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';
import '../widgets/filter_chips.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  SearchFilters _currentFilters = SearchFilters();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<SearchBloc>().add(LoadMoreSearchResults());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _onSearch() {
    final query = _searchController.text.trim();
    final filters = _currentFilters.copyWith(query: query);
    _currentFilters = filters;

    if (filters.hasActiveFilters) {
      context.read<SearchBloc>().add(SearchItems(filters));
    } else {
      context.read<SearchBloc>().add(ClearSearch());
    }
  }

  void _onQueryChanged(String _) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), _onSearch);
  }

  void _clear() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {});
    _onSearch();
  }

  void _reset() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _currentFilters = SearchFilters();
    });
    context.read<SearchBloc>().add(ClearSearch());
  }

  void _onFiltersChanged(SearchFilters filters) {
    setState(() {
      _currentFilters = filters.copyWith(query: _searchController.text.trim());
    });
    context.read<SearchBloc>().add(UpdateFilters(_currentFilters));
  }

  void _applySuggestion({ItemType? type, String? genre}) {
    setState(() {
      _currentFilters = _currentFilters.copyWith(
        type: type,
        genre: genre,
        query: _searchController.text.trim(),
      );
    });
    context.read<SearchBloc>().add(SearchItems(_currentFilters));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final pad = Responsive.horizontalPadding(constraints.maxWidth);

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 14, pad, 0),
                      child: _Header(onBack: () => context.pop()),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(pad, 20, pad, 0),
                      child: _SearchField(
                        controller: _searchController,
                        onChanged: _onQueryChanged,
                        onSubmitted: (_) {
                          _debounce?.cancel();
                          _onSearch();
                        },
                        onClear: _clear,
                      ),
                    ),
                    const SizedBox(height: 14),
                    FilterChips(
                      currentFilters: _currentFilters,
                      onFiltersChanged: _onFiltersChanged,
                      horizontalPadding: pad,
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: BlocBuilder<SearchBloc, SearchState>(
                        builder: (context, state) {
                          if (state is SearchLoading) {
                            return const LoadingShimmer();
                          }

                          if (state is SearchError) {
                            return CustomErrorWidget(
                              message: state.message,
                              onRetry: _onSearch,
                            );
                          }

                          if (state is SearchLoaded) {
                            if (state.items.isEmpty) {
                              return _NoResults(onReset: _reset);
                            }
                            return _Results(
                              state: state,
                              pad: pad,
                              contentWidth: constraints.maxWidth - pad * 2,
                              scrollController: _scrollController,
                              onReset: _reset,
                            );
                          }

                          return _EmptyState(
                            onSuggestion: _applySuggestion,
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        _RoundIconButton(icon: Icons.arrow_back_rounded, onTap: onBack),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Search', style: theme.textTheme.headlineSmall),
            Text(
              'The whole collection, one field',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface,
      shape: CircleBorder(side: BorderSide(color: scheme.outline)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: scheme.onSurface),
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onClear;

  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onSubmitted,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: false,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: 'Search by title, author or genre',
        prefixIcon: const Icon(Icons.search_rounded, size: 21),
        suffixIcon: controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: onClear,
              ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
    );
  }
}

class _Results extends StatelessWidget {
  final SearchLoaded state;
  final double pad;
  final double contentWidth;
  final ScrollController scrollController;
  final VoidCallback onReset;

  const _Results({
    required this.state,
    required this.pad,
    required this.contentWidth,
    required this.scrollController,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(pad, 4, pad, 12),
            child: Row(
              children: [
                Text(
                  '${state.total} ${state.total == 1 ? 'title' : 'titles'}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontSize: 12.5,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: onReset,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(0, 32),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  child: const Text(
                    'Clear filters',
                    style: TextStyle(fontSize: 12.5),
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(pad, 0, pad, 8),
          sliver: SliverGrid(
            gridDelegate: Responsive.gridDelegate(width: contentWidth),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= state.items.length) {
                  return const Center(
                    child: SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                }

                final item = state.items[index];
                return AnimationConfiguration.staggeredGrid(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  columnCount: Responsive.gridColumns(contentWidth),
                  child: ScaleAnimation(
                    scale: 0.97,
                    child: FadeInAnimation(
                      child: ItemCard(
                        item: item,
                        onTap: () => context.push('/item/${item.id}'),
                      ),
                    ),
                  ),
                );
              },
              childCount: state.items.length + (state.hasReachedMax ? 0 : 1),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 28)),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final void Function({ItemType? type, String? genre}) onSuggestion;

  const _EmptyState({required this.onSuggestion});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  scheme.primaryContainer,
                  scheme.secondaryContainer.withValues(alpha: 0.6),
                ],
              ),
            ),
            child: Icon(
              Icons.travel_explore_rounded,
              size: 34,
              color: scheme.primary,
            ),
          ),
          const SizedBox(height: 20),
          Text('Discover your next read', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Text(
              'Search the free collection by title, author or genre — results '
              'update as you type.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('TRY A GENRE', style: theme.textTheme.labelSmall),
          const SizedBox(height: 10),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _SuggestionPill(
                label: 'Mystery',
                icon: Icons.search_rounded,
                onTap: () => onSuggestion(genre: 'Mystery'),
              ),
              _SuggestionPill(
                label: 'Philosophy',
                icon: Icons.psychology_alt_outlined,
                onTap: () => onSuggestion(genre: 'Philosophy'),
              ),
              _SuggestionPill(
                label: 'Audiobooks',
                icon: Icons.headphones_rounded,
                onTap: () => onSuggestion(type: ItemType.audiobook),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _SuggestionPill({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 15),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        backgroundColor: scheme.surface,
        minimumSize: const Size(0, 38),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  final VoidCallback onReset;

  const _NoResults({required this.onReset});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text('No matching titles', style: theme.textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(
              'Try a shorter query, or remove a filter.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: onReset,
              icon: const Icon(Icons.restart_alt_rounded, size: 18),
              label: const Text('Reset search'),
            ),
          ],
        ),
      ),
    );
  }
}
