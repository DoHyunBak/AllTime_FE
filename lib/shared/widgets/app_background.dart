import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 깨끗하고 밝은 화이트 캔버스 배경.
/// 글래스모피즘 효과를 위해 아주 연한 파스텔톤의 추상적 형태들을 배경에 배치합니다.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return Container(
        color: AppColors.bgBaseDark,
        child: Stack(
          children: [
            Positioned(
              top: -100,
              right: -50,
              child: _Blob(color: AppColors.primary.withValues(alpha: 0.15), size: 300),
            ),
            Positioned(
              bottom: 100,
              left: -80,
              child: _Blob(color: AppColors.info.withValues(alpha: 0.1), size: 250),
            ),
            Positioned.fill(child: child),
          ],
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: Stack(
        children: [
          // ── 글래스 블러를 위한 매우 연한 파스텔톤 그라데이션 블롭 ──────
          Positioned(
            top: 50,
            left: -50,
            child: _Blob(color: const Color(0xFFF0F9FF), size: 400), // Very light blue
          ),
          Positioned(
            top: 300,
            right: -100,
            child: _Blob(color: const Color(0xFFF5F3FF), size: 350), // Very light violet
          ),
          Positioned(
            bottom: -50,
            left: 50,
            child: _Blob(color: const Color(0xFFECFDF5), size: 450), // Very light emerald
          ),
          // ── 배경 텍스처 (매우 미세한 노이즈 또는 패턴) ──────
          Positioned.fill(
            child: Opacity(
              opacity: 0.02,
              child: Image.network(
                'https://www.transparenttextures.com/patterns/cubes.png',
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
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
