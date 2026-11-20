// lib/widgets/loading_shimmer.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/responsive.dart';

class LoadingShimmer extends StatelessWidget {
  final bool showHeader;

  const LoadingShimmer({super.key, this.showHeader = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1C2338) : const Color(0xFFE9EBF3);
    final highlight = isDark ? const Color(0xFF283149) : const Color(0xFFF7F8FC);

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = Responsive.horizontalPadding(constraints.maxWidth);
        final contentWidth = constraints.maxWidth - padding * 2;

        return Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: padding, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (showHeader) ...[
                  Row(
                    children: [
                      _Block(width: 46, height: 46, radius: 14, color: scheme.surface),
                      const SizedBox(width: 12),
                      _Block(width: 120, height: 14, color: scheme.surface),
                      const Spacer(),
                      _Block(width: 32, height: 32, color: scheme.surface),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
                _Block(width: 160, height: 18, color: scheme.surface),
                const SizedBox(height: 14),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: Responsive.shrinkWrapGridDelegate(
                    width: contentWidth,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                      _ItemSkeleton(color: scheme.surface),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ItemSkeleton extends StatelessWidget {
  final Color color;

  const _ItemSkeleton({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _Block(color: color, radius: 14)),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Block(width: double.infinity, height: 11, color: color),
                const SizedBox(height: 6),
                _Block(width: 70, height: 9, color: color),
                const SizedBox(height: 10),
                _Block(width: 54, height: 14, radius: 8, color: color),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final Color color;

  const _Block({
    this.width,
    this.height = double.infinity,
    this.radius = 8,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}
