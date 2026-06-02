import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/payment/payment_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';

class PaymentMethodScreen extends ConsumerWidget {
  const PaymentMethodScreen({super.key});

  static const _methods = [
    '신한 헤이영캠퍼스',
    'PAYCO',
    '카카오페이',
    '네이버페이',
    '신용/체크카드',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMethod = ref.watch(paymentMethodProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: isDark 
                    ? Colors.black.withValues(alpha: 0.2) 
                    : Colors.white.withValues(alpha: 0.5),
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
                  onPressed: () => context.pop(),
                ),
                title: Text(
                  '결제 수단 관리', 
                  style: TextStyle(
                    color: isDark ? Colors.white : AppColors.textPrimary, 
                    fontWeight: FontWeight.w800
                  )
                ),
                iconTheme: IconThemeData(color: isDark ? Colors.white : AppColors.textPrimary),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              '기숙사 통합 결제 수단',
              style: TextStyle(
                fontSize: 20, 
                fontWeight: FontWeight.w800, 
                color: isDark ? Colors.white : AppColors.textPrimary
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '선택하신 결제 수단은 식당, 세탁실 등 기숙사 내 모든 시설에서 NFC 태깅 시 자동으로 결제됩니다.',
              style: TextStyle(
                fontSize: 14, 
                color: isDark ? Colors.white70 : AppColors.textSecondary
              ),
            ),
            const SizedBox(height: 32),
            GlassContainer(
              padding: EdgeInsets.zero,
              child: Column(
                children: _methods.map((method) {
                  final isSelected = method == selectedMethod;
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    title: Text(
                      method,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isDark ? Colors.white : AppColors.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: AppColors.primary)
                        : Icon(Icons.circle_outlined, color: isDark ? Colors.white30 : AppColors.textMuted),
                    onTap: () {
                      ref.read(paymentMethodProvider.notifier).state = method;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$method(으)로 기본 결제 수단이 변경되었습니다.'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      context.pop();
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
