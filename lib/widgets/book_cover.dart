// lib/widgets/book_cover.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

/// Generated cover art for titles without artwork.
///
/// Each title gets a stable palette derived from its own text, so the library
/// feels designed even when the catalogue has no cover images.
class BookCover extends StatelessWidget {
  final String title;
  final String author;
  final bool isAudiobook;
  final String? imageUrl;
  final BorderRadius? borderRadius;
  final bool showMeta;
  final bool showTypeBadge;

  const BookCover({
    super.key,
    required this.title,
    required this.author,
    required this.isAudiobook,
    this.imageUrl,
    this.borderRadius,
    this.showMeta = true,
    this.showTypeBadge = true,
  });

  static const List<List<Color>> _palettes = [
    [Color(0xFF312E81), Color(0xFF6366F1)],
    [Color(0xFF134E4A), Color(0xFF14B8A6)],
    [Color(0xFF7C2D12), Color(0xFFF59E0B)],
    [Color(0xFF4C1D95), Color(0xFFA855F7)],
    [Color(0xFF1E3A5F), Color(0xFF38BDF8)],
    [Color(0xFF3F1D38), Color(0xFFEC4899)],
    [Color(0xFF1F2937), Color(0xFF64748B)],
    [Color(0xFF365314), Color(0xFF84CC16)],
  ];

  static List<Color> paletteFor(String seed) {
    var hash = 0;
    for (final unit in seed.codeUnits) {
      hash = (hash * 31 + unit) & 0x7fffffff;
    }
    return _palettes[hash % _palettes.length];
  }

  @override
  Widget build(BuildContext context) {
    final palette = paletteFor('$title$author');
    final radius = borderRadius ?? BorderRadius.circular(16);

    return ClipRRect(
      borderRadius: radius,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Generated artwork
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: palette,
              ),
            ),
            child: Stack(
              children: [
                // Soft light bloom
                Positioned(
                  top: -60,
                  right: -50,
                  child: _Glow(
                    size: 180,
                    color: Colors.white.withValues(alpha: 0.18),
                  ),
                ),
                Positioned(
                  bottom: -70,
                  left: -60,
                  child: _Glow(
                    size: 200,
                    color: Colors.black.withValues(alpha: 0.16),
                  ),
                ),
                // Spine highlight
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 6,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withValues(alpha: 0.22),
                          Colors.white.withValues(alpha: 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
                if (showMeta)
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final titleSize = (width * 0.115).clamp(13.0, 28.0);
                      return Padding(
                        padding: EdgeInsets.fromLTRB(
                          width * 0.11,
                          width * 0.14,
                          width * 0.09,
                          width * 0.1,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LIBRA',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: (width * 0.045).clamp(7.0, 11.0),
                                fontWeight: FontWeight.w700,
                                letterSpacing: 2.2,
                                color: Colors.white.withValues(alpha: 0.72),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Fraunces',
                                    fontSize: titleSize,
                                    height: 1.15,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: -0.2,
                                    color: Colors.white,
                                    shadows: const [
                                      Shadow(
                                        color: Color(0x33000000),
                                        blurRadius: 12,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: width * 0.08),
                                Container(
                                  width: width * 0.18,
                                  height: 1.5,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                SizedBox(height: width * 0.07),
                                Text(
                                  author.toUpperCase(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize:
                                        (width * 0.055).clamp(8.0, 12.0),
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.0,
                                    color:
                                        Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Real artwork, when the catalogue provides it
          if (imageUrl != null && imageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: imageUrl!,
              fit: BoxFit.cover,
              fadeInDuration: const Duration(milliseconds: 250),
              placeholder: (_, _) => const SizedBox.shrink(),
              errorWidget: (_, _, _) => const SizedBox.shrink(),
            ),

          // Type badge
          if (showTypeBadge)
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.32),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isAudiobook ? Icons.graphic_eq : Icons.menu_book_rounded,
                      size: 11,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isAudiobook ? 'AUDIO' : 'BOOK',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 8.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.7,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
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
