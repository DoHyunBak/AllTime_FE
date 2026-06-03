import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 깔끔하고 밝은 단색 배경.
/// (글래스모피즘용 블롭/텍스처 제거 — 평범하고 깨끗한 캔버스)
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.bgBase,
      child: child,
    );
  }
}
