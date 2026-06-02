import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Models ────────────────────────────────────────────────────────────

@immutable
class Board {
  const Board({required this.id, required this.name, required this.description, required this.postCount});
  final String id;
  final String name;
  final String description;
  final int postCount;
}

@immutable
class Post {
  const Post({
    required this.id,
    required this.boardId,
    required this.title,
    required this.author,
    required this.date,
    required this.viewCount,
    required this.commentCount,
    this.isHot = false,
  });
  final String id;
  final String boardId;
  final String title;
  final String author;
  final String date;
  final int viewCount;
  final int commentCount;
  final bool isHot;
}

@immutable
class Comment {
  const Comment({
    required this.id,
    required this.postId,
    required this.author,
    required this.content,
    required this.date,
  });
  final String id;
  final String postId;
  final String author;
  final String content;
  final String date;
}

// ── Mock boards ───────────────────────────────────────────────────────

final _mockBoards = [
  const Board(id: 'notice',      name: '공지사항',      description: '기숙사 주요 공지사항',    postCount: 18),
  const Board(id: 'hot',         name: 'HOT 게시글',   description: '지금 가장 뜨거운 게시글', postCount: 25),
  const Board(id: 'dorm_dongwon',name: '인재관',        description: '인재관 전용 게시판',       postCount: 187),
  const Board(id: 'dorm_hyosung',name: '효성관',        description: '효성관 전용 게시판',       postCount: 134),
  const Board(id: 'dorm_hanwha', name: '한화관',        description: '한화관 전용 게시판',       postCount: 152),
  const Board(id: 'delivery',    name: '배달 공동구매', description: '같이 시켜요',              postCount: 89),
  const Board(id: 'roommate',    name: '룸메이트 구함', description: '룸메이트를 찾아요',        postCount: 41),
  const Board(id: 'lost',        name: '분실물',        description: '잃어버린 물건을 찾아요',  postCount: 53),
  const Board(id: 'free',        name: '자유게시판',    description: '자유롭게 이야기해요',      postCount: 312),
];

// ── Mock posts ────────────────────────────────────────────────────────

