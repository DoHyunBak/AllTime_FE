import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/payment/payment_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                elevation: 0,
                title: const Text('마이페이지', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          children: [
            // ── 프로필 카드 ──────────────────────────────────────
            if (user != null) _ProfileCard(user: user),

            // ── 쿠폰 현황 ────────────────────────────────────────
            if (user != null && user.discountCoupons > 0)
              _CouponBanner(count: user.discountCoupons),

            const SizedBox(height: 12),

            // ── 계정 ─────────────────────────────────────────────
            const _SectionHeader(label: '계정'),
            _InfoTile(icon: Icons.school_outlined, label: '기숙사', value: user?.dormitory ?? '-', onTap: null),
            _InfoTile(icon: Icons.verified_user_outlined, label: '학교 인증', value: (user?.isSchoolVerified ?? false) ? '인증 완료' : '미인증', onTap: null),
            _InfoTile(icon: Icons.payment_outlined, label: '통합 결제 수단', value: paymentMethod, onTap: () => context.push('/payment-method')),
            _InfoTile(
              icon: Icons.login_outlined,
              label: '로그인 방식',
              value: switch (user?.loginProvider?.name) {
                'google' => 'Google',
                'kakao'  => '카카오',
                'naver'  => '네이버',
                _        => '-',
              },
              onTap: null,
            ),

            const SizedBox(height: 12),

            // ── 앱 정보 ───────────────────────────────────────────
            const _SectionHeader(label: '앱 정보'),
            _InfoTile(icon: Icons.info_outline, label: '버전', value: '0.1.0 (Beta)', onTap: null),
            _InfoTile(icon: Icons.policy_outlined, label: '개인정보처리방침', value: '', onTap: () => context.push('/privacy')),
            _InfoTile(icon: Icons.description_outlined, label: '이용약관', value: '', onTap: () => context.push('/terms')),

            const SizedBox(height: 32),

            // ── 로그아웃 ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ElevatedButton(
                onPressed: () => ref.read(authProvider.notifier).logout(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFF7C7C7C)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
                ),
                child: Text(
                  '로그아웃'.toUpperCase(),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── 프로필 카드 ──────────────────────────────────────────────
class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // 아바타
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.2),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0] : '?',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 20),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    if (user.isAdmin) ...[
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                        ),
                        child: const Text(
                          '관리자',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Text(user.email, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5))),
                const SizedBox(height: 6),
                Text(
                  user.dormitory,
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 쿠폰 배너 ───────────────────────────────────────────────
class _CouponBanner extends StatelessWidget {
  const _CouponBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      opacity: 0.2,
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '500원 할인 쿠폰 $count장 보유 중',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          Text(
            '자동 적용',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.5,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      leading: Icon(icon, size: 20, color: Colors.white70),
      title: Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      trailing: value.isNotEmpty
          ? Text(value, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600))
          : const Icon(Icons.chevron_right, size: 20, color: Colors.white30),
      onTap: onTap,
    );
  }
}
