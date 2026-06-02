import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  '이용약관', 
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '이용약관',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? Colors.white : AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 16),
              Text(
                '제1조 (목적)\n'
                '본 약관은 ALL TIME(이하 "서비스")가 제공하는 모든 제반 서비스의 이용과 관련하여 회사와 회원 간의 권리, 의무 및 책임사항 등을 규정함을 목적으로 합니다.\n\n'
                '제2조 (약관의 효력 및 변경)\n'
                '1. 본 약관은 서비스를 통하여 이를 공지하거나 전자우편 등의 방법으로 회원에게 통지함으로써 효력이 발생합니다.\n'
                '2. 서비스는 합리적인 사유가 발생할 경우 관련 법령에 위배되지 않는 범위 안에서 약관을 개정할 수 있습니다.\n\n'
                '제3조 (서비스의 제공 및 변경)\n'
                '서비스는 기숙사 생활 편의를 위한 커뮤니티, 시설 정보 제공 등을 주된 서비스로 하며, 운영상의 필요에 따라 제공하는 서비스의 내용을 변경할 수 있습니다.\n\n'
                '제4조 (회원의 의무)\n'
                '회원은 서비스 이용 시 다음 각 호의 행위를 하여서는 안 됩니다.\n'
                '- 신청 또는 변경 시 허위 내용의 등록\n'
                '- 타인의 정보 도용\n'
                '- 서비스가 정한 정보 이외의 정보의 송신 또는 게시\n\n'
                '본 이용약관은 데모용이며 실제 서비스 론칭 시 상세 내용이 추가됩니다.',
                style: TextStyle(
                  fontSize: 14, 
                  height: 1.6, 
                  color: isDark ? Colors.white.withValues(alpha: 0.8) : AppColors.textSecondary
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
