import 'package:flutter/material.dart';

/// Toss Design System(TDS) 팔레트.
/// 단일 액센트(Toss Blue) + 5단계 그레이스케일. 순수 검정(#000) 미사용.
abstract final class AppColors {
  // ── Brand (단일 액센트: 우리 그린 유지) ───────────────────
  static const primary    = Color(0xFF1DB954); // Brand Green
  static const primaryDim = Color(0xFF19A349); // 진한 그린
  static const primaryBg  = Color(0xFFE8F8EF); // 연한 그린 워시

  // ── Background / Surface (Light) ──────────────────────────
  static const bgBase     = Color(0xFFF2F2F7); // Apple System Grouped Background
  static const bgSurface  = Color(0xFFFFFFFF); // Canvas / Card
  static const bgElevated = Color(0xFFF2F2F7); // Lifted surface (inputs)
  static const bgCard     = Color(0xFFFFFFFF);
  static const bgAlt      = Color(0xFFF2F4F6);

  // ── Background (Dark) — 미사용(라이트 고정)이나 컴파일 호환 유지 ──
  static const bgBaseDark     = Color(0xFF17171C);
  static const bgSurfaceDark  = Color(0xFF1E1E24);
  static const bgElevatedDark = Color(0xFF2A2A32);
  static const bgCardDark     = Color(0xFF1E1E24);
  static const bgAltDark      = Color(0xFF111114);

  // ── Text (5단계 그레이스케일) ─────────────────────────────
  static const textPrimary   = Color(0xFF191F28); // Near-ink (headlines)
  static const textSecondary = Color(0xFF333D4B); // Body
  static const textMuted     = Color(0xFF6B7684); // Metadata
  static const textDimmed    = Color(0xFF8B95A1); // Disabled/dimmed
  static const textWhite     = Color(0xFFFFFFFF);

  // ── Text (Dark) — 컴파일 호환 유지 ────────────────────────
  static const textPrimaryDark   = Color(0xFFF2F4F6);
  static const textSecondaryDark = Color(0xFFD1D6DB);
  static const textMutedDark     = Color(0xFF8B95A1);

  // ── Border ────────────────────────────────────────────────
  static const borderLight  = Color(0xFFE5E8EB); // Light border
  static const borderButton = Color(0xFFD1D6DB); // Strong border
  static const borderDark   = Color(0xFF2A2A32);

  // ── Semantic ──────────────────────────────────────────────
  static const error   = Color(0xFFF04452); // Toss Red
  static const warning = Color(0xFFFF9500); // Amber (semantic only)
  static const info    = Color(0xFF3182F6); // Announcement Blue
  static const star    = Color(0xFFFFB200);

  // ── Status ────────────────────────────────────────────────
  static const available  = primary;  // 사용가능 (그린)
  static const running    = info;      // 사용중 (블루)
  static const outOfOrder = error;     // 점검중 (레드)

  // ── Aliases ───────────────────────────────────────────────
  static const bgPrimary  = bgBase;
  static const bgButton   = bgElevated;
  static const linkBlue   = info;
  static const offline    = textMuted;
}
