import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A warm, sunlit, devotional palette inspired by parchment, brushed gold,
/// terracotta, and a luminous "First Vision" sky blue.
///
/// Light mode is warm parchment with sky-blue + gold + terracotta accents.
/// Dark mode is "firelight in a quiet room" — warm near-black with brown
/// undertones, the same accents lifted brighter.
class AppPalette {
  // Brand — luminous sky blue (heaven), warm gold (divine light),
  // terracotta (humanity / warmth)
  static const Color primary = Color(0xFF5B7FA8);
  static const Color primaryDark = Color(0xFF96B4D6);

  static const Color accent = Color(0xFFC9A66B);
  static const Color accentDark = Color(0xFFE3C589);

  static const Color tertiary = Color(0xFFB26B57);
  static const Color tertiaryDark = Color(0xFFD89786);

  // Surfaces — light parchment
  static const Color bgLight = Color(0xFFFBF6EC);
  static const Color surfaceLight = Color(0xFFFFFDF7);
  static const Color surfaceLightAlt = Color(0xFFF3ECDC);
  static const Color outlineLight = Color(0xFFE5DCC4);

  // Surfaces — warm dark (firelight). Browner / amber undertones than before
  // so even at night the app reads as "warm room with a single lit candle"
  // rather than "cold midnight blue."
  static const Color bgDark = Color(0xFF211912);
  static const Color surfaceDark = Color(0xFF2C2218);
  static const Color surfaceDarkAlt = Color(0xFF362A1F);
  static const Color outlineDark = Color(0xFF483828);

  // Text — warm undertones, never blue-grey
  static const Color onLight = Color(0xFF2A2620);
  static const Color onLightMuted = Color(0xFF6E6452);
  static const Color onDark = Color(0xFFF3EBDA);
  static const Color onDarkMuted = Color(0xFFB6A88F);
}

ThemeData buildLightTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDDE7F2),
    onPrimaryContainer: const Color(0xFF1F3754),
    secondary: AppPalette.accent,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFF5E9D0),
    onSecondaryContainer: const Color(0xFF6B5226),
    tertiary: AppPalette.tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFFF4DCD2),
    onTertiaryContainer: const Color(0xFF5A2C20),
    error: const Color(0xFFB3372C),
    onError: Colors.white,
    errorContainer: const Color(0xFFF7DDD8),
    onErrorContainer: const Color(0xFF40110B),
    surface: AppPalette.surfaceLight,
    onSurface: AppPalette.onLight,
    surfaceContainerHighest: AppPalette.surfaceLightAlt,
    onSurfaceVariant: AppPalette.onLightMuted,
    outline: AppPalette.outlineLight,
    outlineVariant: const Color(0xFFEDE5D2),
    shadow: const Color(0x14000000),
    scrim: const Color(0x66000000),
    inverseSurface: AppPalette.bgDark,
    onInverseSurface: AppPalette.onDark,
    inversePrimary: AppPalette.primaryDark,
  );
  return _buildTheme(scheme, AppPalette.bgLight);
}

ThemeData buildDarkTheme() {
  final scheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppPalette.primaryDark,
    onPrimary: AppPalette.bgDark,
    primaryContainer: const Color(0xFF2D4262),
    onPrimaryContainer: const Color(0xFFD8E3F2),
    secondary: AppPalette.accentDark,
    onSecondary: AppPalette.bgDark,
    secondaryContainer: const Color(0xFF3F311C),
    onSecondaryContainer: const Color(0xFFF5E5C4),
    tertiary: AppPalette.tertiaryDark,
    onTertiary: AppPalette.bgDark,
    tertiaryContainer: const Color(0xFF4F2E25),
    onTertiaryContainer: const Color(0xFFF6DCD2),
    error: const Color(0xFFE8B5AF),
    onError: const Color(0xFF53120D),
    errorContainer: const Color(0xFF7A2018),
    onErrorContainer: const Color(0xFFF7DDD8),
    surface: AppPalette.surfaceDark,
    onSurface: AppPalette.onDark,
    surfaceContainerHighest: AppPalette.surfaceDarkAlt,
    onSurfaceVariant: AppPalette.onDarkMuted,
    outline: AppPalette.outlineDark,
    outlineVariant: const Color(0xFF2A2419),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xCC000000),
    inverseSurface: AppPalette.bgLight,
    onInverseSurface: AppPalette.onLight,
    inversePrimary: AppPalette.primary,
  );
  return _buildTheme(scheme, AppPalette.bgDark);
}

ThemeData _buildTheme(ColorScheme scheme, Color bg) {
  // Display: Fraunces — a warm, literary serif. Body: Inter — clean and readable.
  final displayFont = GoogleFonts.fraunces;
  final bodyFont = GoogleFonts.inter;

  final textTheme = TextTheme(
    displayLarge: displayFont(
      fontSize: 56,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.5,
      color: scheme.onSurface,
      height: 1.05,
    ),
    displayMedium: displayFont(
      fontSize: 44,
      fontWeight: FontWeight.w500,
      letterSpacing: -1.0,
      color: scheme.onSurface,
      height: 1.1,
    ),
    displaySmall: displayFont(
      fontSize: 36,
      fontWeight: FontWeight.w500,
      letterSpacing: -0.5,
      color: scheme.onSurface,
      height: 1.15,
    ),
    headlineLarge: displayFont(
      fontSize: 30,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.3,
      color: scheme.onSurface,
      height: 1.2,
    ),
    headlineMedium: displayFont(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.2,
      color: scheme.onSurface,
      height: 1.25,
    ),
    headlineSmall: displayFont(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
      height: 1.3,
    ),
    titleLarge: bodyFont(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.1,
      color: scheme.onSurface,
    ),
    titleMedium: bodyFont(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    titleSmall: bodyFont(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: scheme.onSurface,
    ),
    bodyLarge: bodyFont(
      fontSize: 17,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
      height: 1.5,
    ),
    bodyMedium: bodyFont(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: scheme.onSurface,
      height: 1.5,
    ),
    bodySmall: bodyFont(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: scheme.onSurfaceVariant,
      height: 1.4,
    ),
    labelLarge: bodyFont(
      fontSize: 15,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: scheme.onSurface,
    ),
    labelMedium: bodyFont(
      fontSize: 13,
      fontWeight: FontWeight.w500,
      color: scheme.onSurfaceVariant,
    ),
    labelSmall: bodyFont(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: scheme.onSurfaceVariant,
    ),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: bg,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: bg,
      surfaceTintColor: Colors.transparent,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: scheme.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: scheme.outline.withValues(alpha: 0.6)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: textTheme.labelLarge,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(64, 56),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: scheme.onSurface,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        textStyle: textTheme.labelLarge,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        minimumSize: const Size(64, 56),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: scheme.primary,
        textStyle: textTheme.labelLarge,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: scheme.surfaceContainerHighest,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: scheme.primary, width: 1.5),
      ),
      labelStyle: textTheme.bodyMedium,
      hintStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
    ),
    dividerTheme: DividerThemeData(
      color: scheme.outline.withValues(alpha: 0.5),
      thickness: 1,
      space: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: scheme.inverseSurface,
      contentTextStyle:
          textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    splashFactory: InkRipple.splashFactory,
  );
}
