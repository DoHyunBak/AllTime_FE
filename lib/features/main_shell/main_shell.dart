import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/auth/auth_provider.dart';
import '../../shared/widgets/dorm_mode_banner.dart';
import '../../shared/widgets/app_background.dart';

final shellIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key, required this.child});
  final Widget child;

  static const _tabs = [
    (icon: Icons.home_outlined,     activeIcon: Icons.home,     label: '홈',     path: '/'),
    (icon: Icons.forum_outlined,    activeIcon: Icons.forum,    label: '커뮤니티', path: '/community'),
    (icon: Icons.apartment_outlined,activeIcon: Icons.apartment,label: '시설',    path: '/facility'),
    (icon: Icons.poll_outlined,     activeIcon: Icons.poll,     label: '설문',    path: '/survey'),
    (icon: Icons.person_outline,    activeIcon: Icons.person,   label: '마이',    path: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellIndexProvider);
    final user = ref.watch(authProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final barBgColor = isDark 
        ? AppColors.bgSurfaceDark.withValues(alpha: 0.8) 
        : Colors.white.withValues(alpha: 0.8);
    final borderColor = isDark ? AppColors.borderDark : AppColors.borderLight;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: barBgColor,
                  border: Border(bottom: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.5)),
                ),
                child: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Row(
                    children: [
                      Text('ALL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: textColor)),
                      const Text('TIME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      if (user != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${user.school} · ${user.dormitory}',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isDark ? Colors.white70 : AppColors.textMuted),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                  actions: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.notifications_none, color: textColor),
                          onPressed: () {},
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            const DormModeBanner(),
            Expanded(child: child),
          ],
        ),
        bottomNavigationBar: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: barBgColor,
                border: Border(top: BorderSide(color: borderColor.withValues(alpha: 0.5), width: 0.5)),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(shellIndexProvider.notifier).state = index;
                  context.go(_tabs[index].path);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: AppColors.primary,
                unselectedItemColor: isDark ? Colors.white30 : AppColors.textMuted,
                selectedFontSize: 11,
                unselectedFontSize: 11,
                elevation: 0,
                items: _tabs.map((tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  activeIcon: Icon(tab.activeIcon),
                  label: tab.label,
                )).toList(),
              ),
            ),
          ),
        ),
        floatingActionButton: user != null && user.discountCoupons > 0
            ? FloatingActionButton.small(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 2,
                shape: const CircleBorder(),
                onPressed: () => _showCouponDialog(context, user.discountCoupons),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.local_offer, color: Colors.white, size: 20),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: Center(
                          child: Text(
                            '${user.discountCoupons}',
                            style: const TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : null,
      ),
    );
  }

  void _showCouponDialog(BuildContext context, int count) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('보유 할인 쿠폰', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        content: Text(
          '500원 할인 쿠폰 $count장을 보유 중입니다.\n식당 결제 시 자동 적용됩니다.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
