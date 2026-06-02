import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static const _fontFamilyFallback = ['Apple SD Gothic Neo', 'sans-serif'];

  static TextTheme _buildTextTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.textPrimary : AppColors.textPrimaryDark;
    final secondaryColor = brightness == Brightness.light ? AppColors.textSecondary : AppColors.textSecondaryDark;
    final mutedColor = brightness == Brightness.light ? AppColors.textMuted : AppColors.textMutedDark;

    return TextTheme(
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: color,   fontFamilyFallback: _fontFamilyFallback),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: color,   height: 1.3, fontFamilyFallback: _fontFamilyFallback),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color,   fontFamilyFallback: _fontFamilyFallback),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color,   fontFamilyFallback: _fontFamilyFallback),
      titleSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color,   fontFamilyFallback: _fontFamilyFallback),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: color,   fontFamilyFallback: _fontFamilyFallback),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondaryColor, fontFamilyFallback: _fontFamilyFallback),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor,     fontFamilyFallback: _fontFamilyFallback),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: color,   letterSpacing: 1.4, fontFamilyFallback: _fontFamilyFallback),
      labelSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: secondaryColor, fontFamilyFallback: _fontFamilyFallback),
    );
  }

  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    final bgColor = brightness == Brightness.light ? AppColors.bgSurface : AppColors.bgSurfaceDark;
    final textColor = brightness == Brightness.light ? AppColors.textPrimary : AppColors.textPrimaryDark;

    return AppBarTheme(
      backgroundColor: bgColor.withValues(alpha: 0.8), // Glassy effect
      foregroundColor: textColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      toolbarHeight: 56,
      centerTitle: false,
      titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: textColor, fontFamilyFallback: _fontFamilyFallback),
      iconTheme: IconThemeData(color: textColor),
    );
  }

  static ElevatedButtonThemeData get _elevatedButtonTheme => ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5),
      animationDuration: const Duration(milliseconds: 120),
    ),
  );

  static InputDecorationTheme _buildInputDecorationTheme(Brightness brightness) {
    final fillColor = brightness == Brightness.light ? AppColors.bgElevated : AppColors.bgElevatedDark;
    final borderColor = brightness == Brightness.light ? AppColors.borderLight : AppColors.borderDark;

    return InputDecorationTheme(
      filled: true,
      fillColor: fillColor.withValues(alpha: 0.5),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderColor)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      hintStyle: TextStyle(fontSize: 14, color: brightness == Brightness.light ? AppColors.textMuted : AppColors.textMutedDark),
    );
  }

  static CardThemeData _buildCardTheme(Brightness brightness) {
    final color = brightness == Brightness.light ? AppColors.bgSurface : AppColors.bgSurfaceDark;
    final borderColor = brightness == Brightness.light ? AppColors.borderLight : AppColors.borderDark;

    return CardThemeData(
      color: color.withValues(alpha: 0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24), // Apple Style
        side: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.5),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
        outline: AppColors.borderLight,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Apple SD Gothic Neo',
      textTheme: _buildTextTheme(Brightness.light),
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.light),
      cardTheme: _buildCardTheme(Brightness.light),
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 0.5, space: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSurface.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      extensions: [
        GlassTheme(
          blurSigma: 15.0,
          opacity: 0.1,
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.3),
              Colors.white.withValues(alpha: 0.05),
            ],
          ),
        ),
      ],
    );
  }

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        surface: AppColors.bgSurfaceDark,
        onSurface: AppColors.textPrimaryDark,
        error: AppColors.error,
        outline: AppColors.borderDark,
      ),
      scaffoldBackgroundColor: Colors.transparent,
      fontFamily: 'Apple SD Gothic Neo',
      textTheme: _buildTextTheme(Brightness.dark),
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _buildInputDecorationTheme(Brightness.dark),
      cardTheme: _buildCardTheme(Brightness.dark),
      dividerTheme: const DividerThemeData(color: AppColors.borderDark, thickness: 0.5, space: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMutedDark,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSurfaceDark.withValues(alpha: 0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
      ),
      extensions: [
        GlassTheme(
          blurSigma: 15.0,
          opacity: 0.05,
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.15),
              Colors.white.withValues(alpha: 0.02),
            ],
          ),
        ),
      ],
    );
  }
}

/// Glassmorphism 테마 프로퍼티를 관리하는 익스텐션
class GlassTheme extends ThemeExtension<GlassTheme> {
  const GlassTheme({
    required this.blurSigma,
    required this.opacity,
    required this.borderGradient,
  });

  final double blurSigma;
  final double opacity;
  final Gradient borderGradient;

  @override
  GlassTheme copyWith({
    double? blurSigma,
    double? opacity,
    Gradient? borderGradient,
  }) {
    return GlassTheme(
      blurSigma: blurSigma ?? this.blurSigma,
      opacity: opacity ?? this.opacity,
      borderGradient: borderGradient ?? this.borderGradient,
    );
  }

  @override
  GlassTheme lerp(ThemeExtension<GlassTheme>? other, double t) {
    if (other is! GlassTheme) return this;
    return GlassTheme(
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? blurSigma,
      opacity: lerpDouble(opacity, other.opacity, t) ?? opacity,
      borderGradient: Gradient.lerp(borderGradient, other.borderGradient, t) ?? borderGradient,
    );
  }

  static double? lerpDouble(num? a, num? b, double t) {
    if (a == null && b == null) return null;
    a ??= 0.0;
    b ??= 0.0;
    return a + (b - a) * t;
  }
}
