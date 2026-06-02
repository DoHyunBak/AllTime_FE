import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/auth/auth_provider.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/app_background.dart';
import '../domain/survey_provider.dart';

class SurveyScreen extends ConsumerWidget {
  const SurveyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surveys = ref.watch(surveyProvider);
    final isAdmin = ref.watch(isAdminProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(
            '참여 가능한 설문', 
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87, 
              fontWeight: FontWeight.w900
            )
          ),
        ),
        body: surveys.isEmpty
            ? Center(
                child: Text(
                  '진행 중인 설문이 없습니다', 
                  style: TextStyle(
                    color: isDark ? AppColors.textMutedDark : AppColors.textSecondary, 
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                  )
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: surveys.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (ctx, i) => _SurveyCard(survey: surveys[i]),
              ),
        floatingActionButton: isAdmin
            ? FloatingActionButton(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                shape: const CircleBorder(),
                onPressed: () => _showCreateDialog(context, ref),
                child: const Icon(Icons.add_rounded, size: 28),
              )
            : null,
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryTextColor = isDark ? Colors.white : Colors.black87;

    return GlassContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  survey.title, 
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: primaryTextColor)
                ),
              ),
              const SizedBox(width: 8),
              if (survey.isExpired)
                _Badge(label: '종료됨', color: AppColors.textMuted, isDark: isDark)
              else
                _Badge(
                  label: 'D-${survey.expiresAt.difference(DateTime.now()).inDays}', 
                  color: AppColors.primary, 
                  isDark: isDark
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            survey.description, 
            style: TextStyle(
              fontSize: 13, 
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4
            )
          ),
          const SizedBox(height: 16),

          // ── 추첨 경품 안내 ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 1.0),
            ),
            child: Row(
              children: [
                const Icon(Icons.card_giftcard_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12, 
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, 
                        height: 1.3
                      ),
                      children: [
                        const TextSpan(text: '참여자 중 추첨을 통해 '),
                        TextSpan(
                          text: survey.prize,
                          style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                        const TextSpan(text: '을 드립니다!'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          ...survey.options.map((option) {
            final ratio = survey.totalVotes == 0 ? 0.0 : option.votes / survey.totalVotes;
            return GestureDetector(
              onTap: showResult ? null : () => setState(() => _selectedOption = option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: showResult
                    ? _ResultBar(
                        option: option, 
                        ratio: ratio, 
                        isTop: option.votes == survey.options.map((o) => o.votes).reduce((a, b) => a > b ? a : b),
                        isDark: isDark,
                      )
                    : _OptionButton(
                        option: option, 
                        selected: _selectedOption == option.id,
                        isDark: isDark,
                      ),
              ),
            );
          }),

          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '총 ${survey.totalVoters}명 참여 중', 
                style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textMuted, fontWeight: FontWeight.w600)
              ),
              if (!showResult)
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => setState(() => _showResult = true),
                      child: Text(
                        '결과 미리보기', 
                        style: TextStyle(
                          fontSize: 12, 
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary, 
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w600
                        )
                      ),
                    ),
                    const SizedBox(width: 16),
                    if (_selectedOption != null)
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            notifier.vote(survey.id, _selectedOption!);
                            setState(() {});
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('투표가 완료되었습니다! ${survey.prize} 추첨에 자동 응모되었습니다 🎁'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            elevation: 0,
                          ),
                          child: const Text('투표하기', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900)),
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

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color, required this.isDark});
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.0),
      ),
      child: Text(
        label, 
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w900)
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({required this.option, required this.selected, required this.isDark});
  final SurveyOption option;
  final bool selected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: selected 
            ? AppColors.primary 
            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.8)),
          width: 1.5,
        ),
      ),
      child: Text(
        option.label,
        style: TextStyle(
          fontSize: 14,
          color: selected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
          fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}

class _ResultBar extends StatelessWidget {
  const _ResultBar({required this.option, required this.ratio, required this.isTop, required this.isDark});
  final SurveyOption option;
  final double ratio;
  final bool isTop;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isTop ? AppColors.primary : (isDark ? AppColors.textMutedDark : AppColors.textMuted);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isTop 
            ? (isDark ? AppColors.primary.withValues(alpha: 0.1) : AppColors.primaryBg) 
            : (isDark ? Colors.white.withValues(alpha: 0.03) : Colors.black.withValues(alpha: 0.02)),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isTop ? AppColors.primary.withValues(alpha: 0.3) : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05)),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isTop) ...[
                const Icon(Icons.stars_rounded, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Text(
                  option.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isTop ? FontWeight.w900 : FontWeight.w600,
                    color: isTop ? AppColors.primary : (isDark ? Colors.white70 : Colors.black87),
                  ),
                ),
              ),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 8,
              backgroundColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateSurveySheet extends StatefulWidget {
  const _CreateSurveySheet({required this.ref});
  final WidgetRef ref;

  @override
  State<_CreateSurveySheet> createState() => _CreateSurveySheetState();
}

