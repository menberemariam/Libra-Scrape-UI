// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../blocs/items/items_bloc.dart';
import '../config/app_theme.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import '../utils/responsive.dart';
import '../widgets/item_card.dart';
import '../widgets/loading_shimmer.dart';
import '../widgets/error_widget.dart';
import '../widgets/stats_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<ItemsBloc>().add(const LoadMoreItems());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> _refresh() async {
    final bloc = context.read<ItemsBloc>();
    bloc.add(const RefreshItems());
    await bloc.stream
        .firstWhere((state) => state is ItemsLoaded || state is ItemsError)
        .timeout(
          const Duration(seconds: 8),
          onTimeout: () => bloc.state,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final inset = width > AppTheme.pageMaxWidth
              ? (width - AppTheme.pageMaxWidth) / 2 + 28
              : Responsive.horizontalPadding(width);
          final contentWidth = width - inset * 2;

          return BlocBuilder<ItemsBloc, ItemsState>(
            builder: (context, state) {
              final List<ItemModel> items =
                  state is ItemsLoaded ? state.items : const [];
              final loaded = state is ItemsLoaded;

              return RefreshIndicator(
                onRefresh: _refresh,
                edgeOffset: 120,
                color: AppTheme.primaryColor,
                child: CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _Hero(
                        inset: inset,
                        stats: loaded
                            ? StatsCard(
                                totalItems: state.total,
                                totalBooks: items
                                    .where((item) => !item.isAudiobook)
                                    .length,
                                totalAudiobooks: items
                                    .where((item) => item.isAudiobook)
                                    .length,
                              )
                            : null,
                        showPreviewBadge: ApiService.demoMode,
                        onSearch: () => context.push('/search'),
                        onRefresh: _refresh,
                      ),
                    ),
                    if (state is ItemsLoading)
                      const SliverToBoxAdapter(child: LoadingShimmer()),
                    if (state is ItemsError)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 48),
                          child: CustomErrorWidget(
                            message: state.message,
                            onRetry: () => context
                                .read<ItemsBloc>()
                                .add(const LoadItems()),
                          ),
                        ),
                      ),
                    if (state is ItemsLoaded) ...[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(inset, 24, inset, 0),
                          child: _SectionHeader(
                            title: 'New arrivals',
                            subtitle:
                                '${state.total} titles in the free collection',
                            onBrowse: () => context.push('/search'),
                          ),
                        ),
                      ),
                      if (state.items.isEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 56),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.auto_stories_outlined,
                                  size: 42,
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'The shelves are empty for now',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        SliverPadding(
                          padding: EdgeInsets.fromLTRB(
                            inset,
                            16,
                            inset,
                            8,
                          ),
                          sliver: SliverGrid(
                            gridDelegate: Responsive.gridDelegate(
                              width: contentWidth,
                            ),
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (index >= state.items.length) {
                                  return const Center(
                                    child: SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                }

                                final item = state.items[index];
                                return AnimationConfiguration.staggeredGrid(
                                  position: index,
                                  duration:
                                      const Duration(milliseconds: 320),
                                  columnCount: Responsive.gridColumns(
                                    contentWidth,
                                  ),
                                  child: ScaleAnimation(
                                    scale: 0.97,
                                    child: FadeInAnimation(
                                      child: ItemCard(
                                        item: item,
                                        onTap: () =>
                                            context.push('/item/${item.id}'),
                                      ),
                                    ),
                                  ),
                                );
                              },
                              childCount: state.items.length +
                                  (state.hasReachedMax ? 0 : 1),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(inset, 24, inset, 36),
                          child: _FooterNote(
                            hasReachedMax: state.hasReachedMax,
                          ),
                        ),
                      ),
                    ] else
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 60),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  final double inset;
  final Widget? stats;
  final bool showPreviewBadge;
  final VoidCallback onSearch;
  final Future<void> Function() onRefresh;

  const _Hero({
    required this.inset,
    required this.stats,
    required this.showPreviewBadge,
    required this.onSearch,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.brandGradient,
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.28),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(34),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -90,
              right: -70,
              child: _Glow(
                size: 260,
                color: AppTheme.accentColor.withValues(alpha: 0.22),
              ),
            ),
            Positioned(
              bottom: -120,
              left: -80,
              child: _Glow(
                size: 300,
                color: const Color(0xFF818CF8).withValues(alpha: 0.28),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(inset, topPadding + 16, inset, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: const Icon(
                          Icons.local_library_rounded,
                          color: Color(0xFFFCD34D),
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Libra',
                            style: TextStyle(
                              fontFamily: 'Fraunces',
                              fontSize: 21,
                              height: 1.05,
                              fontWeight: FontWeight.w600,
                              letterSpacing: -0.2,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'FREE DIGITAL LIBRARY',
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.6,
                              color: Colors.white.withValues(alpha: 0.58),
                            ),
                          ),
                        ],
                      ),
                      if (showPreviewBadge) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: AppTheme.accentColor.withValues(
                                alpha: 0.45,
                              ),
                            ),
                          ),
                          child: const Text(
                            'PREVIEW',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      _GlassButton(
                        icon: Icons.refresh_rounded,
                        tooltip: 'Refresh catalogue',
                        onTap: onRefresh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontFamily: 'Fraunces',
                        fontSize: Responsive.isCompact(context) ? 34 : 40,
                        height: 1.12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.7,
                        color: Colors.white,
                      ),
                      children: [
                        const TextSpan(text: 'Find your next\n'),
                        TextSpan(
                          text: 'favorite book.',
                          style: TextStyle(
                            color: AppTheme.accentColor.withValues(
                              alpha: 0.95,
                            ),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 400),
                    child: Text(
                      'Thousands of classic books and audiobooks — free to '
                      'read, listen and keep.',
                      style: TextStyle(
                        fontSize: 13.5,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  _SearchPill(onTap: onSearch, scheme: scheme),
                  if (stats != null) ...[
                    const SizedBox(height: 16),
                    stats!,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchPill extends StatelessWidget {
  final VoidCallback onTap;
  final ColorScheme scheme;

  const _SearchPill({required this.onTap, required this.scheme});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 52,
          padding: const EdgeInsets.only(left: 16, right: 6),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.search_rounded, size: 20, color: scheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Search titles, authors or genres',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: scheme.onSurfaceVariant.withValues(alpha: 0.9),
                  ),
                ),
              ),
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: scheme.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _GlassButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 24,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, size: 18, color: Colors.white),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onBrowse;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onBrowse,
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
            padding: const EdgeInsets.symmetric(horizontal: 10),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Browse all'),
              SizedBox(width: 2),
              Icon(Icons.arrow_forward_rounded, size: 15),
            ],
          ),
        ),
      ],
    );
  }
}

class _FooterNote extends StatelessWidget {
  final bool hasReachedMax;

  const _FooterNote({required this.hasReachedMax});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = hasReachedMax
        ? 'Public-domain works, curated with care.'
        : 'Loading more titles…';

    return Column(
      children: [
        Container(
          width: 36,
          height: 3,
          decoration: BoxDecoration(
            color: theme.colorScheme.outline,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
