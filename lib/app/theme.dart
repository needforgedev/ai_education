import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Teen tier — "builder energy". Indigo + Cyan accents on a near-white
/// neutral background, Space Grotesk throughout.
class AppPalette {
  static const Color bg = Color(0xFFF4F4F8);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color primary = Color(0xFF4F46E5); // indigo
  static const Color primaryDeep = Color(0xFF3730A3);
  static const Color cyan = Color(0xFF06B6D4);
  static const Color ink = Color(0xFF0F172A);
  static const Color text = Color(0xFF1F2937);
  static const Color textSoft = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);

  /// Subtle indigo wash used in lesson "Try it" callouts and selected option backgrounds.
  static const Color primaryWash = Color(0xFFEEF2FF);
}

class AppRadii {
  static const double button = 14;
  static const double card = 18;
  static const double chip = 999;
  static const double input = 12;
  static const double pill = 10;
}

ThemeData buildTheme(Brightness brightness) {
  final base = ThemeData(brightness: brightness, useMaterial3: true);
  final isLight = brightness == Brightness.light;

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppPalette.primary,
    onPrimary: Colors.white,
    primaryContainer: AppPalette.primaryWash,
    onPrimaryContainer: AppPalette.primary,
    secondary: AppPalette.cyan,
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFCFFAFE),
    onSecondaryContainer: const Color(0xFF155E75),
    tertiary: AppPalette.ink,
    onTertiary: Colors.white,
    tertiaryContainer: const Color(0xFF1E293B),
    onTertiaryContainer: Colors.white,
    error: const Color(0xFFDC2626),
    onError: Colors.white,
    errorContainer: const Color(0xFFFEE2E2),
    onErrorContainer: const Color(0xFF7F1D1D),
    surface: isLight ? AppPalette.surface : const Color(0xFF0F172A),
    onSurface: isLight ? AppPalette.ink : const Color(0xFFE2E8F0),
    onSurfaceVariant: AppPalette.textSoft,
    outline: AppPalette.border,
    outlineVariant: AppPalette.border,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFFAFAFC),
    surfaceContainer: AppPalette.bg,
    surfaceContainerHigh: const Color(0xFFEEF1F5),
    surfaceContainerHighest: const Color(0xFFE9ECF1),
    inverseSurface: AppPalette.ink,
    onInverseSurface: Colors.white,
    inversePrimary: const Color(0xFFA5B4FC),
    shadow: Colors.black,
    scrim: Colors.black,
    surfaceTint: AppPalette.primary,
  );

  final textTheme = GoogleFonts.spaceGroteskTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.spaceGrotesk(
      fontSize: 48, fontWeight: FontWeight.w700,
      letterSpacing: -1.6, height: 1.05, color: colorScheme.onSurface,
    ),
    displayMedium: GoogleFonts.spaceGrotesk(
      fontSize: 38, fontWeight: FontWeight.w700,
      letterSpacing: -1.2, height: 1.05, color: colorScheme.onSurface,
    ),
    displaySmall: GoogleFonts.spaceGrotesk(
      fontSize: 30, fontWeight: FontWeight.w700,
      letterSpacing: -1.0, height: 1.1, color: colorScheme.onSurface,
    ),
    headlineLarge: GoogleFonts.spaceGrotesk(
      fontSize: 28, fontWeight: FontWeight.w700,
      letterSpacing: -0.8, color: colorScheme.onSurface,
    ),
    headlineMedium: GoogleFonts.spaceGrotesk(
      fontSize: 24, fontWeight: FontWeight.w700,
      letterSpacing: -0.6, color: colorScheme.onSurface,
    ),
    headlineSmall: GoogleFonts.spaceGrotesk(
      fontSize: 22, fontWeight: FontWeight.w700,
      letterSpacing: -0.5, color: colorScheme.onSurface,
    ),
    titleLarge: GoogleFonts.spaceGrotesk(
      fontSize: 18, fontWeight: FontWeight.w700,
      letterSpacing: -0.3, color: colorScheme.onSurface,
    ),
    titleMedium: GoogleFonts.spaceGrotesk(
      fontSize: 16, fontWeight: FontWeight.w600,
      letterSpacing: -0.2, color: colorScheme.onSurface,
    ),
    titleSmall: GoogleFonts.spaceGrotesk(
      fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface,
    ),
    bodyLarge: GoogleFonts.spaceGrotesk(
      fontSize: 16, fontWeight: FontWeight.w400,
      height: 1.5, color: AppPalette.text,
    ),
    bodyMedium: GoogleFonts.spaceGrotesk(
      fontSize: 14, fontWeight: FontWeight.w400,
      height: 1.5, color: AppPalette.text,
    ),
    bodySmall: GoogleFonts.spaceGrotesk(
      fontSize: 12, fontWeight: FontWeight.w400, color: AppPalette.textSoft,
    ),
    labelLarge: GoogleFonts.spaceGrotesk(
      fontSize: 14, fontWeight: FontWeight.w600, color: colorScheme.onSurface,
    ),
    labelMedium: GoogleFonts.spaceGrotesk(
      fontSize: 12, fontWeight: FontWeight.w600,
      letterSpacing: 0.5, color: AppPalette.textSoft,
    ),
    labelSmall: GoogleFonts.spaceGrotesk(
      fontSize: 11, fontWeight: FontWeight.w600,
      letterSpacing: 0.8, color: AppPalette.textSoft,
    ),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: AppPalette.bg,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.bg,
      foregroundColor: colorScheme.onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: textTheme.titleLarge,
    ),
    cardTheme: CardThemeData(
      color: colorScheme.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.card),
        side: const BorderSide(color: AppPalette.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: const BorderSide(color: AppPalette.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: const BorderSide(color: AppPalette.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: const BorderSide(color: AppPalette.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
        borderSide: BorderSide(color: colorScheme.error, width: 1.5),
      ),
      labelStyle: TextStyle(color: AppPalette.textSoft),
      hintStyle: TextStyle(color: AppPalette.textSoft.withValues(alpha: 0.7)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppPalette.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 52),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppPalette.text,
        backgroundColor: colorScheme.surface,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: AppPalette.border, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.button),
        ),
        textStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppPalette.primary,
        textStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: colorScheme.surface,
      selectedColor: AppPalette.ink,
      side: const BorderSide(color: AppPalette.border),
      labelStyle: textTheme.labelMedium?.copyWith(
        color: AppPalette.text,
      ),
      secondaryLabelStyle: textTheme.labelMedium?.copyWith(
        color: Colors.white,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.chip),
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppPalette.primary,
      linearTrackColor: AppPalette.border,
      linearMinHeight: 4,
    ),
    dividerTheme: const DividerThemeData(
      color: AppPalette.border,
      thickness: 1,
      space: 1,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: colorScheme.surface,
      indicatorColor: Colors.transparent,
      indicatorShape: const RoundedRectangleBorder(),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return textTheme.labelSmall?.copyWith(
          color: selected ? AppPalette.primary : AppPalette.textSoft,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          fontSize: 11,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? AppPalette.primary : AppPalette.textSoft,
          size: 22,
        );
      }),
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      height: 72,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppPalette.ink,
      contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadii.input),
      ),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Reusable design tokens for one-off widget styling.
class AppText {
  /// Eyebrow text — small uppercase tag above headers.
  static TextStyle eyebrow(BuildContext context, {Color? color}) =>
      Theme.of(context).textTheme.labelSmall!.copyWith(
            color: color ?? AppPalette.textSoft,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          );

  /// Mono-feeling tag (we use Space Grotesk for everything but bump letter-spacing).
  static TextStyle mono(BuildContext context, {Color? color}) =>
      GoogleFonts.spaceGrotesk(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 1.5,
        color: color ?? AppPalette.textSoft,
      );
}
