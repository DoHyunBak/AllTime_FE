import 'package:flutter/material.dart';

abstract final class AppColors {
  // ── Brand ─────────────────────────────────────────────────
  static const primary    = Color(0xFF1ED760); // Spotify Green
  static const primaryDim = Color(0xFF1DB954);

  // ── Background ────────────────────────────────────────────
  static const bgBase     = Color(0xFF121212); // Near Black
  static const bgSurface  = Color(0xFF181818); // Dark Surface
  static const bgElevated = Color(0xFF1F1F1F); // Mid Dark
  static const bgCard     = Color(0xFF252525); // Dark Card
  static const bgAlt      = Color(0xFF272727); // Mid Card

  // ── Text ──────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFB3B3B3);
  static const textMuted     = Color(0xFF7C7C7C);
  static const textWhite     = Color(0xFFFFFFFF);

  // ── Border ────────────────────────────────────────────────
  static const borderLight  = Color(0xFF4D4D4D); // Border Gray
  static const borderButton = Color(0xFF7C7C7C); // Light Border

  // ── Semantic ──────────────────────────────────────────────
  static const error   = Color(0xFFF3727F); // Negative Red
  static const warning = Color(0xFFFFA42B); // Warning Orange
  static const info    = Color(0xFF539DF5); // Announcement Blue
  static const star    = Color(0xFFF9A825);

  // ── Status ────────────────────────────────────────────────
  static const available  = Color(0xFF1ED760);
  static const running    = Color(0xFF539DF5);
  static const outOfOrder = Color(0xFFF3727F);

  // ── Aliases ───────────────────────────────────────────────
  static const bgPrimary  = bgBase;
  static const bgButton   = bgElevated;
  static const linkBlue   = info;
  static const offline    = textMuted;
}
