import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────
// 타 학교 기숙사 정보
// ─────────────────────────────────────────────────────────
@immutable
class SchoolDorm {
  const SchoolDorm({
    required this.id,
    required this.schoolName,
    required this.dormName,
    required this.todayMenus,
    required this.popularMenus,
    required this.gymMachineCount,
    required this.laundryCount,
    required this.hasPool,
  });

  final String id;
  final String schoolName;
  final String dormName;
  final List<String> todayMenus;
  final List<String> popularMenus;
  final int gymMachineCount;
  final int laundryCount;
  final bool hasPool;
}

final _mockSchools = [
  const SchoolDorm(
    id: 'school_01',
    schoolName: '연세대학교',
    dormName: '우정원',
    todayMenus: ['된장찌개 백반', '돈까스', '비빔밥'],
    popularMenus: ['삼겹살 정식 ⭐4.9', '제육볶음 ⭐4.7'],
    gymMachineCount: 45,
    laundryCount: 24,
    hasPool: true,
  ),
  const SchoolDorm(
    id: 'school_02',
    schoolName: '고려대학교',
    dormName: '안암학사',
    todayMenus: ['김치찌개', '치킨 카레', '잡채밥'],
    popularMenus: ['부대찌개 ⭐4.8', '마라탕 ⭐4.6'],
    gymMachineCount: 38,
    laundryCount: 18,
    hasPool: false,
  ),
  const SchoolDorm(
    id: 'school_03',
    schoolName: '서강대학교',
    dormName: '곤자가 국제학사',
    todayMenus: ['순두부찌개', '제육볶음', '쌀국수'],
    popularMenus: ['닭갈비 ⭐4.7', '낙지볶음 ⭐4.5'],
    gymMachineCount: 20,
    laundryCount: 12,
    hasPool: false,
  ),
];

final schoolDormListProvider = Provider<List<SchoolDorm>>((ref) => _mockSchools);

// ─────────────────────────────────────────────────────────
// 학교간 대항전
// ─────────────────────────────────────────────────────────
enum MatchStatus { recruiting, scheduled, completed }

@immutable
class InterSchoolMatch {
  const InterSchoolMatch({
    required this.id,
    required this.sport,
    required this.hostSchool,
    required this.guestSchool,
    required this.scheduledAt,
    required this.status,
    required this.applicants,
    required this.maxPlayers,
  });

  final String id;
  final String sport;
  final String hostSchool;
  final String guestSchool;
  final DateTime scheduledAt;
  final MatchStatus status;
  final int applicants;
  final int maxPlayers;

  bool get isFull => applicants >= maxPlayers;
}

final _mockMatches = [
  InterSchoolMatch(
    id: 'm1',
    sport: '⚽ 축구',
    hostSchool: '우리 학교',
    guestSchool: '연세대학교',
    scheduledAt: DateTime.now().add(const Duration(days: 7)),
    status: MatchStatus.recruiting,
    applicants: 8,
    maxPlayers: 11,
  ),
  InterSchoolMatch(
    id: 'm2',
    sport: '🏀 농구',
    hostSchool: '우리 학교',
    guestSchool: '고려대학교',
    scheduledAt: DateTime.now().add(const Duration(days: 14)),
    status: MatchStatus.recruiting,
    applicants: 3,
    maxPlayers: 5,
  ),
  InterSchoolMatch(
    id: 'm3',
    sport: '🏸 배드민턴',
    hostSchool: '연세대학교',
    guestSchool: '우리 학교',
    scheduledAt: DateTime.now().add(const Duration(days: 3)),
    status: MatchStatus.scheduled,
    applicants: 4,
    maxPlayers: 4,
  ),
];

class MatchNotifier extends StateNotifier<List<InterSchoolMatch>> {
  MatchNotifier() : super(_mockMatches);

  final _applied = <String>{};

  bool hasApplied(String matchId) => _applied.contains(matchId);

  void apply(String matchId) {
    if (_applied.contains(matchId)) return;
    _applied.add(matchId);
    state = state.map((m) => m.id == matchId
        ? InterSchoolMatch(
            id: m.id,
            sport: m.sport,
            hostSchool: m.hostSchool,
            guestSchool: m.guestSchool,
            scheduledAt: m.scheduledAt,
            status: m.status,
            applicants: m.applicants + 1,
            maxPlayers: m.maxPlayers,
          )
        : m).toList();
  }

  void addMatch(InterSchoolMatch match) {
    state = [match, ...state];
  }
}

final matchProvider = StateNotifierProvider<MatchNotifier, List<InterSchoolMatch>>((ref) {
  return MatchNotifier();
});

// ─────────────────────────────────────────────────────────
// 자치회
// ─────────────────────────────────────────────────────────
@immutable
class CouncilNotice {
  const CouncilNotice({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.content,
  });

  final String id;
  final String title;
  final String category;
  final String date;
  final String content;
}

final _mockCouncilNotices = [
  const CouncilNotice(
    id: 'c1',
    title: '6월 자치회비 사용 내역 공고',
    category: '재정',
    date: '06.01',
    content: '세탁기 수리비 80,000원, 공용 냉장고 구입 120,000원...',
  ),
  const CouncilNotice(
    id: 'c2',
    title: '기숙사 편의시설 개선 건의 접수',
    category: '건의함',
    date: '05.28',
    content: '기숙사 생활 개선을 위한 건의사항을 접수합니다.',
  ),
  const CouncilNotice(
    id: 'c3',
    title: '6월 입사 환영회 개최 안내',
    category: '행사',
    date: '05.25',
    content: '신입생 및 복학생을 위한 환영회를 개최합니다.',
  ),
];

final councilNoticeProvider = Provider<List<CouncilNotice>>((ref) => _mockCouncilNotices);
