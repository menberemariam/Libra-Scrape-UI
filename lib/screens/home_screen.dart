// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../blocs/items/items_bloc.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120,
            floating: true,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'LibraScrape',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              centerTitle: false,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.go('/search'),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => context.read<ItemsBloc>().add(const RefreshItems()),
              ),
            ],
          ),
          BlocBuilder<ItemsBloc, ItemsState>(
            builder: (context, state) {
              if (state is ItemsLoading) {
                return const SliverToBoxAdapter(
                  child: LoadingShimmer(),
                );
              }

              if (state is ItemsError) {
                return SliverToBoxAdapter(
                  child: CustomErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<ItemsBloc>().add(const LoadItems()),
                  ),
                );
              }

              if (state is ItemsLoaded) {
                return SliverList(
                  delegate: SliverChildListDelegate([
                    // Stats Section
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: StatsCard(
                        totalItems: state.total,
                        totalBooks: state.items.where((item) => !item.isAudiobook).length,
                        totalAudiobooks: state.items.where((item) => item.isAudiobook).length,
                      ),
                    ),
                    
                    // Items Grid
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: AnimationLimiter(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: state.items.length + (state.hasReachedMax ? 0 : 1),
                          itemBuilder: (context, index) {
                            if (index >= state.items.length) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            return AnimationConfiguration.staggeredGrid(
                              position: index,
                              duration: const Duration(milliseconds: 375),
                              columnCount: 2,
                              child: ScaleAnimation(
                                child: FadeInAnimation(
                                  child: ItemCard(
                                    item: state.items[index],
                                    onTap: () => context.go('/item/${state.items[index].id}'),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 80),
                  ]),
                );
              }

              return const SliverToBoxAdapter(
                child: SizedBox.shrink(),
              );
            },
          ),
        ],
      ),
    );
  }
}