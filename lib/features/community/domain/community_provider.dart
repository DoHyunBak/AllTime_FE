import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final _mockBoards = [
  const Board(id: 'notice', name: '공지사항', description: '기숙사 주요 공지사항', postCount: 15),
  const Board(id: 'hot', name: 'HOT 게시글', description: '지금 가장 뜨거운 게시글', postCount: 20),
  const Board(id: 'dorm_dongwon', name: '인재관', description: '인재관 전용 게시판', postCount: 142),
  const Board(id: 'dorm_hyosung', name: '효성관', description: '효성관 전용 게시판', postCount: 98),
  const Board(id: 'dorm_hanwha', name: '한화관', description: '한화관 전용 게시판', postCount: 115),
  const Board(id: 'delivery', name: '배달 공동구매', description: '같이 시켜요', postCount: 67),
  const Board(id: 'roommate', name: '룸메이트 구함', description: '룸메이트를 찾아요', postCount: 23),
  const Board(id: 'lost', name: '분실물', description: '잃어버린 물건을 찾아요', postCount: 31),
  const Board(id: 'free', name: '자유게시판', description: '자유롭게 이야기해요', postCount: 289),
];

final _mockPosts = [
  const Post(id: 'n1', boardId: 'notice', title: '[필독] 6월 귀가 시간 변경 안내', author: '관리자', date: '06.02', viewCount: 512, commentCount: 0, isHot: true),
  const Post(id: 'n2', boardId: 'notice', title: '냉방 가동 시작 (6/5~)', author: '관리자', date: '06.01', viewCount: 420, commentCount: 0),
  const Post(id: 'n3', boardId: 'notice', title: '6월 세탁실 정기점검 일정', author: '관리자', date: '05.30', viewCount: 310, commentCount: 0),
  const Post(id: 'p1', boardId: 'dorm_dongwon', title: '에어컨 고장 신고합니다 301호', author: '익명', date: '06.02', viewCount: 87, commentCount: 12, isHot: true),
  const Post(id: 'p2', boardId: 'delivery', title: '치킨 공동구매 4명 모집 (인재관)', author: '익명', date: '06.02', viewCount: 54, commentCount: 8, isHot: true),
  const Post(id: 'p3', boardId: 'lost', title: '우산 잃어버리신 분? (로비)', author: '익명', date: '06.01', viewCount: 32, commentCount: 3, isHot: true),
  const Post(id: 'p4', boardId: 'free', title: '기말고사 스터디 같이 할 사람', author: '익명', date: '06.01', viewCount: 61, commentCount: 15, isHot: true),
  const Post(id: 'p5', boardId: 'dorm_hyosung', title: '효성관 엘리베이터 언제 고쳐주나요', author: '익명', date: '05.31', viewCount: 103, commentCount: 22, isHot: true),
];

final boardListProvider = Provider<List<Board>>((ref) => _mockBoards.where((b) => b.id != 'notice' && b.id != 'hot').toList());

final postListProvider = Provider.family<List<Post>, String?>((ref, boardId) {
  if (boardId == null) return _mockPosts;
  if (boardId == 'hot') return _mockPosts.where((p) => p.isHot).toList();
  return _mockPosts.where((p) => p.boardId == boardId).toList();
});
