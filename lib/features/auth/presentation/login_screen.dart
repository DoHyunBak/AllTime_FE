import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/user_model.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/toss.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  Future<void> _login(LoginProvider provider) async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).loginMock(provider);
    if (mounted) context.go('/');
  }

  Future<void> _loginDemo({bool asAdmin = false}) async {
    setState(() => _loading = true);
    await ref.read(authProvider.notifier).loginMock(
      LoginProvider.google,
      asAdmin: asAdmin,
      skipVerification: true,
    );
    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
              child: Column(
                children: [
                  const SizedBox(height: 32),

                  // ── 로고 ──────────────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'ALL',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -1.5),
                        ),
                        TextSpan(
                          text: 'TIME',
                          style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: AppColors.primary, letterSpacing: -1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '기숙사 생활의 모든 것',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 0.5, fontWeight: FontWeight.w500),
                  ),

                  const SizedBox(height: 48),

                  // ── 로그인 카드 ────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: AppColors.bgSurface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderLight, width: 0.5),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 20, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('로그인', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                        const SizedBox(height: 4),
                        const Text('소셜 계정으로 빠르게 시작하세요', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                        const SizedBox(height: 28),

                        if (_loading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: FuturisticLoader(),
                            ),
                          )
                        else
                          Column(
                            children: [
                              _SocialButton(
                                label: 'Google로 시작하기',
                                bgColor: Colors.white,
                                borderColor: AppColors.borderLight,
                                textColor: const Color(0xFF191F28),
                                leading: const _GoogleMark(),
                                onTap: () => _login(LoginProvider.google),
                              ),
                              const SizedBox(height: 12),
                              _SocialButton(
                                label: 'Kakao로 시작하기',
                                bgColor: const Color(0xFFFEE500),
                                borderColor: const Color(0xFFFEE500),
                                textColor: const Color(0xFF191919),
                                leading: const Icon(Icons.chat_bubble, color: Color(0xFF191919), size: 22),
                                onTap: () => _login(LoginProvider.kakao),
                              ),
                              const SizedBox(height: 12),
                              _SocialButton(
                                label: 'Naver로 시작하기',
                                bgColor: const Color(0xFF03C75A),
                                borderColor: const Color(0xFF03C75A),
                                textColor: Colors.white,
                                leading: const _NaverMark(),
                                onTap: () => _login(LoginProvider.naver),
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider(color: AppColors.borderLight)),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('또는', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                            ),
                            const Expanded(child: Divider(color: AppColors.borderLight)),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: _DemoButton(
                                label: '학생 데모',
                                onTap: _loading ? null : () => _loginDemo(asAdmin: false),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _DemoButton(
                                label: '관리자 데모',
                                onTap: _loading ? null : () => _loginDemo(asAdmin: true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),
                  const Text(
                    '기숙사 학생증으로만 가입 가능합니다',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.label,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.leading,
    required this.onTap,
  });
  final String label;
  final Color bgColor;
  final Color borderColor;
  final Color textColor;
  final Widget leading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        // 아이콘은 좌측 고정, 라벨은 중앙 정렬
        child: Stack(
          alignment: Alignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: Align(alignment: Alignment.centerLeft, child: leading),
            ),
            Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: textColor)),
          ],
        ),
      ),
    );
  }
}

/// 구글 멀티컬러 'G' 마크 (에셋 없이 표현)
class _GoogleMark extends StatelessWidget {
  const _GoogleMark();
  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 24,
      height: 24,
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF4285F4),
            height: 1.0,
          ),
        ),
      ),
    );
  }
}

/// 네이버 'N' 마크
class _NaverMark extends StatelessWidget {
  const _NaverMark();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text(
          'N',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white, height: 1.0),
        ),
      ),
    );
  }
}

class _DemoButton extends StatelessWidget {
  const _DemoButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: onTap != null ? AppColors.textSecondary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}
