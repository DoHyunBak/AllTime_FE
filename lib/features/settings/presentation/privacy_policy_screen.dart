import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

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
                  '개인정보 처리 방침', 
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
                '개인정보 처리 방침',
                style: TextStyle(
                  fontSize: 20, 
                  fontWeight: FontWeight.w800, 
                  color: isDark ? Colors.white : AppColors.textPrimary
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'ALL TIME(이하 "서비스")는 사용자의 개인정보를 중요시하며, 정보통신망 이용촉진 및 정보보호 등에 관한 법률 등 관련 법령을 준수하고 있습니다.\n\n'
                '1. 수집하는 개인정보 항목\n'
                '서비스는 기숙사 인증 및 커뮤니티 운영을 위해 아래의 개인정보를 수집합니다.\n'
                '- 필수 항목: 학교 이메일, 이름, 기숙사명\n'
                '- 선택 항목: 프로필 사진, 한 줄 소개\n\n'
                '2. 개인정보의 수집 및 이용 목적\n'
                '서비스는 수집한 개인정보를 다음의 목적을 위해 활용합니다.\n'
                '- 회원 가입 및 관리\n'
                '- 서비스 제공 및 운영\n'
                '- 기숙사 전용 기능 제공\n\n'
                '3. 개인정보의 보유 및 이용 기간\n'
                '원칙적으로, 개인정보 수집 및 이용 목적이 달성된 후에는 해당 정보를 지체 없이 파기합니다. 단, 관계 법령에 의해 보존할 필요가 있는 경우 관련 법령에서 정한 일정한 기간 동안 회원정보를 보관합니다.\n\n'
                '본 개인정보 처리 방침은 데모용이며 실제 서비스 론칭 시 상세 내용이 추가됩니다.',
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
