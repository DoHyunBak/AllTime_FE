import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────
  static const primary    = Color(0xFF1DB954); // Spotify Green
  static const primaryDim = Color(0xFF19A349);
  static const primaryBg  = Color(0xFFE8F8EF); // light green tint

  // ── Background (Light) ────────────────────────────────────
  static const bgBase     = Color(0xFFF5F7FA); // Soft off-white
  static const bgSurface  = Color(0xFFFFFFFF); // Pure white
  static const bgElevated = Color(0xFFEFF1F5); // Slightly elevated
  static const bgCard     = Color(0xFFFFFFFF); // Card white
  static const bgAlt      = Color(0xFFF0F2F5); // Alt grey

  // ── Text ──────────────────────────────────────────────────
  static const textPrimary   = Color(0xFF0D1117); // Near black
  static const textSecondary = Color(0xFF4B5563); // Medium grey
  static const textMuted     = Color(0xFF9CA3AF); // Light grey
  static const textWhite     = Color(0xFFFFFFFF); // For dark surfaces

  // ── Border ────────────────────────────────────────────────
  static const borderLight  = Color(0xFFE5E7EB); // Main border
  static const borderButton = Color(0xFFD1D5DB); // Button border

  // ── Semantic ──────────────────────────────────────────────
  static const error   = Color(0xFFDC2626); // Red
  static const warning = Color(0xFFF59E0B); // Amber
  static const info    = Color(0xFF3B82F6); // Blue
  static const star    = Color(0xFFF59E0B); // Star yellow

  // ── Status ────────────────────────────────────────────────
  static const available  = Color(0xFF1DB954);
  static const running    = Color(0xFF3B82F6);
  static const outOfOrder = Color(0xFFDC2626);

  // ── Aliases ───────────────────────────────────────────────
  static const bgPrimary  = bgBase;
  static const bgButton   = bgElevated;
  static const linkBlue   = info;
  static const offline    = textMuted;
}
