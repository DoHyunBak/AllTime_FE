import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SurveyOption {
  const SurveyOption({required this.id, required this.label, this.votes = 0});
  final String id;
  final String label;
  final int votes;

  SurveyOption copyWith({int? votes}) =>
      SurveyOption(id: id, label: label, votes: votes ?? this.votes);
}

@immutable
class Survey {
  const Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.options,
    required this.createdBy,
    required this.expiresAt,
    required this.totalVoters,
  });

  final String id;
  final String title;
  final String description;
  final List<SurveyOption> options;
  final String createdBy;
  final DateTime expiresAt;
  final int totalVoters;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  int get totalVotes => options.fold(0, (sum, o) => sum + o.votes);

  Survey copyWithVote(String optionId) {
    return Survey(
      id: id,
      title: title,
      description: description,
      options: options.map((o) =>
          o.id == optionId ? o.copyWith(votes: o.votes + 1) : o).toList(),
      createdBy: createdBy,
      expiresAt: expiresAt,
      totalVoters: totalVoters + 1,
    );
  }
}

final _mockSurveys = [
  Survey(
    id: 's1',
    title: '6월 메뉴 선호도 조사',
    description: '6월 한 달간 가장 먹고 싶은 메뉴를 선택해주세요. 가장 많은 표를 받은 메뉴를 우선 편성합니다.',
    options: const [
      SurveyOption(id: 'o1', label: '삼겹살 구이 🥩', votes: 87),
      SurveyOption(id: 'o2', label: '부대찌개 🍲', votes: 64),
      SurveyOption(id: 'o3', label: '치킨 카레 🍛', votes: 52),
      SurveyOption(id: 'o4', label: '마라탕 🌶️', votes: 43),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 5)),
    totalVoters: 246,
  ),
  Survey(
    id: 's2',
    title: '조식 운영 시간 의견',
    description: '현재 07:00~09:00인 조식 시간을 조정하면 어떨까요? 학생 의견을 반영하겠습니다.',
    options: const [
      SurveyOption(id: 'o5', label: '현행 유지 (07:00~09:00)', votes: 112),
      SurveyOption(id: 'o6', label: '앞당김 (06:30~08:30)', votes: 78),
      SurveyOption(id: 'o7', label: '연장 (07:00~09:30)', votes: 95),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 2)),
    totalVoters: 285,
  ),
  Survey(
    id: 's3',
    title: '기숙사 자습실 운영 방식 투표',
    description: '자습실 운영 방식을 개선하고자 합니다. 선호하는 방식을 선택해주세요.',
    options: const [
      SurveyOption(id: 'o8',  label: '24시간 자유 이용', votes: 198),
      SurveyOption(id: 'o9',  label: '예약제 (2시간 단위)', votes: 143),
      SurveyOption(id: 'o10', label: '현행 유지 (06~24시)', votes: 67),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 8)),
    totalVoters: 408,
  ),
  Survey(
    id: 's4',
    title: '체육관 새 기구 추가 투표',
    description: '예산 확보로 체육관 기구를 추가합니다. 어떤 기구가 가장 필요하신가요?',
    options: const [
      SurveyOption(id: 'o11', label: '런닝머신 추가', votes: 234),
      SurveyOption(id: 'o12', label: '스쿼트 랙 추가', votes: 156),
      SurveyOption(id: 'o13', label: '요가/스트레칭 공간', votes: 89),
      SurveyOption(id: 'o14', label: '사이클 머신 추가', votes: 112),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 12)),
    totalVoters: 591,
  ),
  Survey(
    id: 's5',
    title: '기숙사 공용 공간 개선 의견',
    description: '(종료된 설문) 지난 달 실시한 공용 공간 개선 설문 결과입니다.',
    options: const [
      SurveyOption(id: 'o15', label: '게임/휴게 공간 확충', votes: 312),
      SurveyOption(id: 'o16', label: '스터디룸 증설', votes: 287),
      SurveyOption(id: 'o17', label: '카페테리아 리뉴얼', votes: 198),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().subtract(const Duration(days: 3)),
    totalVoters: 797,
  ),
];

class SurveyNotifier extends StateNotifier<List<Survey>> {
  SurveyNotifier() : super(_mockSurveys);

  // 투표한 설문 ID 기록 (중복 방지)
  final _voted = <String>{};

  bool hasVoted(String surveyId) => _voted.contains(surveyId);

  void vote(String surveyId, String optionId) {
    if (_voted.contains(surveyId)) return;
    _voted.add(surveyId);
    state = state.map((s) =>
        s.id == surveyId ? s.copyWithVote(optionId) : s).toList();
  }

  void addSurvey(Survey survey) {
    state = [survey, ...state];
  }
}

final surveyProvider = StateNotifierProvider<SurveyNotifier, List<Survey>>((ref) {
  return SurveyNotifier();
});
