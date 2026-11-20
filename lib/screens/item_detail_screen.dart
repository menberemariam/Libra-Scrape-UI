// lib/screens/item_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_theme.dart';
import '../models/item_model.dart';
import '../services/api_service.dart';
import '../widgets/book_cover.dart';
import '../widgets/error_widget.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  final ApiService _apiService = ApiService();
  ItemModel? _item;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }

  Future<void> _loadItem() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final item = await _apiService.getItemById(widget.itemId);

      setState(() {
        _item = item;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the source link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _StatusScaffold(
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2.5)),
      );
    }

    if (_error != null) {
      return _StatusScaffold(
        child: CustomErrorWidget(message: _error!, onRetry: _loadItem),
      );
    }

    final item = _item;
    if (item == null) {
      return const _StatusScaffold(
        child: Center(child: Text('Item not found')),
      );
    }

    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: wide ? _wideBody(item) : _mobileBody(item),
    );
  }

  // ---------------------------------------------------------------------------
  // Mobile: immersive cover hero with a sheet that overlaps it.
  // ---------------------------------------------------------------------------
  Widget _mobileBody(ItemModel item) {
    final scheme = Theme.of(context).colorScheme;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              _CoverHero(item: item),
              Transform.translate(
                offset: const Offset(0, -26),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: scheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: EdgeInsets.fromLTRB(24, 28, 24, 40 + bottomInset),
                  child: _Details(
                    item: item,
                    onDownload: () =>
                        context.push('/download/${item.id}'),
                    onSource: () => _launchUrl(item.sourceUrl),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          top: MediaQuery.paddingOf(context).top + 10,
          left: 16,
          child: _GlassIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Desktop: two-column product layout with a proper page header.
  // ---------------------------------------------------------------------------
  Widget _wideBody(ItemModel item) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 4),
            child: Row(
              children: [
                _FlatIconButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
                const SizedBox(width: 12),
                Text(
                  'Title details',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _launchUrl(item.sourceUrl),
                  icon: const Icon(Icons.open_in_new_rounded, size: 16),
                  label: const Text('View source'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 12, 32, 48),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1040),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 300,
                        child: Column(
                          children: [
                            AspectRatio(
                              aspectRatio: 3 / 4,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: scheme.shadow
                                          .withValues(alpha: 0.22),
                                      blurRadius: 32,
                                      offset: const Offset(0, 16),
                                    ),
                                  ],
                                ),
                                child: BookCover(
                                  title: item.title,
                                  author: item.author,
                                  isAudiobook: item.isAudiobook,
                                  imageUrl: item.coverUrl,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            FilledButton.icon(
                              onPressed: () =>
                                  context.push('/download/${item.id}'),
                              icon: const Icon(Icons.download_rounded,
                                  size: 19),
                              label: const Text('Get this title'),
                              style: FilledButton.styleFrom(
                                minimumSize: const Size(double.infinity, 52),
                              ),
                            ),
                            const SizedBox(height: 10),
                            OutlinedButton.icon(
                              onPressed: () => _launchUrl(item.sourceUrl),
                              icon: const Icon(Icons.open_in_new_rounded,
                                  size: 17),
                              label: const Text('View original source'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size(double.infinity, 50),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              'Free to download and keep.',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                      Expanded(
                        child: _Details(
                          item: item,
                          hideActions: true,
                          onDownload: () =>
                              context.push('/download/${item.id}'),
                          onSource: () => _launchUrl(item.sourceUrl),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverHero extends StatelessWidget {
  final ItemModel item;

  const _CoverHero({required this.item});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: 340,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppTheme.brandGradient),
      child: Stack(
        children: [
          Positioned(
            top: -60,
            right: -50,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accentColor.withValues(alpha: 0.25),
                    AppTheme.accentColor.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 34),
              child: SizedBox(
                width: 158,
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 18),
                        ),
                      ],
                    ),
                    child: BookCover(
                      title: item.title,
                      author: item.author,
                      isAudiobook: item.isAudiobook,
                      imageUrl: item.coverUrl,
                      borderRadius: BorderRadius.circular(16),
                      showTypeBadge: false,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 44,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.isAudiobook
                          ? Icons.headphones_rounded
                          : Icons.menu_book_rounded,
                      size: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      item.isAudiobook ? 'AUDIOBOOK' : 'E-BOOK',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: scheme.onPrimary.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'PUBLIC DOMAIN',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Details extends StatelessWidget {
  final ItemModel item;
  final bool hideActions;
  final VoidCallback onDownload;
  final VoidCallback onSource;

  const _Details({
    required this.item,
    this.hideActions = false,
    required this.onDownload,
    required this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Badge(
              icon: item.isAudiobook
                  ? Icons.headphones_rounded
                  : Icons.menu_book_rounded,
              label: item.isAudiobook ? 'Audiobook' : 'E-book',
              background: scheme.primaryContainer,
              foreground: scheme.onPrimaryContainer,
            ),
            _Badge(
              icon: Icons.verified_rounded,
              label: 'Free · Public domain',
              background: scheme.tertiaryContainer,
              foreground: scheme.onTertiaryContainer,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(item.title, style: theme.textTheme.displaySmall),
        const SizedBox(height: 8),
        Text(
          'by ${item.author}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: scheme.outline),
        const SizedBox(height: 22),
        if (item.description != null) ...[
          Text(
            'About this ${item.isAudiobook ? 'audiobook' : 'book'}',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          Text(
            item.description!,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.72,
              color: scheme.onSurface.withValues(alpha: 0.86),
            ),
          ),
          const SizedBox(height: 26),
        ],
        if (item.genres.isNotEmpty) ...[
          Text('Genres', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: item.genres
                .map(
                  (genre) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: scheme.outline),
                    ),
                    child: Text(
                      genre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 26),
        ],
        _SourceCard(item: item, onSource: onSource),
        if (!hideActions) ...[
          const SizedBox(height: 24),
          _Actions(item: item, onDownload: onDownload, onSource: onSource),
          const SizedBox(height: 20),
          Center(
            child: Text(
              'Downloaded files are yours to keep, forever.',
              style: theme.textTheme.bodySmall?.copyWith(fontSize: 11.5),
            ),
          ),
        ],
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onDownload;
  final VoidCallback onSource;

  const _Actions({
    required this.item,
    required this.onDownload,
    required this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onDownload,
            icon: const Icon(Icons.download_rounded, size: 19),
            label: const Text('Get this title'),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 120,
          child: OutlinedButton.icon(
            onPressed: onSource,
            icon: const Icon(Icons.open_in_new_rounded, size: 17),
            label: const Text('Source'),
          ),
        ),
      ],
    );
  }
}

class _SourceCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onSource;

  const _SourceCard({required this.item, required this.onSource});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(
                  item.source == ItemSource.librivox
                      ? Icons.headphones_rounded
                      : Icons.public_rounded,
                  size: 19,
                  color: scheme.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Source',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.source == ItemSource.librivox
                          ? 'LibriVox'
                          : 'Standard Ebooks',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onSource,
                child: const Text('Open'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: scheme.outline),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: scheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Text(
                'Added ${_formatDate(item.createdAt)}',
                style: theme.textTheme.bodySmall,
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: scheme.outline),
                ),
                child: Text(
                  'CC0 / PD',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontSize: 9,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;

  const _Badge({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: foreground),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusScaffold extends StatelessWidget {
  final Widget child;

  const _StatusScaffold({required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: child,
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.28),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(icon, size: 20, color: Colors.white),
        ),
      ),
    );
  }
}

class _FlatIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _FlatIconButton({required this.icon, required this.onTap});

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

String _formatDate(DateTime date) {
  final now = DateTime.now();
  final difference = now.difference(date);

  if (difference.inDays < 1) {
    return 'today';
  } else if (difference.inDays < 7) {
    return '${difference.inDays} days ago';
  } else if (difference.inDays < 30) {
    return '${(difference.inDays / 7).floor()} weeks ago';
  } else if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()} months ago';
  } else {
    return '${(difference.inDays / 365).floor()} years ago';
  }
}
