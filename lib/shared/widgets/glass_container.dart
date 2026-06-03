import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Toss 스타일 카드.
/// 흰색 면 + 1px #e5e8eb 보더 + 16px 라운드 + 4% 소프트 섀도우.
/// (별칭 GlassContainer 로도 사용 — 기존 호출부 호환)
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 16,
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
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLight, width: 1),
        boxShadow: const [
          // Toss: 4% 단일 소프트 섀도우 (스택 금지)
          BoxShadow(
            color: Color.fromRGBO(25, 31, 40, 0.04),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: child,
    );
  }
}

typedef GlassContainer = GlassCard;
