import 'dart:ui';
import 'package:flutter/material.dart';

/// 고도의 투명도와 강한 백드롭 블러를 가진 고품질 글래스 카드.
/// 밝은 배경 위에서 부드러운 그림자와 미세한 흰색 테두리로 입체감을 줍니다.
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

    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          // 부드럽고 확산되는 드롭 섀도우
          BoxShadow(
            color: isDark 
                ? Colors.black.withValues(alpha: 0.5) 
                : Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 10),
            spreadRadius: -5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // 더 강력한 블러 효과
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: radius,
              // 높은 투명도의 베이스 컬러
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.white.withValues(alpha: 0.4),
              // 미세하고 깨끗한 서리 낀 흰색 테두리
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.08)
                    : Colors.white.withValues(alpha: 0.6),
                width: 1.0,
              ),
              // 모서리 하이라이트 효과를 위한 미세 그라데이션
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isDark
                    ? [Colors.white.withValues(alpha: 0.1), Colors.transparent]
                    : [Colors.white.withValues(alpha: 0.5), Colors.transparent],
                stops: const [0.0, 0.5],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

typedef GlassContainer = GlassCard;
