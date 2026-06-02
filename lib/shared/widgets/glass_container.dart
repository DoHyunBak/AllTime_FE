import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Light-mode card container.
/// Replaces the dark glassmorphism style with clean white cards.
class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius = 16,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.blurSigma = 0,   // Kept for API compatibility; unused in light mode
    this.opacity = 1.0,   // Kept for API compatibility
    this.borderOpacity = 1.0,
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
    return Container(
      margin: margin,
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: child,
    );
  }
}
