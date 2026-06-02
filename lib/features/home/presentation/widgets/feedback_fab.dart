import 'package:flutter/material.dart';
import '../../../../core/feedback/feedback_service.dart';

/// 피드백 FAB — 항상 접근 가능한 의견 수렴 창구
///
/// 디자인: 글래스모피즘 스타일로 변경
class FeedbackFab extends StatelessWidget {
  const FeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => FeedbackService.open(context),
      backgroundColor: Colors.white.withValues(alpha: 0.2),
      foregroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
      ),
      icon: const Icon(Icons.edit_note_outlined, size: 20),
      label: const Text(
        '의견 보내기',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
