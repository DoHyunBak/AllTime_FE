import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

/// Apple 스타일 글래스모피즘 카드.
///
/// 설계 원칙
/// - Blur: 15~20 프로스티드 글래스 효과 (ImageFilter.blur)
/// - Surface: 반투명 흰색 기반 그라데이션
/// - Border: 1px 그라데이션 보더로 가장자리 입체감
/// - Shadow: 매우 부드럽고 확산되는 그림자
/// - 성능: RepaintBoundary로 블러 레이어 분리
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.width,
    this.height,
    this.isFullWidth = false,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final bool isFullWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final glassTheme = theme.extension<GlassTheme>()!;
    final isDark = theme.brightness == Brightness.dark;
    final radius = BorderRadius.circular(borderRadius);

    return RepaintBoundary(
      child: Container(
        width: isFullWidth ? double.infinity : width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -4,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _GradientBorderPainter(
            radius: borderRadius,
            gradient: glassTheme.borderGradient,
            strokeWidth: 1,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: glassTheme.blurSigma, sigmaY: glassTheme.blurSigma),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: isDark ? 0.08 : 0.15),
                      Colors.white.withValues(alpha: isDark ? 0.02 : 0.05),
                    ],
                  ),
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 그라데이션 보더를 그리는 페인터
class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.radius,
    required this.gradient,
    required this.strokeWidth,
  });

  final double radius;
  final Gradient gradient;
  final double strokeWidth;
  final Paint _paint = Paint();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    _paint.shader = gradient.createShader(rect);
    _paint.style = PaintingStyle.stroke;
    _paint.strokeWidth = strokeWidth;

    final RRect rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    canvas.drawRRect(rrect, _paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 기존 코드 호환성을 위한 별칭
typedef GlassContainer = GlassCard;
