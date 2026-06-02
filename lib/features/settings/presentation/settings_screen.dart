import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/payment/payment_provider.dart';
import '../../../shared/widgets/glass_container.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final paymentMethod = ref.watch(paymentMethodProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          if (user != null) _ProfileCard(user: user),
          if (user != null && user.discountCoupons > 0) _CouponBanner(count: user.discountCoupons),
          const SizedBox(height: 8),
          const _SectionHeader(label: '계정'),
          _InfoTile(icon: Icons.apartment_outlined, label: '기숙사', value: user?.dormitory ?? '-', onTap: null),
          _InfoTile(icon: Icons.verified_user_outlined, label: '학교 인증', value: (user?.isSchoolVerified ?? false) ? '인증 완료' : '미인증', onTap: null),
          _InfoTile(icon: Icons.payment_outlined, label: '통합 결제 수단', value: paymentMethod, onTap: () => context.push('/payment-method')),
          _InfoTile(
            icon: Icons.login_outlined,
            label: '로그인 방식',
            value: user == null ? '-' : switch (user.loginProvider.name) {
              'google' => 'Google',
              'kakao'  => '카카오',
              'naver'  => '네이버',
              _        => '-',
            },
            onTap: null,
          ),
          const SizedBox(height: 8),
          const _SectionHeader(label: '앱 정보'),
          const _InfoTile(icon: Icons.info_outline, label: '버전', value: '0.1.0 (Beta)', onTap: null),
          _InfoTile(icon: Icons.policy_outlined, label: '개인정보처리방침', value: '', onTap: () => context.push('/privacy')),
          _InfoTile(icon: Icons.description_outlined, label: '이용약관', value: '', onTap: () => context.push('/terms')),
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton(
              onPressed: () => ref.read(authProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(500)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('로그아웃', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.user});
  final dynamic user;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primaryBg,
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0] : '?',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(user.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    if (user.isAdmin) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                        ),
                        child: const Text('관리자', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(user.email, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                const SizedBox(height: 4),
                Text(user.dormitory, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponBanner extends StatelessWidget {
  const _CouponBanner({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer, color: AppColors.primary, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text('500원 할인 쿠폰 $count장 보유 중', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const Text('자동 적용', style: TextStyle(fontSize: 11, color: AppColors.primaryDim, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: AppColors.textMuted),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
      leading: Icon(icon, size: 20, color: AppColors.textMuted),
      title: Text(label, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary)),
      trailing: value.isNotEmpty
          ? Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500))
          : const Icon(Icons.chevron_right, size: 20, color: AppColors.textMuted),
      onTap: onTap,
    );
  }
}