final _mockPosts = [
  // 공지사항
  const Post(id: 'n1',  boardId: 'notice',      title: '[필독] 6월 귀가 시간 변경 안내 (통금 11시→12시)',       author: '관리자', date: '06.02', viewCount: 845, commentCount: 0,  isHot: true),
  const Post(id: 'n2',  boardId: 'notice',      title: '냉방 가동 시작 (6/5~) 및 에너지 절약 안내',            author: '관리자', date: '06.01', viewCount: 620, commentCount: 0),
  const Post(id: 'n3',  boardId: 'notice',      title: '6월 세탁실 정기점검 일정 (6/8 오전 6시~12시)',          author: '관리자', date: '05.30', viewCount: 498, commentCount: 0),
  const Post(id: 'n4',  boardId: 'notice',      title: '기숙사 Wi-Fi 업그레이드 완료 안내',                     author: '관리자', date: '05.28', viewCount: 712, commentCount: 0),
  const Post(id: 'n5',  boardId: 'notice',      title: '여름학기 기숙사 신청 일정 공지',                        author: '관리자', date: '05.25', viewCount: 1243, commentCount: 0, isHot: true),

  // 인재관
  const Post(id: 'p1',  boardId: 'dorm_dongwon', title: '에어컨 고장 신고합니다 301호 — 3일째 안 나와요',        author: '익명', date: '06.02', viewCount: 187, commentCount: 14, isHot: true),
  const Post(id: 'p6',  boardId: 'dorm_dongwon', title: '인재관 공용공간 청소 당번 정하실 분?',                  author: '익명', date: '05.31', viewCount: 72,  commentCount: 9),
  const Post(id: 'p9',  boardId: 'dorm_dongwon', title: '3층 남자 샤워실 온수 나오시는 분 계세요?',              author: '익명', date: '05.30', viewCount: 55,  commentCount: 7),
  const Post(id: 'p10', boardId: 'dorm_dongwon', title: '101호 옆 자판기 고장났는데 관리실에 말해도 되나요?',     author: '익명', date: '05.29', viewCount: 43,  commentCount: 5),
  const Post(id: 'p11', boardId: 'dorm_dongwon', title: '인재관 202호 청소도구 함께 쓸 분 구합니다',             author: '익명', date: '05.28', viewCount: 31,  commentCount: 2),

  // 효성관
  const Post(id: 'p5',  boardId: 'dorm_hyosung', title: '효성관 엘리베이터 언제 고쳐주나요 벌써 2주째',          author: '익명', date: '05.31', viewCount: 213, commentCount: 24, isHot: true),
  const Post(id: 'p12', boardId: 'dorm_hyosung', title: '효성관 세탁기 예약 어떻게 하나요? 처음이라서요',         author: '익명', date: '05.30', viewCount: 88,  commentCount: 11),
  const Post(id: 'p13', boardId: 'dorm_hyosung', title: '4층 복도 LED 교체 언제 되나요',                        author: '익명', date: '05.29', viewCount: 61,  commentCount: 4),
  const Post(id: 'p14', boardId: 'dorm_hyosung', title: '효성관 1층 공용 냉장고 관리 어떻게 하고 있나요?',        author: '익명', date: '05.27', viewCount: 47,  commentCount: 6),

  // 한화관
  const Post(id: 'p8',  boardId: 'dorm_hanwha',  title: '한화관 화장실 온수 문제 해결됐나요?',                   author: '익명', date: '05.29', viewCount: 94,  commentCount: 12),
  const Post(id: 'p15', boardId: 'dorm_hanwha',  title: '한화관 헬스장 기구 추가 요청합니다 — 런닝머신 증설',     author: '익명', date: '05.28', viewCount: 156, commentCount: 18, isHot: true),
  const Post(id: 'p16', boardId: 'dorm_hanwha',  title: '한화관 3동 소음 심각해요 야간에 발소리가',              author: '익명', date: '05.27', viewCount: 103, commentCount: 15),
  const Post(id: 'p17', boardId: 'dorm_hanwha',  title: '한화관 주차장 자전거 도난당하신 분 있나요?',             author: '익명', date: '05.26', viewCount: 78,  commentCount: 8),

  // 배달 공동구매
  const Post(id: 'p2',  boardId: 'delivery',     title: '치킨 공동구매 4명 모집 (인재관 기준) 2만원대 가능',      author: '익명', date: '06.02', viewCount: 134, commentCount: 18, isHot: true),
  const Post(id: 'p18', boardId: 'delivery',     title: '피자 2판 같이 시킬 분? 6시 인재관 로비 집결',           author: '익명', date: '06.01', viewCount: 87,  commentCount: 12),
  const Post(id: 'p19', boardId: 'delivery',     title: '중식 공동구매 모집 — 짜장면+탕수육 세트',               author: '익명', date: '05.31', viewCount: 63,  commentCount: 7),
  const Post(id: 'p20', boardId: 'delivery',     title: '버거킹 세트 공동구매 3인 모집 (효성관)',                 author: '익명', date: '05.30', viewCount: 51,  commentCount: 5),
  const Post(id: 'p21', boardId: 'delivery',     title: '밤 11시 야식 떡볶이+순대 공동구매 🌙',                  author: '익명', date: '05.29', viewCount: 98,  commentCount: 22),

  // 룸메이트
  const Post(id: 'p7',  boardId: 'roommate',     title: '7월부터 룸메이트 구합니다 (남, 비흡연, 독서 위주)',      author: '익명', date: '05.30', viewCount: 68,  commentCount: 8),
  const Post(id: 'p22', boardId: 'roommate',     title: '여름학기 인재관 2인실 룸메이트 구해요 (여)',             author: '익명', date: '05.28', viewCount: 94,  commentCount: 14),
  const Post(id: 'p23', boardId: 'roommate',     title: '한화관 3인실 룸메이트 1명 추가 구합니다',               author: '익명', date: '05.27', viewCount: 52,  commentCount: 6),

  // 분실물
  const Post(id: 'p3',  boardId: 'lost',         title: '우산 잃어버리신 분? (로비 우산꽂이 근처 발견)',          author: '익명', date: '06.01', viewCount: 76,  commentCount: 5),
  const Post(id: 'p24', boardId: 'lost',         title: '에어팟 잃어버렸어요 — 효성관 1층 구내식당 근처',         author: '익명', date: '05.31', viewCount: 112, commentCount: 9,  isHot: true),
  const Post(id: 'p25', boardId: 'lost',         title: '체육관에서 운동화 가져가신 분 계신가요?',                author: '익명', date: '05.29', viewCount: 84,  commentCount: 11),
  const Post(id: 'p26', boardId: 'lost',         title: '빨간 우산 인재관 세탁실에 두고 왔는데 있으면 연락주세요', author: '익명', date: '05.28', viewCount: 37,  commentCount: 3),

  // 자유게시판
  const Post(id: 'p4',  boardId: 'free',         title: '기말고사 스터디 같이 할 사람 구해요 (도서관 5층)',        author: '익명', date: '06.01', viewCount: 143, commentCount: 28, isHot: true),
  const Post(id: 'p27', boardId: 'free',         title: '기숙사 생활 꿀팁 공유해요 — 저는 선풍기 필수!',          author: '익명', date: '05.31', viewCount: 234, commentCount: 31, isHot: true),
  const Post(id: 'p28', boardId: 'free',         title: '내일 날씨 좋다는데 치맥 같이 하실 분?',                 author: '익명', date: '05.30', viewCount: 67,  commentCount: 14),
  const Post(id: 'p29', boardId: 'free',         title: '기숙사 밥 맛있는 날 vs 별로인 날 투표',                 author: '익명', date: '05.29', viewCount: 188, commentCount: 42, isHot: true),
  const Post(id: 'p30', boardId: 'free',         title: '같이 아침 먹을 사람 구해요 7시 식당 앞에서',             author: '익명', date: '05.28', viewCount: 55,  commentCount: 8),
  const Post(id: 'p31', boardId: 'free',         title: '편의점 할인 정보 공유 — CU 1+1 리스트',                 author: '익명', date: '05.27', viewCount: 312, commentCount: 47, isHot: true),
  const Post(id: 'p32', boardId: 'free',         title: '학교 근처 맛집 추천 부탁드려요',                        author: '익명', date: '05.26', viewCount: 201, commentCount: 36),
];

