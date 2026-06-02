import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';

// 30분 후 평가 팝업을 띄워야 하는지 상태 관리
class MealRatingScheduler {
  static Timer? _timer;

  // 결제 후 30분 타이머 시작 (데모: 30초)
  static void scheduleAfterPayment({
    required BuildContext context,
    required WidgetRef ref,
    required String menuName,
    Duration delay = const Duration(seconds: 30), // 데모용 30초, 실제론 30분
  }) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      if (context.mounted) {
        showMealRatingDialog(context: context, ref: ref, menuName: menuName);
      }
    });
  }

  static void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}

Future<void> showMealRatingDialog({
  required BuildContext context,
  required WidgetRef ref,
  required String menuName,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _MealRatingSheet(menuName: menuName, ref: ref),
  );
}

class _MealRatingSheet extends StatefulWidget {
  const _MealRatingSheet({required this.menuName, required this.ref});
  final String menuName;
  final WidgetRef ref;

  @override
  State<_MealRatingSheet> createState() => _MealRatingSheetState();
}

class _MealRatingSheetState extends State<_MealRatingSheet> {
  int _stars = 0;
  XFile? _photo;
  final _commentController = TextEditingController();
  bool _submitted = false;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: ImageSource.gallery);
    if (file != null) setState(() => _photo = file);
  }

  Future<void> _submit() async {
    if (_stars == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('별점을 선택해주세요')),
      );
      return;
    }

    // 사진 리뷰 작성 시 500원 쿠폰 지급
    if (_photo != null) {
      widget.ref.read(authProvider.notifier).addDiscountCoupon();
    }

    setState(() => _submitted = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) Navigator.pop(context);

    if (_photo != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('사진 리뷰 등록 완료! 500원 할인 쿠폰이 지급되었습니다 🎉'),
          backgroundColor: AppColors.primary,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textPrimary.withValues(alpha: 0.1), 
            width: 1
          ),
        ),
        padding: EdgeInsets.only(
          left: 28,
          right: 28,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: _submitted
            ? _SubmittedView(isDark: isDark)
            : Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 드래그 핸들
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textPrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '${widget.menuName} 어떠셨나요?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '오늘 식사 평가를 남겨주세요',
                    style: TextStyle(
                      fontSize: 13, 
                      color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 별점
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) => GestureDetector(
                      onTap: () => setState(() => _stars = i + 1),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Icon(
                          i < _stars ? Icons.star : Icons.star_border,
                          size: 40,
                          color: i < _stars 
                              ? AppColors.star 
                              : (isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textPrimary.withValues(alpha: 0.1)),
                        ),
                      ),
                    )),
                  ),
                  const SizedBox(height: 24),

                  // 사진 업로드 (500원 할인 안내)
                  GestureDetector(
                    onTap: _pickPhoto,
                    child: Container(
                      width: double.infinity,
                      height: 100,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textPrimary.withValues(alpha: 0.02),
                        border: Border.all(
                          color: _photo != null 
                              ? (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.3)) 
                              : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.05)),
                          width: _photo != null ? 1.5 : 1,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: _photo != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: kIsWeb
                                  ? Image.network(_photo!.path, fit: BoxFit.cover)
                                  : Image.file(File(_photo!.path), fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.camera_alt_outlined, 
                                  color: isDark ? Colors.white54 : AppColors.textSecondary, 
                                  size: 28
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: '사진 추가 시 ',
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: isDark ? Colors.white54 : AppColors.textSecondary
                                        ),
                                      ),
                                      TextSpan(
                                        text: '500원 할인 쿠폰',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDark ? Colors.white : AppColors.textPrimary,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      TextSpan(
                                        text: ' 지급',
                                        style: TextStyle(
                                          fontSize: 12, 
                                          color: isDark ? Colors.white54 : AppColors.textSecondary
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 코멘트
                  TextField(
                    controller: _commentController,
                    maxLines: 2,
                    style: TextStyle(
                      fontSize: 14, 
                      color: isDark ? Colors.white : AppColors.textPrimary
                    ),
                    decoration: InputDecoration(
                      hintText: '한 줄 리뷰를 남겨주세요 (선택)',
                      hintStyle: TextStyle(
                        fontSize: 14, 
                        color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textMuted
                      ),
                      contentPadding: const EdgeInsets.all(16),
                      filled: true,
                      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textPrimary.withValues(alpha: 0.02),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.05)
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.05)
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.4), 
                          width: 1.5
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 제출 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submit,
                      child: Text(
                        '평가 제출'.toUpperCase(),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class _SubmittedView extends StatelessWidget {
  const _SubmittedView({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle, 
            color: isDark ? Colors.white : AppColors.primary, 
            size: 60
          ),
          const SizedBox(height: 16),
          Text(
            '평가 완료!',
            style: TextStyle(
              fontSize: 18, 
              fontWeight: FontWeight.w900, 
              color: isDark ? Colors.white : AppColors.textPrimary
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '소중한 리뷰 감사합니다',
            style: TextStyle(
              fontSize: 14, 
              color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.textSecondary
            ),
          ),
        ],
      ),
    );
  }
}
