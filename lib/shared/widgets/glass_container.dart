import 'dart:ui';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 배경이 흰색일 때도 가독성을 유지하는 글래스모피즘 카드.
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
              color: isDark 
                  ? Colors.black.withValues(alpha: 0.3) 
                  : Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: -2,
            ),
          ],
        ),
        child: CustomPaint(
          painter: _GradientBorderPainter(
            radius: borderRadius,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.white.withValues(alpha: 0.15), Colors.white.withValues(alpha: 0.02)]
                  : [AppColors.primary.withValues(alpha: 0.2), Colors.black.withValues(alpha: 0.05)],
            ),
            strokeWidth: 1.2,
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                padding: padding,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.bgSurfaceDark.withValues(alpha: 0.7)
                      : Colors.white.withValues(alpha: 0.8), // 흰색 배경 위에서 보이도록 불투명도 조절
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

typedef GlassContainer = GlassCard;