// ── 대량 생성 게시글 (상용 서비스 느낌의 풍부한 데이터) ──────────────────

const _genTitlesByBoard = {
  'notice': [
    '기숙사 소방 점검 안내', '동절기 난방 운영 시간 변경', '공용 세탁실 이용 수칙 재안내',
    '분리수거 요일 변경 공지', '기숙사 출입증 재발급 안내', '여름방학 퇴실 절차 안내',
    '정전 예정 안내 (전기 안전 점검)', '기숙사 만족도 조사 실시 안내', '택배 보관소 운영 시간 변경',
    '기숙사 비상 대피 훈련 안내', '공용 냉장고 정기 청소 안내', '월별 호실 점검 일정 공지',
  ],
  'dorm_dongwon': [
    '인재관 정수기 필터 교체됐나요?', '인재관 헬스장 야간 이용 가능한가요?', '301호 와이파이 느린 분?',
    '인재관 택배 분실 주의하세요', '인재관 공용 세탁기 사용법 공유', '인재관 룸메이트 코골이 해결법 ㅠ',
    '인재관 옥상 개방 시간 아시는 분', '인재관 1층 자판기 신메뉴 들어왔어요', '인재관 복도 청소 상태 어떤가요',
    '인재관 엘리베이터 점검 일정', '인재관 샤워실 수압 약한 시간대', '인재관 흡연 구역 어디인가요',
  ],
  'dorm_hyosung': [
    '효성관 냉방 잘 되나요?', '효성관 세탁 건조기 추가됐어요!', '효성관 공용 주방 사용 가능한가요',
    '효성관 택배함 비밀번호 변경됐나요', '효성관 야간 통금 시간 문의', '효성관 4층 소음 너무 심해요',
    '효성관 정문 카드키 인식 안 됨', '효성관 헬스장 운영 시간 변경?', '효성관 분리수거장 위치',
    '효성관 룸메 구하기 어렵네요', '효성관 휴게실 TV 고장났어요', '효성관 자전거 보관소 자리 있나요',
  ],
  'dorm_hanwha': [
    '한화관 온수 언제 정상화되나요', '한화관 헬스장 기구 추가 요청', '한화관 3동 엘리베이터 느려요',
    '한화관 공용 전자레인지 청결 상태', '한화관 택배 보관함 부족해요', '한화관 야간 소음 심각합니다',
    '한화관 주차장 자전거 도난 주의', '한화관 정수기 위치 아시는 분', '한화관 세탁실 혼잡 시간대',
    '한화관 옥상 출입 가능한가요', '한화관 1층 편의점 운영 시간', '한화관 휴게실 콘센트 부족',
  ],
  'delivery': [
    '치킨 같이 시키실 분 모집', '피자 공동구매 인원 모아요', '족발보쌈 같이 드실 분?',
    '마라탕 공동구매 (효성관 집결)', '버거 세트 같이 시켜요', '야식 떡볶이 모집합니다 🌙',
    '중식 짜장면+탕수육 공구', '초밥 세트 같이 주문하실 분', '햄버거 공동구매 3인 모집',
    '닭강정 같이 시키실 분 구함', '곱창 공동구매 (한화관)', '샐러드 정기 공구 하실 분',
  ],
  'roommate': [
    '여름학기 룸메이트 구합니다 (남)', '인재관 2인실 룸메 구해요 (여)', '비흡연 룸메이트 찾습니다',
    '조용한 룸메 구함 (공부 위주)', '한화관 3인실 1명 추가 모집', '효성관 룸메 교체 원하시는 분',
    '아침형 룸메이트 구해요', '게임 좋아하는 룸메 환영', '운동 같이 할 룸메 구합니다',
    '깔끔한 룸메이트 찾아요', '2학기 룸메 미리 구해요', '국제학생 룸메 환영합니다',
  ],
  'lost': [
    '에어팟 잃어버렸어요', '우산 찾습니다 (로비)', '운동화 분실 (체육관)',
    '학생증 주우신 분 계신가요', '검정 후드집업 분실', '보조배터리 잃어버렸어요',
    '텀블러 주인 찾아요', '안경 분실했습니다 (식당)', '카드지갑 찾습니다',
    '충전기 두고 왔어요 (세탁실)', '키링 잃어버렸어요', '노트북 파우치 분실',
  ],
  'free': [
    '기숙사 생활 꿀팁 공유해요', '오늘 식당 메뉴 어땠나요', '같이 운동할 사람 구해요',
    '시험 기간 스터디 모집', '학교 근처 맛집 추천 부탁', '편의점 할인 정보 공유',
    '주말에 같이 영화 보실 분', '기숙사 와이파이 빠른 곳', '아침 같이 먹을 사람',
    '심심한데 보드게임 하실 분', '러닝 크루 모집합니다', '기숙사 입사 후기 공유',
    '다들 통금 어떻게 지키세요', '카페 같이 갈 사람 구해요', '중간고사 화이팅 글',
  ],
};

