import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/liquid_glass.dart';
import '../../../shared/widgets/toss.dart';
import '../domain/inter_school_provider.dart';

class InterSchoolScreen extends ConsumerStatefulWidget {
  const InterSchoolScreen({super.key});

  @override
  ConsumerState<InterSchoolScreen> createState() => _InterSchoolScreenState();
}

class _InterSchoolScreenState extends ConsumerState<InterSchoolScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('기숙사 네트워크',
              style: TextStyle(
                  color: isDark ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.w900)),
          bottom: TabBar(
            controller: _tab,
            labelColor: isDark ? Colors.white : AppColors.primary,
            unselectedLabelColor:
                isDark ? AppColors.textMutedDark : AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
            unselectedLabelStyle:
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            tabs: const [Tab(text: '자치회'), Tab(text: '타 학교'), Tab(text: '대항전')],
          ),
        ),
        body: TabBarView(
          controller: _tab,
          children: [
            _CouncilTab(),
            _OtherSchoolTab(),
            _MatchTab(isAdmin: isAdmin),
          ],
        ),
      ),
    );
  }
}

class _CouncilTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(councilNoticeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              const Icon(Icons.groups_rounded,
                  color: AppColors.primary, size: 24),
              const SizedBox(width: 12),
              Text('기숙사 자치회 공지',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : Colors.black87)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...notices.map((n) => _CouncilItem(notice: n)),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit_note_rounded, size: 20),
            label: const Text('자치회 건의사항 제출',
                style: TextStyle(fontWeight: FontWeight.w900)),
          ),
        ),
      ],
    );
  }
}

