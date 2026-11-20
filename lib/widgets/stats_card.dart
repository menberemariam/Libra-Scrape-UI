// lib/widgets/stats_card.dart
import 'package:flutter/material.dart';

/// Compact catalogue counters designed to sit inside the home hero.
class StatsCard extends StatelessWidget {
  final int totalItems;
  final int totalBooks;
  final int totalAudiobooks;
  final bool onDark;

  const StatsCard({
    super.key,
    required this.totalItems,
    required this.totalBooks,
    required this.totalAudiobooks,
    this.onDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = onDark ? Colors.white : Theme.of(context).colorScheme.onSurface;
    final muted = onDark
        ? Colors.white.withValues(alpha: 0.66)
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.09) : null,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.14)
              : Theme.of(context).colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          _Stat(
            icon: Icons.library_books_outlined,
            label: 'Titles',
            value: totalItems,
            foreground: foreground,
            muted: muted,
          ),
          _Divider(onDark: onDark),
          _Stat(
            icon: Icons.menu_book_rounded,
            label: 'E-books',
            value: totalBooks,
            foreground: foreground,
            muted: muted,
          ),
          _Divider(onDark: onDark),
          _Stat(
            icon: Icons.headphones_rounded,
            label: 'Audio',
            value: totalAudiobooks,
            foreground: foreground,
            muted: muted,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  final bool onDark;

  const _Divider({required this.onDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 34,
      color: onDark
          ? Colors.white.withValues(alpha: 0.14)
          : Theme.of(context).colorScheme.outline,
    );
  }
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color foreground;
  final Color muted;

  const _Stat({
    required this.icon,
    required this.label,
    required this.value,
    required this.foreground,
    required this.muted,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: muted),
          const SizedBox(height: 6),
          Text(
            value > 999 ? '${(value / 1000).toStringAsFixed(1)}k' : '$value',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: foreground,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
              color: muted,
            ),
          ),
        ],
      ),
    );
  }
}
