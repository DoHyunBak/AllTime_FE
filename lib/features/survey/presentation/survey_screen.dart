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
          ? const Center(
              child: Text('진행 중인 설문이 없습니다', style: TextStyle(color: AppColors.textMuted, fontSize: 14)),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: surveys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (ctx, i) => _SurveyCard(survey: surveys[i]),
            ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              shape: const CircleBorder(),
              onPressed: () => _showCreateDialog(context, ref),
              child: const Icon(Icons.add),
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

// ── 설문 카드 ─────────────────────────────────────────────────────────

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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(survey.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              const SizedBox(width: 8),
              if (survey.isExpired)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(4)),
                  child: const Text('종료', style: TextStyle(fontSize: 10, color: AppColors.textMuted, fontWeight: FontWeight.w700)),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                  ),
                  child: Text(
                    'D-${survey.expiresAt.difference(DateTime.now()).inDays}',
                    style: const TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(survey.description, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 14),

          ...survey.options.map((option) {
            final ratio = survey.totalVotes == 0 ? 0.0 : option.votes / survey.totalVotes;
            return GestureDetector(
              onTap: showResult ? null : () => setState(() => _selectedOption = option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: showResult
                    ? _ResultBar(option: option, ratio: ratio, isTop: option.votes == survey.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b))
                    : _OptionButton(option: option, selected: _selectedOption == option.id),
              ),
            );
          }),

          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('총 ${survey.totalVoters}명 참여', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
              if (!showResult)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showResult = true),
                      child: const Text('결과 보기', style: TextStyle(fontSize: 12, color: AppColors.textSecondary, decoration: TextDecoration.underline)),
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
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: selected ? AppColors.primaryBg : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight),
      ),
      child: Text(
        option.label,
        style: TextStyle(
          fontSize: 14,
          color: selected ? AppColors.primary : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: isTop ? AppColors.primaryBg : AppColors.bgElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isTop ? AppColors.primary.withValues(alpha: 0.4) : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isTop) ...[
                const Icon(Icons.emoji_events, size: 15, color: AppColors.primary),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isTop ? FontWeight.w800 : FontWeight.w500,
                    color: isTop ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isTop ? AppColors.primary : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: AppColors.borderLight,
              valueColor: AlwaysStoppedAnimation<Color>(isTop ? AppColors.primary : AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 설문 생성 시트 ─────────────────────────────────────────────────────

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
    final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (options.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('옵션을 2개 이상 입력해주세요')));
      return;
    }
    final survey = Survey(
      id: 's_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: _descController.text.trim(),
      options: options.asMap().entries.map((e) => SurveyOption(id: 'o_${e.key}', label: e.value)).toList(),
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
      child: SingleChildScrollView(
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
            const Text('설문 만들기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 18),
            TextField(controller: _titleController, decoration: const InputDecoration(hintText: '설문 제목')),
            const SizedBox(height: 10),
            TextField(controller: _descController, maxLines: 2, decoration: const InputDecoration(hintText: '설명 (선택)')),
            const SizedBox(height: 20),
            const Text('응답 옵션', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
            const SizedBox(height: 10),
            ..._optionControllers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(controller: e.value, decoration: InputDecoration(hintText: '옵션 ${e.key + 1}')),
            )),
            if (_optionControllers.length < 6)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_circle_outline, size: 16),
                label: const Text('옵션 추가'),
                style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
              ),
            const SizedBox(height: 20),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text('설문 등록'.toUpperCase()))),
          ],
        ),
      ),
    );
  }
}
