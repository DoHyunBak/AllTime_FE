import 'package:flutter/material.dart';
import 'liquid_glass.dart';

/// Liquid Glass [LiquidGlassTier.tier2] 카드.
/// 반투명 프로스티드 면 + 스쿼클 + 스페큘러 하이라이트(블러 위젯 없음 → 60fps).
/// (별칭 GlassContainer 로도 사용 — 기존 호출부 호환)
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 20,
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
    return LiquidGlass(
      tier: LiquidGlassTier.tier2,
      borderRadius: borderRadius,
      padding: padding,
      margin: margin,
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: child,
    );
  }
}

typedef GlassContainer = GlassCard;