class _CouncilItem extends StatelessWidget {
  const _CouncilItem({required this.notice});
  final CouncilNotice notice;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.primary.withValues(alpha: 0.15)
                  : AppColors.primaryBg,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3), width: 1),
            ),
            child: Text(notice.category,
                style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w900)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(notice.title,
                style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.white : Colors.black87,
                    fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Text(notice.date,
              style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _OtherSchoolTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(schoolDormListProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemBuilder: (ctx, i) =>
          Appear(index: i, child: _SchoolCard(school: schools[i])),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school});
  final SchoolDorm school;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final mutedTextColor =
        isDark ? AppColors.textMutedDark : AppColors.textSecondary;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${school.schoolName} · ${school.dormName}',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: primaryTextColor)),
          const SizedBox(height: 16),
          _InfoSection(
              label: '오늘 메뉴',
              value: school.todayMenus.join(' · '),
              color: primaryTextColor,
              labelColor: mutedTextColor),
          const SizedBox(height: 12),
          _InfoSection(
              label: '인기 메뉴',
              value: school.popularMenus.join(', '),
              color: mutedTextColor,
              labelColor: mutedTextColor),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _FacilityChip(
                  icon: Icons.fitness_center_rounded,
                  label: '머신 ${school.gymMachineCount}대'),
              _FacilityChip(
                  icon: Icons.local_laundry_service_rounded,
                  label: '세탁기 ${school.laundryCount}대'),
              if (school.hasPool)
                const _FacilityChip(icon: Icons.pool_rounded, label: '수영장'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection(
      {required this.label,
      required this.value,
      required this.color,
      required this.labelColor});
  final String label;
  final String value;
  final Color color;
  final Color labelColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: labelColor,
                letterSpacing: 1.0)),
        const SizedBox(height: 4),
        Text(value,
            style: TextStyle(
                fontSize: 13, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderLight, width: 1.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label,
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _MatchTab extends ConsumerWidget {
  const _MatchTab({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: matches.isEmpty
          ? Center(
              child: Text('진행 중인 대항전이 없습니다',
                  style: TextStyle(
                      color: isDark
                          ? AppColors.textMutedDark
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (ctx, i) =>
                  Appear(index: i, child: _MatchCard(match: matches[i])),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: const CircleBorder(),
              onPressed: () => _showCreateSheet(context, ref),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }

  void _showCreateSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateMatchSheet(ref: ref),
    );
  }
}

class _MatchCard extends ConsumerWidget {
  const _MatchCard({required this.match});
  final InterSchoolMatch match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(matchProvider.notifier);
    final hasApplied = notifier.hasApplied(match.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    final (statusLabel, statusColor, statusBg) = switch (match.status) {
      MatchStatus.recruiting => (
          '참가모집',
          AppColors.available,
          isDark
              ? AppColors.available.withValues(alpha: 0.15)
              : AppColors.primaryBg
        ),
      MatchStatus.scheduled => (
          '확정예정',
          AppColors.info,
          isDark
              ? AppColors.info.withValues(alpha: 0.15)
              : const Color(0xFFF0F7FF)
        ),
      MatchStatus.completed => (
          '종료됨',
          AppColors.textMuted,
          isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.bgElevated
        ),
    };

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(match.sport, style: const TextStyle(fontSize: 20)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: statusColor.withValues(alpha: 0.3), width: 1.0),
                ),
                child: Text(statusLabel,
                    style: TextStyle(
                        fontSize: 11,
                        color: statusColor,
                        fontWeight: FontWeight.w900)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Text(match.hostSchool,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor)),
                    const SizedBox(height: 4),
                    const Text('우리 학교',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('VS',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondary.withValues(alpha: 0.5))),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(match.guestSchool,
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: primaryTextColor)),
                    const SizedBox(height: 4),
                    const Text('상대 학교',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.scheduledAt.month}월 ${match.scheduledAt.day}일 예정',
                    style: TextStyle(
                        fontSize: 13,
                        color: primaryTextColor,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '현재 ${match.applicants}명 / 정원 ${match.maxPlayers}명',
                    style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textMutedDark
                            : AppColors.textSecondary),
                  ),
                ],
              ),
              if (match.status == MatchStatus.recruiting && !match.isFull)
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: hasApplied
                        ? null
                        : () {
                            notifier.apply(match.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('참가 신청이 완료되었습니다!')));
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: hasApplied
                          ? (isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : AppColors.bgElevated)
                          : AppColors.primary,
                      foregroundColor:
                          hasApplied ? AppColors.textMuted : Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      elevation: 0,
                    ),
                    child: Text(hasApplied ? '신청완료' : '참가신청',
                        style: const TextStyle(
                            fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CreateMatchSheet extends StatefulWidget {
  const _CreateMatchSheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateMatchSheet> createState() => _CreateMatchSheetState();
}

class _CreateMatchSheetState extends State<_CreateMatchSheet> {
  String _sport = '⚽ 축구';
  final _guestController = TextEditingController();
  int _maxPlayers = 11;
  final _sports = ['⚽ 축구', '🏀 농구', '🏸 배드민턴', '🏐 배구', '⚾ 야구'];

  @override
  void dispose() {
    _guestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black87;

    return LiquidGlass(
      tier: LiquidGlassTier.tier1,
      borderRadius: 28,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          Text('새로운 대항전 등록',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: primaryColor)),
          const SizedBox(height: 20),
          Text('종목 선택',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary,
                  letterSpacing: 1.0)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sports
                .map((s) => GestureDetector(
                      onTap: () => setState(() => _sport = s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: _sport == s
                              ? AppColors.primary
                              : (isDark
                                  ? Colors.white.withValues(alpha: 0.05)
                                  : AppColors.bgElevated),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                              color: _sport == s
                                  ? AppColors.primary
                                  : Colors.transparent),
                        ),
                        child: Text(s,
                            style: TextStyle(
                                fontSize: 13,
                                color: _sport == s
                                    ? Colors.white
                                    : (isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textPrimary),
                                fontWeight: FontWeight.w900)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 24),
          Text('상대 학교명',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? AppColors.textMutedDark
                      : AppColors.textSecondary,
                  letterSpacing: 1.0)),
          const SizedBox(height: 10),
          TextField(
            controller: _guestController,
            decoration: const InputDecoration(hintText: '예: 한국대학교 (캠퍼스명)'),
            style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text('모집 인원 (정원)',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: primaryColor)),
              const Spacer(),
              _CounterButton(
                  icon: Icons.remove_rounded,
                  onTap: () {
                    if (_maxPlayers > 1) setState(() => _maxPlayers--);
                  }),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text('$_maxPlayers명',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: primaryColor)),
              ),
              _CounterButton(
                  icon: Icons.add_rounded,
                  onTap: () => setState(() => _maxPlayers++),
                  color: AppColors.primary),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                  onPressed: () {
                    final guest = _guestController.text.trim();
                    if (guest.isEmpty) return;
                    widget.ref
                        .read(matchProvider.notifier)
                        .addMatch(InterSchoolMatch(
                          id: 'm_${DateTime.now().millisecondsSinceEpoch}',
                          sport: _sport,
                          hostSchool: '우리 학교',
                          guestSchool: guest,
                          scheduledAt:
                              DateTime.now().add(const Duration(days: 14)),
                          status: MatchStatus.recruiting,
                          applicants: 0,
                          maxPlayers: _maxPlayers,
                        ));
                    Navigator.pop(context);
                  },
                  child: const Text('대항전 공고 올리기',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900)))),
        ],
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  const _CounterButton({required this.icon, required this.onTap, this.color});
  final IconData icon;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color?.withValues(alpha: 0.1) ??
              (isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05)),
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            size: 20,
            color: color ?? (isDark ? Colors.white60 : Colors.black45)),
      ),
    );
  }
}
