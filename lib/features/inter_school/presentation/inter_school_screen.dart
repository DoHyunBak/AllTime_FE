import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
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

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('기숙사 네트워크', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
          bottom: TabBar(
            controller: _tab,
            labelColor: AppColors.textPrimary,
            unselectedLabelColor: AppColors.textMuted,
            indicatorColor: AppColors.primary,
            indicatorWeight: 2.5,
            labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontSize: 13),
            tabs: const [Tab(text: '자치회'), Tab(text: '타 학교'), Tab(text: '학교 대항전')],
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

// ── 자치회 탭 ─────────────────────────────────────────────────────────

class _CouncilTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(councilNoticeProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(Icons.groups, color: AppColors.primary, size: 22),
              SizedBox(width: 12),
              Text('기숙사 자치회', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ...notices.map((n) => _CouncilItem(notice: n)),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 16),
          label: Text('건의사항 제출'.toUpperCase()),
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
    return GlassContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Text(notice.category, style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(notice.title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 10),
          Text(notice.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
        ],
      ),
    );
  }
}

// ── 타 학교 탭 ─────────────────────────────────────────────────────────

class _OtherSchoolTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(schoolDormListProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: schools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (ctx, i) => _SchoolCard(school: schools[i]),
    );
  }
}

class _SchoolCard extends StatelessWidget {
  const _SchoolCard({required this.school});
  final SchoolDorm school;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${school.schoolName} · ${school.dormName}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 14),
          const Text('오늘 메뉴', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          Text(school.todayMenus.join(' · '), style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
          const SizedBox(height: 10),
          const Text('인기 메뉴', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 5),
          Text(school.popularMenus.join(', '), style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),
          Row(
            children: [
              _FacilityChip(icon: Icons.fitness_center, label: '머신 ${school.gymMachineCount}대'),
              const SizedBox(width: 8),
              _FacilityChip(icon: Icons.local_laundry_service, label: '세탁기 ${school.laundryCount}대'),
              if (school.hasPool) ...[
                const SizedBox(width: 8),
                const _FacilityChip(icon: Icons.pool, label: '수영장'),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _FacilityChip extends StatelessWidget {
  const _FacilityChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── 학교 대항전 탭 ─────────────────────────────────────────────────────

class _MatchTab extends ConsumerWidget {
  const _MatchTab({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: matches.isEmpty
          ? const Center(child: Text('예정된 대항전이 없습니다', style: TextStyle(color: AppColors.textMuted, fontSize: 14)))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _MatchCard(match: matches[i]),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              onPressed: () => _showCreateSheet(context, ref),
              child: const Icon(Icons.add),
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

    final (statusLabel, statusColor, statusBg) = switch (match.status) {
      MatchStatus.recruiting => ('모집중', AppColors.available,   AppColors.primaryBg),
      MatchStatus.scheduled  => ('확정',  AppColors.info,         const Color(0xFFEFF5FF)),
      MatchStatus.completed  => ('종료',  AppColors.textMuted,    AppColors.bgElevated),
    };

    return GlassContainer(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(match.sport, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(statusLabel, style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w800)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(match.hostSchool, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.textMuted)),
              ),
              Text(match.guestSchool, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${match.scheduledAt.month}/${match.scheduledAt.day} · ${match.applicants}/${match.maxPlayers}명',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w500),
              ),
              if (match.status == MatchStatus.recruiting && !match.isFull)
                GestureDetector(
                  onTap: hasApplied ? null : () {
                    notifier.apply(match.id);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('참가 신청 완료!')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: hasApplied ? AppColors.bgElevated : AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: hasApplied ? AppColors.borderLight : AppColors.primary),
                    ),
                    child: Text(
                      hasApplied ? '신청완료' : '참가 신청',
                      style: TextStyle(fontSize: 12, color: hasApplied ? AppColors.textMuted : Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 대항전 등록 시트 ───────────────────────────────────────────────────

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

  void _submit() {
    final guest = _guestController.text.trim();
    if (guest.isEmpty) return;
    widget.ref.read(matchProvider.notifier).addMatch(InterSchoolMatch(
      id: 'm_${DateTime.now().millisecondsSinceEpoch}',
      sport: _sport,
      hostSchool: '우리 학교',
      guestSchool: guest,
      scheduledAt: DateTime.now().add(const Duration(days: 14)),
      status: MatchStatus.recruiting,
      applicants: 0,
      maxPlayers: _maxPlayers,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bgSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36, height: 4,
              decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Text('대항전 공고 등록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 16),
          const Text('종목', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _sports.map((s) => GestureDetector(
              onTap: () => setState(() => _sport = s),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: _sport == s ? AppColors.primaryBg : AppColors.bgElevated,
                  border: Border.all(color: _sport == s ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(s, style: TextStyle(fontSize: 13, color: _sport == s ? AppColors.primary : AppColors.textSecondary, fontWeight: _sport == s ? FontWeight.w700 : FontWeight.w500)),
              ),
            )).toList(),
          ),
          const SizedBox(height: 20),
          const Text('상대 학교', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.5)),
          const SizedBox(height: 8),
          TextField(controller: _guestController, decoration: const InputDecoration(hintText: '예: 연세대학교')),
          const SizedBox(height: 20),
          Row(
            children: [
              const Text('모집 인원', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const Spacer(),
              IconButton(onPressed: () { if (_maxPlayers > 2) setState(() => _maxPlayers--); }, icon: const Icon(Icons.remove_circle_outline, size: 22, color: AppColors.textMuted)),
              Text('$_maxPlayers명', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              IconButton(onPressed: () => setState(() => _maxPlayers++), icon: const Icon(Icons.add_circle_outline, size: 22, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text('공고 등록'.toUpperCase()))),
        ],
      ),
    );
  }
}
