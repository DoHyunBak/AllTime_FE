import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/dorm_battle_provider.dart';

/// 기숙사 메뉴 순위 + 대결 섹션 전체
///
/// 홈 화면에 삽입하는 복합 위젯
class DormBattleSection extends ConsumerWidget {
  const DormBattleSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ① 오늘의 대결
        _BattleCard(isDark: isDark),

        const SizedBox(height: 32),

        // ② 메뉴 인기 순위
        _MenuRankingSection(isDark: isDark),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// ① 오늘의 대결 카드
// ─────────────────────────────────────────────────────────

class _BattleCard extends ConsumerWidget {
  const _BattleCard({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final battle = ref.watch(currentBattleProvider);
    final myVote = ref.watch(myVoteProvider);
    final hasVoted = myVote != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤딩 — 위젯 스타일 (블루)
        _SectionHeader(
          title: '⚔️ 오늘의 대결',
          titleColor: isDark ? Colors.white : AppColors.textPrimary,
          badge: '투표중',
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 대결 설명
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(
                    color: isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.05), 
                    width: 0.5
                  )),
                ),
                child: Text(
                  battle.title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // 투표 구역
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    // A 진영
                    Expanded(
                      child: _VoteButton(
                        menu: battle.menuA,
                        side: 'A',
                        ratio: battle.ratioA,
                        votes: battle.votesA,
                        isSelected: myVote == 'A',
                        hasVoted: hasVoted,
                        isDark: isDark,
                        onTap: hasVoted
                            ? null
                            : () {
                                ref.read(currentBattleProvider.notifier).vote('A');
                                ref.read(myVoteProvider.notifier).state = 'A';
                              },
                      ),
                    ),

                    // VS 배지
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.textPrimary.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.textPrimary.withValues(alpha: 0.1)),
                        ),
                        child: Text(
                          'VS',
                          style: TextStyle(
                            color: isDark ? Colors.white : AppColors.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),

                    // B 진영
                    Expanded(
                      child: _VoteButton(
                        menu: battle.menuB,
                        side: 'B',
                        ratio: battle.ratioB,
                        votes: battle.votesB,
                        isSelected: myVote == 'B',
                        hasVoted: hasVoted,
                        isDark: isDark,
                        onTap: hasVoted
                            ? null
                            : () {
                                ref.read(currentBattleProvider.notifier).vote('B');
                                ref.read(myVoteProvider.notifier).state = 'B';
                              },
                      ),
                    ),
                  ],
                ),
              ),

              // 투표 바 (투표 후 표시)
              if (hasVoted) _VoteProgressBar(battle: battle, isDark: isDark),

              // 총 투표 수
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
                child: Text(
                  hasVoted ? '총 ${battle.totalVotes}명 투표 참여' : '투표하고 결과를 확인하세요!',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 개별 투표 버튼 (메뉴 카드)
class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.menu,
    required this.side,
    required this.ratio,
    required this.votes,
    required this.isSelected,
    required this.hasVoted,
    required this.isDark,
    required this.onTap,
  });

  final MenuItem menu;
  final String side;
  final double ratio;
  final int votes;
  final bool isSelected;
  final bool hasVoted;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isWinning = hasVoted && ratio >= 0.5;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isDark ? Colors.white.withValues(alpha: 0.15) : AppColors.primary.withValues(alpha: 0.1)) 
              : (isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textPrimary.withValues(alpha: 0.02)),
          border: Border.all(
            color: isSelected 
                ? (isDark ? Colors.white.withValues(alpha: 0.5) : AppColors.primary.withValues(alpha: 0.5)) 
                : (isDark ? Colors.white.withValues(alpha: 0.1) : AppColors.textPrimary.withValues(alpha: 0.05)),
            width: isSelected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // 이모지
            Text(menu.emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),

            // 메뉴명
            Text(
              menu.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isSelected 
                    ? (isDark ? Colors.white : AppColors.primary) 
                    : (isDark ? Colors.white70 : AppColors.textPrimary),
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // 기숙사명
            Text(
              menu.dormitory.name,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
              ),
            ),

            // 투표 후 비율 표시
            if (hasVoted) ...[
              const SizedBox(height: 8),
              Text(
                '${(ratio * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: isWinning 
                      ? (isDark ? Colors.white : AppColors.primary) 
                      : (isDark ? Colors.white54 : AppColors.textMuted),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 투표 결과 프로그레스 바
class _VoteProgressBar extends StatelessWidget {
  const _VoteProgressBar({required this.battle, required this.isDark});

  final DormBattle battle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          children: [
            // A 진영 바
            Expanded(
              flex: (battle.ratioA * 100).round(),
              child: Container(
                height: 8,
                color: isDark ? Colors.white.withValues(alpha: 0.6) : AppColors.primary.withValues(alpha: 0.6),
              ),
            ),
            // B 진영 바
            Expanded(
              flex: (battle.ratioB * 100).round(),
              child: Container(
                height: 8,
                color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────
// ② 메뉴 인기 순위
// ─────────────────────────────────────────────────────────

class _MenuRankingSection extends ConsumerWidget {
  const _MenuRankingSection({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ranking = ref.watch(menuRankingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: '🏆 이번 주 메뉴 인기 순위',
          titleColor: isDark ? Colors.white : AppColors.textPrimary,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        GlassContainer(
          padding: EdgeInsets.zero,
          child: Column(
            children: ranking.asMap().entries.map((entry) {
              final rank = entry.key + 1;
              final menu = entry.value;
              return _RankingItem(rank: rank, menu: menu, isLast: rank == ranking.length, isDark: isDark);
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _RankingItem extends StatelessWidget {
  const _RankingItem({required this.rank, required this.menu, required this.isLast, required this.isDark});

  final int rank;
  final MenuItem menu;
  final bool isLast;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isTop3 = rank <= 3;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textPrimary.withValues(alpha: 0.05), 
          width: 0.5
        )),
      ),
      child: Row(
        children: [
          // 순위 배지
          SizedBox(
            width: 32,
            child: isTop3
                ? Text(
                    rank == 1 ? '🥇' : rank == 2 ? '🥈' : '🥉',
                    style: const TextStyle(fontSize: 20),
                  )
                : Text(
                    '$rank',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textMuted,
                    ),
                  ),
          ),

          // 메뉴 이모지
          Text(menu.emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),

          // 메뉴명 + 기숙사
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      menu.dormitory.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // 별점
                    Row(
                      children: [
                        const Icon(Icons.star, size: 12, color: AppColors.star),
                        const SizedBox(width: 3),
                        Text(
                          menu.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 투표 수
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${menu.voteCount}표',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              // 미니 바
              _MiniVoteBar(
                count: menu.voteCount,
                maxCount: 312, // 1위 기준
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// 순위 아이템 옆 미니 투표 바
class _MiniVoteBar extends StatelessWidget {
  const _MiniVoteBar({required this.count, required this.maxCount, required this.isDark});

  final int count;
  final int maxCount;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ratio = count / maxCount;

    return Stack(
      children: [
        Container(
          width: 60,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : AppColors.textPrimary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Container(
          width: 60 * ratio,
          height: 4,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.4) : AppColors.primary.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────
// 공통 섹션 헤더
// ─────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.titleColor,
    this.badge,
    required this.isDark,
  });

  final String title;
  final Color titleColor;
  final String? badge;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: titleColor,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.2) : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.2), 
                width: 0.5
              ),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.white : AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