class _CreateSurveySheetState extends State<_CreateSurveySheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _prizeController = TextEditingController();
  final _optionControllers = [TextEditingController(), TextEditingController()];

  void _addOption() {
    if (_optionControllers.length >= 6) return;
    setState(() => _optionControllers.add(TextEditingController()));
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _prizeController.dispose();
    for (final c in _optionControllers) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = isDark ? Colors.white : Colors.black87;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgSurfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.5 : 0.1), blurRadius: 40, offset: const Offset(0, -10)),
        ],
      ),
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 12,
        bottom: MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: isDark ? Colors.white24 : Colors.black12, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 24),
            Text('새로운 설문 등록', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: primaryColor)),
            const SizedBox(height: 24),
            TextField(
              controller: _titleController, 
              decoration: const InputDecoration(hintText: '설문 제목을 입력해주세요'),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController, 
              maxLines: 2, 
              decoration: const InputDecoration(hintText: '설문에 대한 설명을 추가해주세요 (선택)'),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w500, fontSize: 14),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _prizeController, 
              decoration: const InputDecoration(
                hintText: '참여자 추첨 경품 (예: 스타벅스 아메리카노)', 
                prefixIcon: Icon(Icons.card_giftcard_rounded, size: 20)
              ),
              style: TextStyle(color: primaryColor, fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Text('응답 옵션 설정', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary, letterSpacing: 1.0)),
            const SizedBox(height: 12),
            ..._optionControllers.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: TextField(
                controller: e.value, 
                decoration: InputDecoration(
                  hintText: '옵션 ${e.key + 1}',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                style: TextStyle(color: primaryColor, fontWeight: FontWeight.w600, fontSize: 14),
              ),
            )),
            if (_optionControllers.length < 6)
              TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                label: const Text('옵션 추가하기', style: TextStyle(fontWeight: FontWeight.w900)),
                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity, 
              height: 56, 
              child: ElevatedButton(
                onPressed: () {
                  final title = _titleController.text.trim();
                  if (title.isEmpty) return;
                  final options = _optionControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
                  if (options.length < 2) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('최소 2개 이상의 옵션이 필요합니다.')));
                    return;
                  }
                  widget.ref.read(surveyProvider.notifier).addSurvey(Survey(
                    id: 's_${DateTime.now().millisecondsSinceEpoch}',
                    title: title,
                    description: _descController.text.trim(),
                    options: options.asMap().entries.map((e) => SurveyOption(id: 'o_${e.key}', label: e.value)).toList(),
                    createdBy: 'admin',
                    expiresAt: DateTime.now().add(const Duration(days: 7)),
                    totalVoters: 0,
                    prize: _prizeController.text.trim().isEmpty ? '커피 기프티콘' : _prizeController.text.trim(),
                  ));
                  Navigator.pop(context);
                }, 
                child: const Text('설문 게시하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900))
              )
            ),
          ],
        ),
      ),
    );
  }
}
