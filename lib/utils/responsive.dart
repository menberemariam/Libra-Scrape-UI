// lib/utils/responsive.dart
import 'package:flutter/widgets.dart';

/// Shared responsive breakpoints so every screen grows consistently from a
/// phone in Chrome's device mode up to a full desktop window.
class Responsive {
  Responsive._();

  static const double compact = 600;
  static const double medium = 900;
  static const double expanded = 1200;

  static bool isCompact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < compact;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= medium;

  static int gridColumns(double width) {
    if (width >= expanded) return 6;
    if (width >= medium) return 4;
    if (width >= 700) return 3;
    return 2;
  }

  static double horizontalPadding(double width) {
    if (width >= medium) return 32;
    return 20;
  }

  /// Caps content width so layouts stay balanced on very wide windows.
  static double contentWidth(double width, {double max = 1120}) =>
      width > max ? max : width;

  static double tileWidth(
    double width, {
    int? columns,
    double spacing = 14,
  }) {
    final cols = columns ?? gridColumns(width);
    return (width - spacing * (cols - 1)) / cols;
  }

  /// A grid sized so each tile fits an 3:4 cover plus its caption block.
  static SliverGridDelegate gridDelegate({
    required double width,
    double spacing = 14,
    double captionHeight = 104,
  }) {
    final tile = tileWidth(width, spacing: spacing);
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: gridColumns(width),
      crossAxisSpacing: spacing,
      mainAxisSpacing: spacing + 4,
      mainAxisExtent: tile * 4 / 3 + captionHeight + 14,
    );
  }

  /// Same sizing as [gridDelegate], for shrink-wrapped grids.
  static SliverGridDelegateWithFixedCrossAxisCount shrinkWrapGridDelegate({
    required double width,
    double spacing = 14,
    double captionHeight = 104,
  }) {
    return gridDelegate(
          width: width,
          spacing: spacing,
          captionHeight: captionHeight,
        )
        as SliverGridDelegateWithFixedCrossAxisCount;
  }
}
