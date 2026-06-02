import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../core/dorm_mode/location_dorm_detector.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/dorm_mode_banner.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../facility/domain/facility_provider.dart';
import '../../community/domain/community_provider.dart';
import '../../survey/domain/survey_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) LocationDormDetector.startDetecting(context, ref);
    });
  }

  @override
  void dispose() {
    LocationDormDetector.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _GreetingHero(),
                const SizedBox(height: 16),
                _DormStatusBoard(),
                const SizedBox(height: 16),
                _QuickActions(),
                const SizedBox(height: 16),
                _ActiveSurveyTeaser(),
                const SizedBox(height: 16),
                _AnnouncementsCard(),
                const SizedBox(height: 16),
                _HotPostsCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 인사 + 긴급 공지 히어로 ────────────────────────────────────────────

class _GreetingHero extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider);
    final now = DateTime.now();
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    final dateStr = '${now.month}월 ${now.day}일 (${weekdays[now.weekday - 1]})';

    // 긴급(필독) 공지 1건
    final urgent = ref.watch(postListProvider('notice')).where((p) => p.isHot).firstOrNull;

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(dateStr, style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 4),
                    Text(
                      user != null ? '${user.name}님, 안녕하세요 👋' : '안녕하세요 👋',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.textPrimary),
                    ),
                    if (user != null) ...[
                      const SizedBox(height: 2),
                      Text('${user.school} · ${user.dormitory}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ],
                ),
              ),
              const NfcSimulateButton(),
            ],
          ),
          if (urgent != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () => context.push('/post/${urgent.id}'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.25), width: 0.5),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(4)),
                      child: const Text('필독', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(urgent.title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                    ),
                    const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── 기숙사 현황 보드 ───────────────────────────────────────────────────

class _DormStatusBoard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final washers = ref.watch(washingMachinesProvider);
    final dryers = ref.watch(dryersProvider);
    final gym = ref.watch(gymProvider);
    final menus = ref.watch(cafeteriaMenuProvider);

    final washAvail = washers.where((m) => m.status == MachineStatus.available).length;
    final dryAvail = dryers.where((m) => m.status == MachineStatus.available).length;
    final lunch = menus.firstWhere((m) => m.mealType == '점심', orElse: () => menus.first);

    final gymColor = switch (gym.label) {
      '여유' => AppColors.available,
      '보통' => AppColors.warning,
      _ => AppColors.outOfOrder,
    };

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.dashboard_customize_outlined, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              const Text('기숙사 현황', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go('/facility'),
                child: const Text('시설 전체', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _StatusTile(icon: Icons.local_laundry_service, label: '세탁기', value: '$washAvail대', sub: '사용가능', color: washAvail > 0 ? AppColors.available : AppColors.outOfOrder),
              const SizedBox(width: 10),
              _StatusTile(icon: Icons.dry_cleaning, label: '건조기', value: '$dryAvail대', sub: '사용가능', color: dryAvail > 0 ? AppColors.available : AppColors.outOfOrder),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatusTile(icon: Icons.fitness_center, label: '헬스장', value: gym.label, sub: '${gym.occupancy}/${gym.capacity}명', color: gymColor),
              const SizedBox(width: 10),
              _StatusTile(icon: Icons.restaurant, label: '오늘 점심', value: '${lunch.nutrition.kcal}kcal', sub: lunch.items.first, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTile extends StatelessWidget {
  const _StatusTile({required this.icon, required this.label, required this.value, required this.sub, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              width: 34, height: 34,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 1),
                  Text(value, style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.w900), overflow: TextOverflow.ellipsis),
                  Text(sub, style: const TextStyle(fontSize: 9, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 빠른 메뉴 ──────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ActionButton(icon: Icons.event_note_outlined, label: '예약', onTap: () => context.push('/reservation')),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.poll_outlined, label: '설문', onTap: () => context.go('/survey')),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.forum_outlined, label: '커뮤니티', onTap: () => context.go('/community')),
        const SizedBox(width: 12),
        _ActionButton(icon: Icons.public, label: '네트워크', onTap: () => context.push('/network')),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: GlassContainer(
          padding: const EdgeInsets.symmetric(vertical: 14),
          borderRadius: 14,
          child: Column(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 진행 중 설문 티저 ──────────────────────────────────────────────────

class _ActiveSurveyTeaser extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final survey = ref.watch(surveyProvider).where((s) => !s.isExpired).firstOrNull;
    if (survey == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => context.go('/survey'),
      child: GlassContainer(
        child: Row(
          children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.card_giftcard, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('진행 중 설문', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w800)),
                      const SizedBox(width: 6),
                      Text('D-${survey.expiresAt.difference(DateTime.now()).inDays}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(survey.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text('추첨 1명 · ${survey.prize}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 공지사항 ───────────────────────────────────────────────────────────

class _AnnouncementsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(postListProvider('notice')).take(3).toList();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: '공지사항', onMore: () => context.push('/board/notice')),
          const SizedBox(height: 12),
          ...notices.map((p) => _LineItem(id: p.id, title: p.title, date: p.date, isUrgent: p.isHot)),
        ],
      ),
    );
  }
}

// ── HOT 게시글 ─────────────────────────────────────────────────────────

class _HotPostsCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hot = ref.watch(postListProvider('hot')).take(4).toList();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(title: 'HOT 게시글', onMore: () => context.push('/board/hot')),
          const SizedBox(height: 12),
          ...hot.map((p) => _LineItem(id: p.id, title: p.title, date: p.date, isUrgent: false)),
        ],
      ),
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.onMore});
  final String title;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
        GestureDetector(
          onTap: onMore,
          child: const Text('더보기', style: TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({required this.id, required this.title, required this.date, required this.isUrgent});
  final String id;
  final String title;
  final String date;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            if (isUrgent)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 0.5),
                ),
                child: const Text('필독', style: TextStyle(fontSize: 9, color: AppColors.error, fontWeight: FontWeight.w800)),
              ),
            Expanded(
              child: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text(date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}
