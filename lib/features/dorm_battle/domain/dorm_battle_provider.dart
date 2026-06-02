import 'package:flutter_riverpod/flutter_riverpod.dart';

// ─────────────────────────────────────────────────────────
// 데이터 모델
// ─────────────────────────────────────────────────────────

/// 기숙사 정보
enum Dormitory {
  dongwon('동원관', 'A동', '🏢'),
  hyosung('효성관', 'B동', '🏛️'),
  hanwha('한화관', 'C동', '🏗️'),
  samsung('삼성관', 'D동', '🏠');

  const Dormitory(this.name, this.shortName, this.emoji);
  final String name;
  final String shortName;
  final String emoji;
}

/// 메뉴 아이템
class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.dormitory,
    required this.voteCount,
    required this.rating, // 1.0 ~ 5.0
    this.emoji = '🍽️',
  });

  final String id;
  final String name;
  final Dormitory dormitory;
  final int voteCount;
  final double rating;
  final String emoji;
}

/// 기숙사 대결 (두 기숙사의 메뉴 1:1 투표)
class DormBattle {
  const DormBattle({
    required this.id,
    required this.title,
    required this.menuA,
    required this.menuB,
    required this.votesA,
    required this.votesB,
    required this.expiresAt,
  });

  final String id;
  final String title;
  final MenuItem menuA;
  final MenuItem menuB;
  final int votesA;
  final int votesB;
  final DateTime expiresAt;

  int get totalVotes => votesA + votesB;
  double get ratioA => totalVotes == 0 ? 0.5 : votesA / totalVotes;
  double get ratioB => totalVotes == 0 ? 0.5 : votesB / totalVotes;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

// ─────────────────────────────────────────────────────────
// Mock 데이터 (백엔드 연결 전 사용)
// ─────────────────────────────────────────────────────────

final _mockMenuRanking = [
  const MenuItem(
    id: '1',
    name: '제육볶음 정식',
    dormitory: Dormitory.dongwon,
    voteCount: 312,
    rating: 4.8,
    emoji: '🥩',
  ),
  const MenuItem(
    id: '2',
    name: '김치찌개',
    dormitory: Dormitory.hyosung,
    voteCount: 287,
    rating: 4.5,
    emoji: '🍲',
  ),
  const MenuItem(
    id: '3',
    name: '돈까스 세트',
    dormitory: Dormitory.hanwha,
    voteCount: 251,
    rating: 4.3,
    emoji: '🍛',
  ),
  const MenuItem(
    id: '4',
    name: '비빔밥',
    dormitory: Dormitory.samsung,
    voteCount: 198,
    rating: 4.1,
    emoji: '🥗',
  ),
  const MenuItem(
    id: '5',
    name: '된장찌개 백반',
    dormitory: Dormitory.dongwon,
    voteCount: 176,
    rating: 3.9,
    emoji: '🍜',
  ),
];

final _mockCurrentBattle = DormBattle(
  id: 'battle_001',
  title: '오늘의 대결',
  menuA: _mockMenuRanking[0], // 인재관 제육볶음
  menuB: _mockMenuRanking[2], // 한화관 돈까스
  votesA: 143,
  votesB: 97,
  expiresAt: DateTime.now().add(const Duration(hours: 8)),
);

// ─────────────────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────────────────

/// 오늘의 메뉴 순위
final menuRankingProvider = Provider<List<MenuItem>>((ref) {
  // TODO: 백엔드 API 연결 후 교체
  // return ref.watch(menuRankingApiProvider);
  return _mockMenuRanking;
});

/// 현재 진행 중인 대결
final currentBattleProvider =
    StateNotifierProvider<BattleNotifier, DormBattle>((ref) {
  return BattleNotifier(_mockCurrentBattle);
});

/// 내 투표 상태 ('A', 'B', 또는 null)
final myVoteProvider = StateProvider<String?>((ref) => null);

// ─────────────────────────────────────────────────────────
// StateNotifier
// ─────────────────────────────────────────────────────────

class BattleNotifier extends StateNotifier<DormBattle> {
  BattleNotifier(super.initial);

  /// A 또는 B에 투표
  void vote(String side) {
    if (state.isExpired) return;

    state = DormBattle(
      id: state.id,
      title: state.title,
      menuA: state.menuA,
      menuB: state.menuB,
      votesA: side == 'A' ? state.votesA + 1 : state.votesA,
      votesB: side == 'B' ? state.votesB + 1 : state.votesB,
      expiresAt: state.expiresAt,
    );
  }
}
