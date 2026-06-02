import 'package:feedback/feedback.dart';
import 'package:flutter/material.dart';

/// 인앱 피드백 수집 서비스
///
/// 원칙: 사용자를 '공동 창작자'로 대우
/// - 어느 화면에서든 즉각 피드백 제출 가능
/// - 스크린샷 + 텍스트 메모 자동 첨부
/// - 피드백 채널은 백엔드 연결 전까지 로컬 로그로 저장
abstract final class FeedbackService {
  /// 피드백 모달을 열고 제출 시 처리
  static void open(BuildContext context) {
    BetterFeedback.of(context).show((UserFeedback feedback) async {
      // TODO: 백엔드 API 연결 후 실제 전송으로 교체
      // await FeedbackApi.submit(
      //   text: feedback.text,
      //   screenshot: feedback.screenshot,
      //   extras: feedback.extra,
      // );

      // 개발 단계: 콘솔 로그
      debugPrint('📝 피드백 수신: ${feedback.text}');
      debugPrint('📸 스크린샷 크기: ${feedback.screenshot.lengthInBytes} bytes');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('소중한 의견 감사합니다! 더 나은 AllTime을 만들겠습니다 🙏'),
            backgroundColor: const Color(0xFF00BFA5),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    });
  }
}
