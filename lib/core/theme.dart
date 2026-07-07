import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Off-black (not pure #000) — impeccable rule: replace pure black
  static const Color background = Color(0xFF0C0C0E);
  // Surface: slightly lifted zinc
  static const Color surface = Color(0xFF16161A);
  // Surface 2: dialogs, cards — more elevation
  static const Color surface2 = Color(0xFF1F1F25);
  // Accent: Stark white — primary CTA / active icon
  static const Color primaryAccent = Color(0xFFF5F5F7);
  // Muted: zinc-600 — borders, secondary elements
  static const Color muted = Color(0xFF3F3F46);
  // Text hierarchy
  static const Color textPrimary = Color(0xFFF5F5F7);
  static const Color textSecondary = Color(0xFF8E8E99);
  static const Color textTertiary = Color(0xFF52525B);

  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 56.0;

  static ThemeData get darkTheme {
    // Space Grotesk for UI labels/headings (geometric, editorial, precise)
    // DM Mono for the timer (monospaced — prevents layout shift on tick)
    final base = ThemeData(brightness: Brightness.dark, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primaryAccent,
      colorScheme: const ColorScheme.dark(
        primary: primaryAccent,
        secondary: muted,
        surface: surface,
        onSurface: textPrimary,
        outline: muted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: background,
        elevation: 0,
        height: 68,
        indicatorColor: Colors.transparent, // No pill indicator — we handle it
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? textPrimary : textTertiary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.spaceGrotesk(
            fontSize: 10,
            letterSpacing: 0.8,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? textPrimary : textTertiary,
          );
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
      ),
      textTheme: TextTheme(
        // Timer display — DM Mono for tabular figures
        displayLarge: GoogleFonts.dmMono(
          color: textPrimary,
          fontSize: 64,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.0,
        ),
        // Screen titles
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        // Body copy
        bodyLarge: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        // Labels and captions
        bodyMedium: GoogleFonts.spaceGrotesk(
          color: textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        // Tiny labels (session type, tags)
        labelSmall: GoogleFonts.spaceGrotesk(
          color: textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface2,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
        ),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryAccent,
        thumbColor: primaryAccent,
        inactiveTrackColor: muted,
        overlayColor: Color(0x22F5F5F7),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: const BorderSide(color: muted),
        backgroundColor: surface,
        selectedColor: primaryAccent,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