const _genAuthors = ['익명', '익명', '익명', '관리자'];

List<Post> _generateBulkPosts() {
  final result = <Post>[];
  var counter = 1000;
  final boards = _genTitlesByBoard.keys.toList();
  for (final boardId in boards) {
    final titles = _genTitlesByBoard[boardId]!;
    for (var i = 0; i < titles.length; i++) {
      counter++;
      final seed = counter * 37;
      final day = (seed % 28) + 1;
      final month = 5 + (seed % 2);
      final views = 20 + (seed % 480);
      final comments = seed % 35;
      final isHot = views > 350 || comments > 28;
      result.add(Post(
        id: 'g$counter',
        boardId: boardId,
        title: titles[i],
        author: boardId == 'notice' ? '관리자' : _genAuthors[seed % _genAuthors.length],
        date: '${month.toString().padLeft(2, '0')}.${day.toString().padLeft(2, '0')}',
        viewCount: views,
        commentCount: comments,
        isHot: isHot,
      ));
    }
  }
  return result;
}

final _allPosts = [..._mockPosts, ..._generateBulkPosts()];

// ── Post providers ────────────────────────────────────────────────────

final boardListProvider = Provider<List<Board>>((ref) {
  return _mockBoards.where((b) => b.id != 'notice' && b.id != 'hot').toList();
});

