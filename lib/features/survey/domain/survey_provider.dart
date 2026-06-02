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
    description: '6월 한 달간 가장 먹고 싶은 메뉴를 선택해주세요.',
    options: const [
      SurveyOption(id: 'o1', label: '삼겹살 구이', votes: 87),
      SurveyOption(id: 'o2', label: '부대찌개', votes: 64),
      SurveyOption(id: 'o3', label: '치킨 카레', votes: 52),
      SurveyOption(id: 'o4', label: '마라탕', votes: 43),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 5)),
    totalVoters: 246,
  ),
  Survey(
    id: 's2',
    title: '조식 운영 시간 의견',
    description: '현재 07:00~09:00인 조식 시간을 조정하면 어떨까요?',
    options: const [
      SurveyOption(id: 'o5', label: '현행 유지 (07~09)', votes: 112),
      SurveyOption(id: 'o6', label: '앞당김 (06:30~08:30)', votes: 78),
      SurveyOption(id: 'o7', label: '연장 (07~09:30)', votes: 95),
    ],
    createdBy: 'admin_001',
    expiresAt: DateTime.now().add(const Duration(days: 2)),
    totalVoters: 285,
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
