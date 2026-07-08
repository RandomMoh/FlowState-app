import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors extends ThemeExtension<AppColors> {
  final Color background;
  final Color surface;
  final Color surface2;
  final Color primaryAccent;
  final Color muted;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;

  const AppColors({
    required this.background,
    required this.surface,
    required this.surface2,
    required this.primaryAccent,
    required this.muted,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
  });

  @override
  AppColors copyWith({
    Color? background,
    Color? surface,
    Color? surface2,
    Color? primaryAccent,
    Color? muted,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
  }) {
    return AppColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surface2: surface2 ?? this.surface2,
      primaryAccent: primaryAccent ?? this.primaryAccent,
      muted: muted ?? this.muted,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surface2: Color.lerp(surface2, other.surface2, t)!,
      primaryAccent: Color.lerp(primaryAccent, other.primaryAccent, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
    );
  }
}

extension AppThemeContext on BuildContext {
  AppColors get colors => Theme.of(this).extension<AppColors>()!;
}

class AppTheme {
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 56.0;

  static const AppColors darkColors = AppColors(
    background: Color(0xFF0C0C0E),
    surface: Color(0xFF16161A),
    surface2: Color(0xFF1F1F25),
    primaryAccent: Color(0xFFF5F5F7),
    muted: Color(0xFF3F3F46),
    textPrimary: Color(0xFFF5F5F7),
    textSecondary: Color(0xFF8E8E99),
    textTertiary: Color(0xFF52525B),
  );

  static const AppColors lightColors = AppColors(
    background: Color(0xFFFAFAFA),
    surface: Color(0xFFF4F4F5),
    surface2: Color(0xFFE4E4E7),
    primaryAccent: Color(0xFF09090B),
    muted: Color(0xFFD4D4D8),
    textPrimary: Color(0xFF09090B),
    textSecondary: Color(0xFF71717A),
    textTertiary: Color(0xFFA1A1AA),
  );

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, darkColors);
  static ThemeData get lightTheme => _buildTheme(Brightness.light, lightColors);

  static ThemeData _buildTheme(Brightness brightness, AppColors colors) {
    final base = ThemeData(brightness: brightness, useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: colors.background,
      primaryColor: colors.primaryAccent,
      extensions: [colors],
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primaryAccent,
        brightness: brightness,
        primary: colors.primaryAccent,
        secondary: colors.muted,
        surface: colors.surface,
        onSurface: colors.textPrimary,
        outline: colors.muted,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.background,
        elevation: 0,
        height: 68,
        indicatorColor: Colors.transparent,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: selected ? colors.textPrimary : colors.textTertiary,
            size: 22,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.spaceGrotesk(
            fontSize: 10,
            letterSpacing: 0.8,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? colors.textPrimary : colors.textTertiary,
          );
        }),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: colors.textPrimary),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: colors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w700,
          letterSpacing: 3.0,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.dmMono(
          color: colors.textPrimary,
          fontSize: 64,
          fontWeight: FontWeight.w300,
          letterSpacing: -1.0,
        ),
        headlineMedium: GoogleFonts.spaceGrotesk(
          color: colors.textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        bodyLarge: GoogleFonts.spaceGrotesk(
          color: colors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.6,
        ),
        bodyMedium: GoogleFonts.spaceGrotesk(
          color: colors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.spaceGrotesk(
          color: colors.textTertiary,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 2.0,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface2,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        titleTextStyle: GoogleFonts.spaceGrotesk(
          color: colors.textPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 2.5,
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: colors.primaryAccent,
        thumbColor: colors.primaryAccent,
        inactiveTrackColor: colors.muted,
        overlayColor: colors.primaryAccent.withValues(alpha: 0.1),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        side: BorderSide(color: colors.muted),
        backgroundColor: colors.surface,
        selectedColor: colors.primaryAccent,
        labelStyle: GoogleFonts.spaceGrotesk(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
