import 'dart:ui';
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
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight + 48),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                elevation: 0,
                title: const Text('기숙사 네트워크', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                iconTheme: const IconThemeData(color: Colors.white),
                bottom: TabBar(
                  controller: _tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white.withValues(alpha: 0.4),
                  indicatorColor: Colors.white,
                  indicatorWeight: 3,
                  labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  tabs: const [
                    Tab(text: '자치회'),
                    Tab(text: '타 학교'),
                    Tab(text: '학교 대항전'),
                  ],
                ),
              ),
            ),
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

// ─────────────────────────────────────────────────────────
// 자치회 탭
// ─────────────────────────────────────────────────────────
class _CouncilTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notices = ref.watch(councilNoticeProvider);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        GlassContainer(
          padding: const EdgeInsets.all(16),
          child: const Row(
            children: [
              Icon(Icons.groups, color: Colors.white, size: 22),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  '기숙사 자치회',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ...notices.map((n) => _CouncilItem(notice: n)),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add, size: 18),
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
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
            ),
            child: Text(
              notice.category,
              style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              notice.title,
              style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            notice.date,
            style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 타 학교 탭
// ─────────────────────────────────────────────────────────
class _OtherSchoolTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schools = ref.watch(schoolDormListProvider);

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: schools.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${school.schoolName} · ${school.dormName}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('오늘 메뉴', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(school.todayMenus.join(' · '), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          const Text('인기 메뉴', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white70)),
          const SizedBox(height: 6),
          Text(school.popularMenus.join(', '), style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          const SizedBox(height: 16),
          Row(
            children: [
              _FacilityChip(icon: Icons.fitness_center, label: '머신 ${school.gymMachineCount}대'),
              const SizedBox(width: 10),
              _FacilityChip(icon: Icons.local_laundry_service, label: '세탁기 ${school.laundryCount}대'),
              if (school.hasPool) ...[
                const SizedBox(width: 10),
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
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      opacity: 0.1,
      borderOpacity: 0.1,
      borderRadius: 8,
      blurSigma: 4,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white70),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 학교 대항전 탭
// ─────────────────────────────────────────────────────────
class _MatchTab extends ConsumerWidget {
  const _MatchTab({required this.isAdmin});
  final bool isAdmin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matches = ref.watch(matchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: matches.isEmpty
          ? Center(child: Text('예정된 대항전이 없습니다', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))))
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: matches.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) => _MatchCard(match: matches[i]),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              elevation: 0,
              shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              onPressed: () => _showCreateSheet(context, ref),
              child: const Icon(Icons.add, color: Colors.white),
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

    final statusLabel = switch (match.status) {
      MatchStatus.recruiting => '모집중',
      MatchStatus.scheduled => '확정',
      MatchStatus.completed => '종료',
    };
    final statusColor = switch (match.status) {
      MatchStatus.recruiting => Colors.white,
      MatchStatus.scheduled => Colors.white70,
      MatchStatus.completed => Colors.white38,
    };

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                match.sport,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(match.hostSchool, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('VS', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white54)),
              ),
              Text(match.guestSchool, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${match.scheduledAt.month}/${match.scheduledAt.day} · ${match.applicants}/${match.maxPlayers}명',
                style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.5), fontWeight: FontWeight.w600),
              ),
              if (match.status == MatchStatus.recruiting && !match.isFull)
                GestureDetector(
                  onTap: hasApplied ? null : () {
                    notifier.apply(match.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('참가 신청 완료!'),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: hasApplied ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      hasApplied ? '신청완료' : '참가 신청',
                      style: TextStyle(
                        fontSize: 13,
                        color: hasApplied ? Colors.white54 : Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
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
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1),
        ),
        padding: EdgeInsets.only(
          left: 28, right: 28, top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            const Text('대항전 공고 등록', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 20),
            const Text('종목', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _sports.map((s) => GestureDetector(
                onTap: () => setState(() => _sport = s),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: _sport == s ? Colors.white.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.1),
                    border: Border.all(color: _sport == s ? Colors.white.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.1), width: 1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: _sport == s ? FontWeight.w800 : FontWeight.w500)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 24),
            const Text('상대 학교', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
            const SizedBox(height: 12),
            TextField(
              controller: _guestController,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              decoration: InputDecoration(
                hintText: '예: 연세대학교',
                hintStyle: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('모집 인원', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
                const Spacer(),
                IconButton(onPressed: () { if (_maxPlayers > 2) setState(() => _maxPlayers--); }, icon: const Icon(Icons.remove_circle_outline, size: 24, color: Colors.white54)),
                const SizedBox(width: 8),
                Text('$_maxPlayers명', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(width: 8),
                IconButton(onPressed: () => setState(() => _maxPlayers++), icon: const Icon(Icons.add_circle_outline, size: 24, color: Colors.white)),
              ],
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
                child: Text('공고 등록'.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
