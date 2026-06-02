import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/payment/payment_provider.dart';
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: const Text('결제 수단 관리', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              '기숙사 통합 결제 수단',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              '선택하신 결제 수단은 식당, 세탁실 등 기숙사 내 모든 시설에서 NFC 태깅 시 자동으로 결제됩니다.',
              style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 32),
            GlassContainer(
              padding: EdgeInsets.zero,
              opacity: 0.05,
              borderOpacity: 0.1,
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
                        color: Colors.white,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: Color(0xFF1ED760))
                        : const Icon(Icons.circle_outlined, color: Colors.white30),
                    onTap: () {
                      ref.read(paymentMethodProvider.notifier).state = method;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('$method(으)로 기본 결제 수단이 변경되었습니다.'),
                          backgroundColor: Colors.white.withValues(alpha: 0.2),
                          duration: const Duration(seconds: 2),
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
