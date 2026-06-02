import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract final class AppTheme {
  static const _fontFamilyFallback = ['Apple SD Gothic Neo', 'sans-serif'];

  static TextTheme _buildTextTheme() {
    return const TextTheme(
      displaySmall:  TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.textPrimary,   fontFamilyFallback: _fontFamilyFallback),
      headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,   height: 1.3, fontFamilyFallback: _fontFamilyFallback),
      titleLarge:    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary,   fontFamilyFallback: _fontFamilyFallback),
      titleMedium:   TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,   fontFamilyFallback: _fontFamilyFallback),
      titleSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary,   fontFamilyFallback: _fontFamilyFallback),
      bodyLarge:     TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.textPrimary,   fontFamilyFallback: _fontFamilyFallback),
      bodyMedium:    TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.textSecondary, fontFamilyFallback: _fontFamilyFallback),
      bodySmall:     TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.textMuted,     fontFamilyFallback: _fontFamilyFallback),
      labelLarge:    TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary,   letterSpacing: 1.4, fontFamilyFallback: _fontFamilyFallback),
      labelSmall:    TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary, fontFamilyFallback: _fontFamilyFallback),
    );
  }

  static AppBarTheme get _appBarTheme => const AppBarTheme(
    backgroundColor: AppColors.bgSurface,
    foregroundColor: AppColors.textPrimary,
    elevation: 0,
    scrolledUnderElevation: 0,
    surfaceTintColor: Colors.transparent,
    toolbarHeight: 56,
    centerTitle: false,
    titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontFamilyFallback: _fontFamilyFallback),
    iconTheme: IconThemeData(color: AppColors.textPrimary),
  );

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

  static InputDecorationTheme get _inputDecorationTheme => InputDecorationTheme(
    filled: true,
    fillColor: AppColors.bgElevated,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderLight)),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
    hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
  );

  static CardThemeData get _cardTheme => CardThemeData(
    color: AppColors.bgSurface,
    elevation: 1,
    shadowColor: Colors.black.withValues(alpha: 0.08),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: AppColors.borderLight, width: 0.5)),
    margin: EdgeInsets.zero,
  );

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
      textTheme: _buildTextTheme(),
      appBarTheme: _appBarTheme,
      elevatedButtonTheme: _elevatedButtonTheme,
      inputDecorationTheme: _inputDecorationTheme,
      cardTheme: _cardTheme,
      dividerTheme: const DividerThemeData(color: AppColors.borderLight, thickness: 0.5, space: 0),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.bgSurface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.bgSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.12),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.textPrimary,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        actionTextColor: AppColors.primary,
      ),
      listTileTheme: const ListTileThemeData(textColor: AppColors.textPrimary, iconColor: AppColors.textSecondary),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      tabBarTheme: const TabBarThemeData(
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(fontSize: 13),
        dividerColor: AppColors.borderLight,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.bgElevated,
        selectedColor: AppColors.primaryBg,
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.borderLight, width: 0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
      ),
    );
  }
}
