import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import 'dorm_mode_provider.dart';
import '../../shared/widgets/liquid_glass.dart';

// 위치 기반 자동 기숙사 감지 서비스
// 실제: geolocator 패키지 + 기숙사 GPS 좌표 geofence 로직
// 현재: 앱 시작 후 일정 시간 뒤 팝업 시뮬레이션 (데모)
class LocationDormDetector {
  static Timer? _timer;

  static void startDetecting(BuildContext context, WidgetRef ref) {
    _timer?.cancel();
    // 데모: 5초 후 "기숙사 근처" 감지 시뮬레이션
    _timer = Timer(const Duration(seconds: 5), () {
      final dormMode = ref.read(dormModeProvider);
      if (!dormMode.isActive && context.mounted) {
        _showDormEntryDialog(context, ref);
      }
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }

  static void _showDormEntryDialog(BuildContext context, WidgetRef ref) {
    showGlassDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Row(
          children: [
            Icon(Icons.location_on, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              '기숙사 근처입니다',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Text(
          '기숙사 내부로 들어오셨나요?\n기숙사 모드를 켜면 시설 결제와 현황을 바로 이용할 수 있습니다.',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child:
                const Text('아니오', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(dormModeProvider.notifier).activate('인재관');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('인재관 기숙사 모드 활성화'),
                  backgroundColor: Color(0xFF1A1A2E),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text(
              '예, 켜기',
              style: TextStyle(
                  color: AppColors.primary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
