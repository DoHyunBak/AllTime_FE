import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/auth/user_model.dart';
import '../../../shared/widgets/app_background.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _loading = false;

  // ── 비즈니스 로직 (변경 없음) ────────────────────────────────
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

                  // ── 로고 ──────────────────────────────────────
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'ALL',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1.5,
                          ),
                        ),
                        TextSpan(
                          text: 'TIME',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            color: AppColors.primary,
                            letterSpacing: -1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '기숙사 생활의 모든 것',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xB3FFFFFF),
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // ── 글래스모피즘 카드 ──────────────────────────
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '로그인',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              '소셜 계정으로 빠르게 시작하세요',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xB3FFFFFF),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 32),

                            // ── 소셜 로그인 버튼들 ───────────────
                            if (_loading)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            else
                              Column(
                                children: [
                                  _GlassSocialButton(
                                    label: '구글로 로그인',
                                    brandColor: Colors.white,
                                    textColor: const Color(0xFF1F1F1F),
                                    iconColor: const Color(0xFF4285F4),
                                    icon: Icons.g_mobiledata,
                                    onTap: () => _login(LoginProvider.google),
                                  ),
                                  const SizedBox(height: 12),
                                  _GlassSocialButton(
                                    label: '카카오로 로그인',
                                    brandColor: const Color(0xFFFEE500),
                                    textColor: const Color(0xFF191919),
                                    icon: Icons.chat_bubble,
                                    onTap: () => _login(LoginProvider.kakao),
                                  ),
                                  const SizedBox(height: 12),
                                  _GlassSocialButton(
                                    label: '네이버로 로그인',
                                    brandColor: const Color(0xFF03C75A),
                                    icon: Icons.language,
                                    onTap: () => _login(LoginProvider.naver),
                                  ),
                                ],
                              ),

                            const SizedBox(height: 24),

                            // ── 구분선 ───────────────────────────
                            Row(
                              children: [
                                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2), height: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    '또는',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.4),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Expanded(child: Divider(color: Colors.white.withValues(alpha: 0.2), height: 1)),
                              ],
                            ),

                            const SizedBox(height: 16),

                            // ── 데모 버튼 ────────────────────────
                            Row(
                              children: [
                                Expanded(
                                  child: _GlassDemoButton(
                                    label: '학생 데모',
                                    onTap: _loading ? null : () => _loginDemo(asAdmin: false),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _GlassDemoButton(
                                    label: '관리자 데모',
                                    onTap: _loading ? null : () => _loginDemo(asAdmin: true),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── 하단 안내 ──────────────────────────────────
                  Text(
                    '기숙사 학생증으로만 가입 가능합니다',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
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

// ── 글래스 소셜 버튼 ──────────────────────────────────────────
class _GlassSocialButton extends StatelessWidget {
  const _GlassSocialButton({
    required this.label,
    required this.brandColor,
    required this.icon,
    required this.onTap,
    this.textColor = Colors.white,
    this.iconColor,
  });

  final String label;
  final Color brandColor;
  final Color textColor;
  final Color? iconColor;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: brandColor.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: iconColor ?? textColor, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: textColor,
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

// ── 글래스 데모 버튼 ──────────────────────────────────────────
class _GlassDemoButton extends StatelessWidget {
  const _GlassDemoButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: onTap != null ? 1.0 : 0.4),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
