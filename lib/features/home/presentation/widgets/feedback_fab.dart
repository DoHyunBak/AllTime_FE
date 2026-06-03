import 'package:flutter/material.dart';
import '../../../../core/feedback/feedback_service.dart';
import '../../../../core/theme/app_colors.dart';

/// 피드백 FAB — 항상 접근 가능한 의견 수렴 창구
class FeedbackFab extends StatelessWidget {
  const FeedbackFab({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => FeedbackService.open(context),
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(100),
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
