import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/dorm_mode/dorm_mode_provider.dart';

class DormModeBanner extends ConsumerWidget {
  const DormModeBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dormMode = ref.watch(dormModeProvider);
    if (!dormMode.isActive) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: AppColors.primaryBg,
        border: Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.nfc, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${dormMode.dormName} 기숙사 모드 활성화됨',
              style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
          GestureDetector(
            onTap: () => ref.read(dormModeProvider.notifier).deactivate(),
            child: const Icon(Icons.close, color: AppColors.textMuted, size: 18),
          ),
        ],
      ),
    );
  }
}

class NfcSimulateButton extends ConsumerWidget {
  const NfcSimulateButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dormMode = ref.watch(dormModeProvider);

    return GestureDetector(
      onTap: () {
        if (dormMode.isActive) {
          ref.read(dormModeProvider.notifier).deactivate();
        } else {
          ref.read(dormModeProvider.notifier).activate('인재관');
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('NFC 태깅 완료 — 인재관 기숙사 모드가 활성화되었습니다'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: dormMode.isActive ? AppColors.primaryBg : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: dormMode.isActive ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.nfc, size: 16, color: dormMode.isActive ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(
              dormMode.isActive ? '기숙사 모드 ON' : 'NFC 태깅 [데모]',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: dormMode.isActive ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
