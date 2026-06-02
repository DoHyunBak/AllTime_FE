import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 글래스모피즘 효과를 극대화하기 위한 활기찬 메쉬 그라데이션 배경.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgBaseDark : AppColors.bgBase,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF0F172A), // Deep Navy
                  const Color(0xFF1E293B), // Slate
                  const Color(0xFF020617), // Near Black
                ]
              : [
                  const Color(0xFFF8FAFC), // Cool white
                  const Color(0xFFF1F5F9), // Soft slate
                  const Color(0xFFE2E8F0), // Light grey
                ],
        ),
      ),
      child: Stack(
        children: [
          // ── 활기찬 컬러 블롭 (메쉬 그라데이션 효과) ──────
          Positioned(
            top: -100,
            left: -50,
            child: _Blob(
              color: AppColors.primary.withValues(alpha: isDark ? 0.25 : 0.2),
              size: 350,
            ),
          ),
          Positioned(
            top: 200,
            right: -100,
            child: _Blob(
              color: AppColors.info.withValues(alpha: isDark ? 0.2 : 0.15),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -50,
            left: 20,
            child: _Blob(
              color: const Color(0xFF8B5CF6).withValues(alpha: isDark ? 0.2 : 0.12), // Violet
              size: 280,
            ),
          ),
          Positioned(
            bottom: 150,
            right: 40,
            child: _Blob(
              color: AppColors.primary.withValues(alpha: isDark ? 0.15 : 0.1),
              size: 200,
            ),
          ),
          // ── 실제 콘텐츠 ───────────────────────────────────────
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
