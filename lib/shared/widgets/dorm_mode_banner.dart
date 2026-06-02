import 'dart:ui';
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

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            border: Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.15), width: 1)),
          ),
          child: Row(
            children: [
              const Icon(Icons.nfc, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${dormMode.dormName} 기숙사 모드 활성화됨',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => ref.read(dormModeProvider.notifier).deactivate(),
                child: const Icon(Icons.close, color: Colors.white54, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 홈 화면에서 NFC 태깅 시뮬레이션 버튼
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
          // 실제: NFC 태그에서 기숙사 이름 읽기
          ref.read(dormModeProvider.notifier).activate('인재관');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('NFC 태깅 완료 — 인재관 기숙사 모드가 활성화되었습니다'),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.nfc,
                  size: 18,
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Text(
                  dormMode.isActive ? '기숙사 모드 ON' : 'NFC 태깅 [데모]',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
