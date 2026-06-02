import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static const _fontFamilyFallback = [
    'Apple SD Gothic Neo',
    'sans-serif',
  ];

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Section title — 24px bold
      displaySmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Feature heading — 18px semibold
      headlineSmall: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        height: 1.3,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Nav / AppBar title — 16px bold
      titleLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Section heading — 14px bold
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Small bold — 12px
      titleSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Body — 16px regular
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Body — 14px regular
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Caption — 12px regular
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMuted,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Button label — 14px bold, uppercase
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: 1.4,
        fontFamilyFallback: _fontFamilyFallback,
      ),
      // Small label — 12px semibold
      labelSmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        fontFamilyFallback: _fontFamilyFallback,
      ),
    );
  }

  static AppBarTheme get _appBarTheme => const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 64,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          fontFamilyFallback: _fontFamilyFallback,
        ),
      );

  // Pill button — Spotify style
  static ElevatedButtonThemeData get _elevatedButtonTheme =>
      ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.black, // Dark text on bright green
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(500),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.4,
            fontFamilyFallback: _fontFamilyFallback,
          ),
          animationDuration: const Duration(milliseconds: 120),
        ),
      );

  static InputDecorationTheme get _inputDecorationTheme =>
      InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgElevated,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(500),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(500),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(500),
          borderSide: const BorderSide(color: AppColors.textSecondary, width: 1),
        ),
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textMuted,
          fontFamilyFallback: _fontFamilyFallback,
        ),
      );

  static CardThemeData get _cardTheme => CardThemeData(
        color: AppColors.bgSurface,
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: EdgeInsets.zero,
      );

  static DividerThemeData get _dividerTheme => const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
        space: 0,
      );

  static BottomNavigationBarThemeData get _bottomNavTheme =>
      const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.textPrimary,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          fontFamilyFallback: _fontFamilyFallback,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontFamilyFallback: _fontFamilyFallback,
        ),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      );

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        onPrimary: Colors.black,
        surface: AppColors.bgSurface,
        onSurface: AppColors.textPrimary,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: Colors.transparent, // Background handled by AppBackground
      fontFamily: 'Apple SD Gothic Neo',
      textTheme: _buildTextTheme(),
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dividerTheme: _dividerTheme,
      bottomNavigationBarTheme: _bottomNavTheme,
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 24,
        shadowColor: Colors.black.withValues(alpha: 0.5),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.bgElevated,
        contentTextStyle: TextStyle(color: AppColors.textPrimary, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        textColor: AppColors.textPrimary,
        iconColor: AppColors.textSecondary,
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textSecondary,
        indicatorColor: AppColors.primary,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 13),
      ),
    );
  }
}