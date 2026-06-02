import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/dorm_mode/location_dorm_detector.dart';
import '../../../shared/widgets/offline_banner.dart';
import '../../../shared/widgets/dorm_mode_banner.dart';
import '../../../shared/widgets/glass_container.dart';

const _mockAnnouncements = [
  (title: '[필독] 6월 귀가 시간 변경 안내', date: '06.02', isUrgent: true),
  (title: '냉방 가동 시작 (6/5~)', date: '06.01', isUrgent: false),
  (title: '6월 세탁실 정기점검 일정', date: '05.30', isUrgent: false),
];

const _mockHotPosts = [
  (title: '인재관 301호 에어컨 고장 신고합니다', date: '06.02'),
  (title: '치킨 공동구매 4명 모집 (인재관)', date: '06.02'),
  (title: '분실물: 우산 (로비 우산꽂이)', date: '06.01'),
];

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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [NfcSimulateButton()],
                ),
                const SizedBox(height: 12),
                _FacilityQuickStatus(),
                const SizedBox(height: 20),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(title: '공지사항', onMore: () => context.push('/board/notice')),
                      const SizedBox(height: 12),
                      ..._mockAnnouncements.asMap().entries.map((e) => _AnnouncementItem(
                        id: 'n${e.key + 1}',
                        title: e.value.title,
                        date: e.value.date,
                        isUrgent: e.value.isUrgent,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(title: 'HOT 게시글', onMore: () => context.push('/board/hot')),
                      const SizedBox(height: 12),
                      ..._mockHotPosts.asMap().entries.map((e) => _PostItem(
                        id: 'p${e.key + 1}',
                        title: e.value.title,
                        date: e.value.date,
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FacilityQuickStatus extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('시설 현황', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          Row(
            children: [
              _QuickStatusChip(icon: Icons.local_laundry_service, label: '세탁기', status: '3대 가능', statusColor: AppColors.available),
              const SizedBox(width: 10),
              _QuickStatusChip(icon: Icons.fitness_center, label: '체육관', status: '여유', statusColor: AppColors.available),
              const SizedBox(width: 10),
              _QuickStatusChip(icon: Icons.restaurant, label: '식당', status: '11:30 점심', statusColor: AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatusChip extends StatelessWidget {
  const _QuickStatusChip({required this.icon, required this.label, required this.status, required this.statusColor});
  final IconData icon;
  final String label;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: AppColors.textSecondary),
            const SizedBox(height: 6),
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
            const SizedBox(height: 3),
            Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

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

class _AnnouncementItem extends StatelessWidget {
  const _AnnouncementItem({required this.id, required this.title, required this.date, required this.isUrgent});
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

class _PostItem extends StatelessWidget {
  const _PostItem({required this.id, required this.title, required this.date});
  final String id;
  final String title;
  final String date;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
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
