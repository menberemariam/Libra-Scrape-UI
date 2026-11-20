// lib/config/app_theme.dart
import 'package:flutter/material.dart';

/// Design tokens and component styling for Libra.
///
/// The palette pairs deep "midnight" indigo with a warm amber accent, giving
/// the library a calm, editorial feel that still looks at home in a modern
/// product UI.
class AppTheme {
  AppTheme._();

  // Brand palette -------------------------------------------------------------
  static const Color primaryColor = Color(0xFF4F46E5);
  static const Color primaryDeep = Color(0xFF312E81);
  static const Color secondaryColor = Color(0xFF7C3AED);
  static const Color accentColor = Color(0xFFF59E0B);
  static const Color backgroundColor = Color(0xFFF6F7FB);
  static const Color surfaceColor = Colors.white;
  static const Color inkColor = Color(0xFF101828);
  static const Color mutedColor = Color(0xFF667085);
  static const Color borderColor = Color(0xFFE7E9F2);
  static const Color errorColor = Color(0xFFDC2626);
  static const Color successColor = Color(0xFF059669);

  // Dark palette --------------------------------------------------------------
  static const Color darkBackground = Color(0xFF0B0F1E);
  static const Color darkSurface = Color(0xFF141A2C);
  static const Color darkBorder = Color(0xFF26304A);
  static const Color darkText = Color(0xFFEDEEF7);
  static const Color darkMuted = Color(0xFF98A2B3);

  // Shared metrics ------------------------------------------------------------
  static const double radiusSm = 12;
  static const double radiusMd = 18;
  static const double radiusLg = 24;
  static const double radiusXl = 32;
  static const double pageMaxWidth = 1120;
  static const double readingMaxWidth = 760;

  static LinearGradient get brandGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)],
        stops: [0.0, 0.55, 1.0],
      );

  static LinearGradient get coverFade => LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.black.withValues(alpha: 0.06),
          Colors.black.withValues(alpha: 0.62),
        ],
        stops: const [0.4, 1.0],
      );

  static ThemeData get lightTheme => _build(
        brightness: Brightness.light,
        background: backgroundColor,
        surface: surfaceColor,
        text: inkColor,
        muted: mutedColor,
        border: borderColor,
        primary: primaryColor,
      );

  static ThemeData get darkTheme => _build(
        brightness: Brightness.dark,
        background: darkBackground,
        surface: darkSurface,
        text: darkText,
        muted: darkMuted,
        border: darkBorder,
        primary: const Color(0xFF818CF8),
      );

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color text,
    required Color muted,
    required Color border,
    required Color primary,
  }) {
    final isDark = brightness == Brightness.dark;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      primaryContainer: isDark ? const Color(0xFF2A2C5E) : const Color(0xFFEEF0FF),
      onPrimaryContainer: isDark ? const Color(0xFFDCE0FF) : primaryDeep,
      secondary: secondaryColor,
      onSecondary: Colors.white,
      secondaryContainer:
          isDark ? const Color(0xFF2C1E4E) : const Color(0xFFF3EBFF),
      onSecondaryContainer: isDark ? const Color(0xFFE9DDFF) : const Color(0xFF4C1D95),
      tertiary: accentColor,
      onTertiary: const Color(0xFF3B2400),
      tertiaryContainer:
          isDark ? const Color(0xFF3A2A10) : const Color(0xFFFEF3C7),
      onTertiaryContainer:
          isDark ? const Color(0xFFFFE7B0) : const Color(0xFF92400E),
      error: errorColor,
      onError: Colors.white,
      errorContainer: isDark ? const Color(0xFF3A1B1B) : const Color(0xFFFEE4E2),
      onErrorContainer: isDark ? const Color(0xFFFFD2D2) : const Color(0xFF991B1B),
      surface: surface,
      onSurface: text,
      surfaceContainerHighest: isDark ? const Color(0xFF1D2336) : const Color(0xFFF1F2F8),
      onSurfaceVariant: muted,
      outline: border,
      outlineVariant: border,
      inverseSurface: isDark ? Colors.white : inkColor,
      onInverseSurface: isDark ? inkColor : Colors.white,
      shadow: isDark ? Colors.black : const Color(0xFFCBD0E0),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: 'Inter',
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      textTheme: _textTheme(text, muted),
      dividerTheme: DividerThemeData(color: border, thickness: 1, space: 1),
      iconTheme: IconThemeData(color: muted, size: 22),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 17,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.2,
          color: text,
        ),
        iconTheme: IconThemeData(color: text, size: 22),
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          side: BorderSide(color: border),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: text,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          side: BorderSide(color: border),
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusSm),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1B2136) : const Color(0xFFF3F4F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 14.5,
          color: muted.withValues(alpha: 0.8),
        ),
        prefixIconColor: muted,
        suffixIconColor: muted,
        border: _inputBorder(border),
        enabledBorder: _inputBorder(border),
        focusedBorder: _inputBorder(primary, width: 1.6),
        errorBorder: _inputBorder(errorColor),
        focusedErrorBorder: _inputBorder(errorColor, width: 1.6),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF1B2136) : const Color(0xFFF3F4F9),
        selectedColor: primary,
        secondarySelectedColor: primary,
        side: BorderSide(color: border),
        labelStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w500,
          color: muted,
        ),
        secondaryLabelStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF232B44) : inkColor,
        contentTextStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13.5,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        insetPadding: const EdgeInsets.all(16),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: border,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: muted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(muted.withValues(alpha: 0.35)),
        radius: const Radius.circular(999),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }

  static OutlineInputBorder _inputBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radiusSm),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(Color text, Color muted) {
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 44,
        height: 1.08,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.8,
        color: text,
      ),
      displayMedium: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 34,
        height: 1.12,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.5,
        color: text,
      ),
      displaySmall: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 27,
        height: 1.18,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: text,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 24,
        height: 1.2,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        color: text,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Fraunces',
        fontSize: 21,
        height: 1.25,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: text,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        height: 1.3,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: text,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15,
        height: 1.35,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.1,
        color: text,
      ),
      titleSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        height: 1.35,
        fontWeight: FontWeight.w600,
        color: text,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 15.5,
        height: 1.65,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        height: 1.6,
        fontWeight: FontWeight.w400,
        color: text,
      ),
      bodySmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12.5,
        height: 1.45,
        fontWeight: FontWeight.w400,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Inter',
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
        color: text,
      ),
      labelMedium: TextStyle(
        fontFamily: 'Inter',
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontFamily: 'Inter',
        fontSize: 10.5,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
        color: muted,
      ),
    );
  }
}
