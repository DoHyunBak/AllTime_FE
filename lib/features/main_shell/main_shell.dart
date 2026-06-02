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
    (icon: Icons.home_outlined, activeIcon: Icons.home, label: '홈', path: '/'),
    (icon: Icons.forum_outlined, activeIcon: Icons.forum, label: '커뮤니티', path: '/community'),
    (icon: Icons.apartment_outlined, activeIcon: Icons.apartment, label: '시설', path: '/facility'),
    (icon: Icons.poll_outlined, activeIcon: Icons.poll, label: '설문', path: '/survey'),
    (icon: Icons.person_outline, activeIcon: Icons.person, label: '마이', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(shellIndexProvider);
    final user = ref.watch(authProvider);

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
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    const Text('ALL', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                    Text('TIME', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.primary)),
                    if (user != null) ...[
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '${user.school} - ${user.dormitory}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
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
                        icon: const Icon(Icons.notifications_none, color: Colors.white),
                        onPressed: () {
                          // 알림 화면 이동 (추후 구현)
                        },
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.2), width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: currentIndex,
                onTap: (index) {
                  ref.read(shellIndexProvider.notifier).state = index;
                  context.go(_tabs[index].path);
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                selectedItemColor: Colors.white,
                unselectedItemColor: Colors.white.withValues(alpha: 0.5),
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
        // 쿠폰 뱃지
        floatingActionButton: user != null && user.discountCoupons > 0
            ? FloatingActionButton.small(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
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
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${user.discountCoupons}',
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0xFF1DB954),
                              fontWeight: FontWeight.w700,
                            ),
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
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
          ),
          title: const Text('보유 할인 쿠폰', style: TextStyle(color: Colors.white)),
          content: Text(
            '500원 할인 쿠폰 $count장을 보유 중입니다.\n식당 결제 시 자동 적용됩니다.',
            style: const TextStyle(fontSize: 14, color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('확인', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