final postListProvider = Provider.family<List<Post>, String?>((ref, boardId) {
  if (boardId == null) return _allPosts;
  if (boardId == 'hot') return _allPosts.where((p) => p.isHot).toList();
  return _allPosts.where((p) => p.boardId == boardId).toList();
});

// ── Category filter ───────────────────────────────────────────────────

final selectedBoardFilterProvider = StateProvider<String?>((ref) => null);

// ── Like state ────────────────────────────────────────────────────────

class LikeState {
  const LikeState({required this.likedPostIds, required this.likeCounts});
  final Set<String> likedPostIds;
  final Map<String, int> likeCounts;

  bool isLiked(String postId) => likedPostIds.contains(postId);
  int likeCount(String postId) => likeCounts[postId] ?? 0;

  LikeState copyWith({Set<String>? likedPostIds, Map<String, int>? likeCounts}) {
    return LikeState(likedPostIds: likedPostIds ?? this.likedPostIds, likeCounts: likeCounts ?? this.likeCounts);
  }
}

// 모든 게시글에 대해 좋아요 수 시드 생성 (조회수/댓글 기반 추정)
Map<String, int> _seedLikeCounts() {
  const curated = {
    'n1': 45, 'n2': 28, 'n3': 19, 'n4': 32, 'n5': 87,
    'p1': 34, 'p2': 21, 'p3': 8,  'p4': 56, 'p5': 61,
    'p6': 12, 'p7': 7,  'p8': 18, 'p9': 5,  'p10': 4,
    'p11': 3, 'p12': 9, 'p13': 6, 'p14': 4, 'p15': 38,
    'p16': 24,'p17': 11,'p18': 15,'p19': 9, 'p20': 7,
    'p21': 28,'p22': 13,'p23': 6, 'p24': 31,'p25': 17,
    'p26': 4, 'p27': 72,'p28': 19,'p29': 64,'p30': 11,
    'p31': 94,'p32': 43,
  };
  final map = <String, int>{...curated};
  for (final p in _allPosts) {
    map.putIfAbsent(p.id, () => (p.viewCount * 0.12).round() + (p.commentCount * 2));
  }
  return map;
}

class LikeNotifier extends StateNotifier<LikeState> {
  LikeNotifier() : super(LikeState(
    likedPostIds: const {},
    likeCounts: _seedLikeCounts(),
  ));

  void toggle(String postId) {
    final liked = state.isLiked(postId);
    final count = state.likeCount(postId);
    final newLiked = Set<String>.from(state.likedPostIds);
    final newCounts = Map<String, int>.from(state.likeCounts);
    if (liked) {
      newLiked.remove(postId);
      newCounts[postId] = count - 1;
    } else {
      newLiked.add(postId);
      newCounts[postId] = count + 1;
    }
    state = state.copyWith(likedPostIds: newLiked, likeCounts: newCounts);
  }
}

final likeProvider = StateNotifierProvider<LikeNotifier, LikeState>((ref) => LikeNotifier());

