import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 배경을 흰색으로 고정하여 가독성을 확보한 배경 위젯.
class AppBackground extends StatelessWidget {
  const AppBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      // 사용자의 요청에 따라 배경을 흰색(또는 다크모드 베이스)으로 고정
      color: isDark ? AppColors.bgBaseDark : Colors.white,
      child: child,
    );
  }
}
