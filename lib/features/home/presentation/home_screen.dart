import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:go_router/go_router.dart';
import '../../../core/network/connectivity.dart';
import '../../../core/auth/auth_provider.dart';
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
    // 첫 프레임 이후 위치 기반 기숙사 감지 시작 (5초 후 팝업)
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
    final isOffline = ref.watch(isOfflineProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // NFC 기숙사 모드
                const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [NfcSimulateButton()],
                ),
                const SizedBox(height: 12),

                // 시설 퀵 상태
                _FacilityQuickStatus(),
                const SizedBox(height: 24),

                // 공지사항
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(
                        title: '공지사항',
                        titleColor: Colors.white,
                        onMore: () => context.push('/board/notice'),
                      ),
                      const SizedBox(height: 12),
                      ..._mockAnnouncements.asMap().entries.map((e) {
                        final id = 'n${e.key + 1}'; // n1, n2, n3
                        return _AnnouncementItem(
                          id: id,
                          title: e.value.title,
                          date: e.value.date,
                          isUrgent: e.value.isUrgent,
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // HOT 게시글
                GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeading(
                        title: 'HOT 게시글',
                        titleColor: Colors.white.withValues(alpha: 0.9),
                        onMore: () => context.push('/board/hot'),
                      ),
                      const SizedBox(height: 12),
                      ..._mockHotPosts.asMap().entries.map((e) {
                        final id = 'p${e.key + 1}'; // p1, p2, p3
                        return _PostItem(id: id, title: e.value.title, date: e.value.date);
                      }),
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
          const Text(
            '시설 현황',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _QuickStatusChip(
                icon: Icons.local_laundry_service,
                label: '세탁기',
                status: '3대 가능',
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              _QuickStatusChip(
                icon: Icons.fitness_center,
                label: '체육관',
                status: '여유',
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              _QuickStatusChip(
                icon: Icons.restaurant,
                label: '식당',
                status: '11:30 점심',
                color: Colors.white,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickStatusChip extends StatelessWidget {
  const _QuickStatusChip({
    required this.icon,
    required this.label,
    required this.status,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        borderRadius: 12,
        opacity: 0.1,
        borderOpacity: 0.1,
        blurSigma: 8,
        child: Column(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: color.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 4),
            Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({
    required this.title,
    required this.titleColor,
    required this.onMore,
  });

  final String title;
  final Color titleColor;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: titleColor,
          ),
        ),
        GestureDetector(
          onTap: onMore,
          child: Text(
            '더보기',
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5)),
          ),
        ),
      ],
    );
  }
}

class _AnnouncementItem extends StatelessWidget {
  const _AnnouncementItem({
    required this.id,
    required this.title,
    required this.date,
    required this.isUrgent,
  });

  final String id;
  final String title;
  final String date;
  final bool isUrgent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/$id'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (isUrgent)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                ),
                child: const Text(
                  '필독',
                  style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800),
                ),
              ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
            ),
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
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              date,
              style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
            ),
          ],
        ),
      ),
    );
  }
}