// ── Comment state ─────────────────────────────────────────────────────

const _genCommentPool = [
  '저도 같은 생각이에요!', '좋은 정보 감사합니다 👍', '저도 참여하고 싶어요',
  '혹시 더 자세히 알 수 있을까요?', '완전 공감합니다 ㅋㅋ', '저만 그런 게 아니었군요',
  '관리실에 문의해보는 게 좋을 것 같아요', '오 이건 몰랐네요 감사해요', '저도 겪었던 문제예요 ㅠ',
  '도움이 많이 됐습니다!', '연락처 공유 가능할까요?', '내일 같이 가요!',
  '저도 추가해주세요~', '정말 유용한 글이네요', '빠른 해결 바랍니다',
];

// 생성된 게시글에 대한 댓글 시드
Map<String, List<Comment>> _generateBulkComments() {
  final result = <String, List<Comment>>{};
  for (final p in _allPosts) {
    if (!p.id.startsWith('g')) continue;
    if (p.commentCount == 0) continue;
    final n = p.commentCount > 4 ? 4 : p.commentCount; // 최대 4개만 시드
    final seed = int.tryParse(p.id.substring(1)) ?? 0;
    result[p.id] = List.generate(n, (i) {
      final idx = (seed * 7 + i * 13) % _genCommentPool.length;
      return Comment(
        id: '${p.id}_c$i',
        postId: p.id,
        author: '익명',
        content: _genCommentPool[idx],
        date: p.date,
      );
    });
  }
  return result;
}

