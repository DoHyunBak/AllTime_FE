import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/survey_provider.dart';

class SurveyScreen extends ConsumerWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyProvider);
    final isAdmin = ref.watch(isAdminProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: surveys.isEmpty
          ? Center(
              child: Text('진행 중인 설문이 없습니다', style: TextStyle(color: Colors.white.withValues(alpha: 0.4))),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: surveys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (ctx, i) => _SurveyCard(survey: surveys[i]),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              elevation: 0,
              shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CreateSurveySheet(ref: ref),
    );
  }
}

// ─────────────────────────────────────────────────────────
// 설문 카드 (학생 응답 + 결과 보기)
// ─────────────────────────────────────────────────────────
class _SurveyCard extends ConsumerStatefulWidget {
  const _SurveyCard({required this.survey});
  final Survey survey;

  @override
  ConsumerState<_SurveyCard> createState() => _SurveyCardState();
}

class _SurveyCardState extends ConsumerState<_SurveyCard> {
  String? _selectedOption;
  bool _showResult = false;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(surveyProvider.notifier);
    final surveys = ref.watch(surveyProvider);
    final survey = surveys.firstWhere((s) => s.id == widget.survey.id);
    final hasVoted = notifier.hasVoted(survey.id);
    final showResult = hasVoted || _showResult || survey.isExpired;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
              if (survey.isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('종료', style: TextStyle(fontSize: 10, color: Colors.white54)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 0.5),
                  ),
                  child: Text(
                    'D-${survey.expiresAt.difference(DateTime.now()).inDays}',
                    style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            survey.description,
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 16),

          // 옵션 목록
          ...survey.options.map((option) {
            final ratio = survey.totalVotes == 0 ? 0.0 : option.votes / survey.totalVotes;

            return GestureDetector(
              onTap: showResult ? null : () => setState(() => _selectedOption = option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: showResult
                    ? _ResultBar(option: option, ratio: ratio, isTop: option.votes == survey.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b))
                    : _OptionButton(option: option, selected: _selectedOption == option.id),
              ),
            );
          }),

          // 투표 / 결과보기 버튼
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${survey.totalVoters}명 참여',
                style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
              ),
              if (!showResult)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showResult = true),
                      child: Text(
                        '결과 보기',
                        style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6), decoration: TextDecoration.underline),
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_selectedOption != null)
                      GestureDetector(
                        onTap: () {
                          notifier.vote(survey.id, _selectedOption!);
                          setState(() {});
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text('투표', style: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w800)),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.option, required this.selected});
  final SurveyOption option;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      opacity: selected ? 0.15 : 0.05,
      borderOpacity: selected ? 0.4 : 0.1,
      borderRadius: 10,
      blurSigma: 8,
      child: Text(
        option.label,
        style: TextStyle(
          fontSize: 14,
          color: selected ? Colors.white : Colors.white70,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.option, required this.ratio, required this.isTop});
  final SurveyOption option;
  final double ratio;
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      opacity: isTop ? 0.1 : 0.0,
      borderOpacity: isTop ? 0.3 : 0.1,
      borderRadius: 10,
      blurSigma: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    if (isTop) const Icon(Icons.emoji_events, size: 16, color: Colors.white),
                    if (isTop) const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        option.label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isTop ? FontWeight.w800 : FontWeight.w500,
                          color: isTop ? Colors.white : Colors.white70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isTop ? Colors.white : Colors.white.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: isTop ? Colors.white.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
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

// ─────────────────────────────────────────────────────────
// 관리자용 설문 생성 시트
// ─────────────────────────────────────────────────────────
class _CreateSurveySheet extends StatefulWidget {
  const _CreateSurveySheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateSurveySheet> createState() => _CreateSurveySheetState();
}

class _CreateSurveySheetState extends State<_CreateSurveySheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _optionControllers = [TextEditingController(), TextEditingController()];

  void _addOption() {
    if (_optionControllers.length >= 6) return;
    setState(() => _optionControllers.add(TextEditingController()));
  }

  void _submit() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final options = _optionControllers
        .map((c) => c.text.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('옵션을 2개 이상 입력해주세요')),
      );
      return;
    }

    final survey = Survey(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim(),
      options: options.asMap().entries
          .map((e) => SurveyOption(id: 'o_${e.key}', label: e.value))
          .toList(),
      createdBy: 'admin_001',
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      totalVoters: 0,
    );

    widget.ref.read(surveyProvider.notifier).addSurvey(survey);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    for (final c in _optionControllers) { c.dispose(); }
    super.dispose();
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
          left: 28,
          right: 28,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 24),
              const Text('설문 만들기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
              const SizedBox(height: 20),
              _InputField(controller: _titleController, hint: '설문 제목'),
              const SizedBox(height: 12),
              _InputField(controller: _descController, hint: '설명 (선택)', maxLines: 2),
              const SizedBox(height: 24),
              const Text('응답 옵션', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70)),
              const SizedBox(height: 12),
              ..._optionControllers.asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _InputField(controller: e.value, hint: '옵션 ${e.key + 1}'),
              )),
              if (_optionControllers.length < 6)
                GestureDetector(
                  onTap: _addOption,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.add_circle_outline, size: 18, color: Colors.white54),
                        const SizedBox(width: 8),
                        const Text('옵션 추가', style: TextStyle(fontSize: 13, color: Colors.white54, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: Text('설문 등록'.toUpperCase()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({required this.controller, required this.hint, this.maxLines = 1});
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.3)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.4), width: 1.5),
        ),
      ),
    );
  }
}
