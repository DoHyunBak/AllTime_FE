import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC), // Cool white
            AppColors.bgBase,   // Soft off-white
            Color(0xFFEEF2F7), // Very light blue-grey
          ],
          stops: [0.0, 0.5, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // ── 글래스 블러가 비칠 은은한 컬러 블롭 (기존 팔레트) ──────
          Positioned(
            top: -80,
            left: -60,
            child: _Blob(color: AppColors.primary.withValues(alpha: 0.18), size: 260),
          ),
          Positioned(
            top: 180,
            right: -80,
            child: _Blob(color: AppColors.info.withValues(alpha: 0.14), size: 240),
          ),
          Positioned(
            bottom: -90,
            left: -40,
            child: _Blob(color: AppColors.primary.withValues(alpha: 0.12), size: 300),
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