class CommentNotifier extends StateNotifier<Map<String, List<Comment>>> {
  CommentNotifier() : super({
    ..._generateBulkComments(),
    'p1': const [
      Comment(id: 'c1',  postId: 'p1',  author: '익명', content: '저도 같은 문제 있어요! 301호 옆 302호인데 빨리 고쳐줬으면 좋겠네요', date: '06.02'),
      Comment(id: 'c2',  postId: 'p1',  author: '익명', content: '관리실에 연락했더니 내일 오신다고 합니다. 번호는 내선 103이에요', date: '06.02'),
      Comment(id: 'c3',  postId: 'p1',  author: '익명', content: '관리실 답변으로는 내일 오전 중 수리 기사가 방문한다네요', date: '06.02'),
    ],
    'p2': const [
      Comment(id: 'c4',  postId: 'p2',  author: '익명', content: '저 참여할게요! 카톡으로 연락 주세요', date: '06.02'),
      Comment(id: 'c5',  postId: 'p2',  author: '익명', content: '저도요! 인재관 302호입니다', date: '06.02'),
      Comment(id: 'c6',  postId: 'p2',  author: '익명', content: '몇 시에 모이실 건가요?', date: '06.02'),
    ],
    'p4': const [
      Comment(id: 'c7',  postId: 'p4',  author: '익명', content: '저도 참여하고 싶어요! 전공 뭐세요?', date: '06.01'),
      Comment(id: 'c8',  postId: 'p4',  author: '익명', content: '컴공이면 저도 같이 해요', date: '06.01'),
      Comment(id: 'c9',  postId: 'p4',  author: '익명', content: '카톡방 만들어서 공유해주시면 감사하겠습니다 ㅎㅎ', date: '06.01'),
      Comment(id: 'c10', postId: 'p4',  author: '익명', content: '오전 스터디면 저 빠질게요 ㅠ', date: '06.01'),
    ],
    'p5': const [
      Comment(id: 'c11', postId: 'p5',  author: '익명', content: '진짜 빨리 고쳐줬으면 좋겠어요. 짐 들고 올라가기 너무 힘들어요', date: '05.31'),
      Comment(id: 'c12', postId: 'p5',  author: '익명', content: '저도 매일 계단 이용하고 있어요.. 무릎이 아파요', date: '05.31'),
      Comment(id: 'c13', postId: 'p5',  author: '익명', content: '부품 조달 문제로 지연됐고 이번 주 금요일까지 수리 완료 예정이래요', date: '06.01'),
    ],
    'p15': const [
      Comment(id: 'c14', postId: 'p15', author: '익명', content: '런닝머신 2대밖에 없어서 항상 기다려요 ㅠ', date: '05.28'),
      Comment(id: 'c15', postId: 'p15', author: '익명', content: '저도 덤벨 더 늘려주셨으면 해요', date: '05.28'),
      Comment(id: 'c16', postId: 'p15', author: '익명', content: '자치회에 건의하면 어떨까요?', date: '05.29'),
    ],
    'p24': const [
      Comment(id: 'c17', postId: 'p24', author: '익명', content: '저도 비슷한 시간대에 거기 있었는데 못 봤어요 ㅠ', date: '05.31'),
      Comment(id: 'c18', postId: 'p24', author: '익명', content: 'CCTV 확인 요청해보세요', date: '05.31'),
      Comment(id: 'c19', postId: 'p24', author: '관리자', content: 'CCTV 확인 요청은 학생처 방문 또는 내선 108로 연락 주시기 바랍니다.', date: '06.01'),
    ],
    'p27': const [
      Comment(id: 'c20', postId: 'p27', author: '익명', content: '선풍기 필수 동의 ㅋㅋ 에어컨 틀어도 덥잖아요', date: '05.31'),
      Comment(id: 'c21', postId: 'p27', author: '익명', content: '저는 슬리퍼 2켤레 꼭 챙겨요! 샤워용이랑 실내용 따로', date: '05.31'),
      Comment(id: 'c22', postId: 'p27', author: '익명', content: '귀마개도 진짜 필수에요 옆방 코골이 소리 장난 아님', date: '05.31'),
      Comment(id: 'c23', postId: 'p27', author: '익명', content: '멀티탭 하나 더 챙기세요 콘센트가 부족해요', date: '06.01'),
    ],
    'p29': const [
      Comment(id: 'c24', postId: 'p29', author: '익명', content: '오늘 돈까스는 진짜 맛있었어요!', date: '05.29'),
      Comment(id: 'c25', postId: 'p29', author: '익명', content: '월요일 된장찌개는 항상 별로ㅋㅋ', date: '05.29'),
      Comment(id: 'c26', postId: 'p29', author: '익명', content: '삼겹살 나오는 날은 줄 서도 먹을만해요', date: '05.30'),
    ],
    'p31': const [
      Comment(id: 'c27', postId: 'p31', author: '익명', content: 'CU 삼각김밥 3개에 2,000원!! 오늘까지에요', date: '05.27'),
      Comment(id: 'c28', postId: 'p31', author: '익명', content: '핫식스 1+1 진짜에요? 바로 가야겠다', date: '05.27'),
      Comment(id: 'c29', postId: 'p31', author: '익명', content: '아이스크림 1+1은 매주 있으니까 참고하세요~', date: '05.28'),
      Comment(id: 'c30', postId: 'p31', author: '익명', content: '편의점 앱 깔면 추가 할인이에요! 강추', date: '05.28'),
    ],
  });

  void add(String postId, String content) {
    final now = DateTime.now();
    final date = '${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')}';
    final newComment = Comment(id: 'c${now.millisecondsSinceEpoch}', postId: postId, author: '익명', content: content, date: date);
    final updated = Map<String, List<Comment>>.from(state);
    updated[postId] = [...(updated[postId] ?? []), newComment];
    state = updated;
  }

  void delete(String postId, String commentId) {
    final updated = Map<String, List<Comment>>.from(state);
    updated[postId] = (updated[postId] ?? []).where((c) => c.id != commentId).toList();
    state = updated;
  }
}

final commentProvider = StateNotifierProvider<CommentNotifier, Map<String, List<Comment>>>(
  (ref) => CommentNotifier(),
);

final postCommentsProvider = Provider.family<List<Comment>, String>((ref, postId) {
  return ref.watch(commentProvider)[postId] ?? [];
});
