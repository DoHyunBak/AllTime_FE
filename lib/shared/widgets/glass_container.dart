import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 글래스모피즘 카드 컨테이너.
/// 반투명 흰색 + 배경 블러(BackdropFilter) + 미세한 하이라이트 보더로
/// 프로스티드 글래스 효과를 냅니다. (색상 팔레트는 기존 라이트 테마 유지)
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.blurSigma = 18,
    this.opacity = 0.55,
    this.borderOpacity = 0.6,
    this.width,
    this.height,
    this.boxShadow,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double blurSigma;
  final double opacity;
  final double borderOpacity;
  final double? width;
  final double? height;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      margin: margin,
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.06),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              // 반투명 흰색 글래스 면 + 위→아래 미세 그라데이션
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: (opacity + 0.18).clamp(0.0, 1.0)),
                  Colors.white.withValues(alpha: opacity),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: borderOpacity),
                width: 1.0,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
