import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/community_provider.dart';

class CommunityScreen extends ConsumerWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedBoard = ref.watch(selectedBoardFilterProvider);
    final boards = ref.watch(boardListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // ── 카테고리 필터 칩 ─────────────────────────────────
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: boards.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _FilterChip(
                    label: '전체',
                    isSelected: selectedBoard == null,
                    onTap: () => ref.read(selectedBoardFilterProvider.notifier).state = null,
                  );
                }
                final board = boards[index - 1];
                return _FilterChip(
                  label: board.name,
                  isSelected: selectedBoard == board.id,
                  onTap: () => ref.read(selectedBoardFilterProvider.notifier).state = board.id,
                );
              },
            ),
          ),
          const SizedBox(height: 16),

          if (selectedBoard == null) ...[
            _HotPostsSection(),
            const SizedBox(height: 16),
            _NetworkShortcut(),
            const SizedBox(height: 16),
            _BoardListSection(boards: boards),
          ] else ...[
            _FilteredPostsSection(boardId: selectedBoard, boards: boards),
          ],
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: const CircleBorder(),
        onPressed: () {},
        child: const Icon(Icons.edit),
      ),
    );
  }
}

// ── 카테고리 필터 칩 ───────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected, required this.onTap});
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBg : AppColors.bgSurface,
          borderRadius: BorderRadius.circular(500),
          border: Border.all(
            color: isSelected ? AppColors.primary.withValues(alpha: 0.6) : AppColors.borderLight,
            width: isSelected ? 1.0 : 0.5,
          ),
          boxShadow: isSelected ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

// ── HOT 게시글 ─────────────────────────────────────────────────────────

class _HotPostsSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hotPosts = ref.watch(postListProvider(null)).where((p) => p.isHot).take(3).toList();

    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('HOT 게시글', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          ...hotPosts.map((p) => _PostRow(post: p)),
        ],
      ),
    );
  }
}

// ── 기숙사 네트워크 ────────────────────────────────────────────────────

class _NetworkShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/network'),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: const Row(
          children: [
            Icon(Icons.public, color: AppColors.primary, size: 20),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('기숙사 네트워크', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                  SizedBox(height: 2),
                  Text('자치회 · 타 학교 열람 · 학교 대항전', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

// ── 게시판 목록 ────────────────────────────────────────────────────────

class _BoardListSection extends StatelessWidget {
  const _BoardListSection({required this.boards});
  final List<Board> boards;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('게시판', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          ),
          ...boards.asMap().entries.map((entry) {
            final isLast = entry.key == boards.length - 1;
            return _BoardRow(board: entry.value, isLast: isLast);
          }),
        ],
      ),
    );
  }
}

// ── 필터링된 게시글 ────────────────────────────────────────────────────

class _FilteredPostsSection extends ConsumerWidget {
  const _FilteredPostsSection({required this.boardId, required this.boards});
  final String boardId;
  final List<Board> boards;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(postListProvider(boardId));
    final board = boards.firstWhere((b) => b.id == boardId, orElse: () => const Board(id: '', name: '', description: '', postCount: 0));

    if (posts.isEmpty) {
      return GlassContainer(
        child: Column(
          children: [
            const SizedBox(height: 16),
            const Icon(Icons.article_outlined, size: 40, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text('${board.name}에 게시글이 없습니다.', style: const TextStyle(fontSize: 14, color: AppColors.textMuted)),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            '${board.name} · ${posts.length}개',
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
          ),
        ),
        ...posts.map((p) => GestureDetector(
          onTap: () => context.push('/post/${p.id}'),
          child: GlassContainer(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (p.isHot) ...[
                      Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBg,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                        ),
                        child: const Text('HOT', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800)),
                      ),
                    ],
                    Expanded(
                      child: Text(p.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(p.author, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    const SizedBox(width: 8),
                    Text(p.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const Spacer(),
                    Icon(Icons.visibility_outlined, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text('${p.viewCount}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    const SizedBox(width: 10),
                    Icon(Icons.chat_bubble_outline, size: 12, color: AppColors.textMuted),
                    const SizedBox(width: 3),
                    Text('${p.commentCount}', style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }
}

// ── 공통 위젯 ─────────────────────────────────────────────────────────

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 7),
        child: Row(
          children: [
            if (post.isHot)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                ),
                child: const Text('HOT', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800)),
              ),
            Expanded(
              child: Text(post.title, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary), overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Text(post.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
      ),
    );
  }
}

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.board, required this.isLast});
  final Board board;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        title: Text(board.name, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(board.description, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: Text('${board.postCount}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        onTap: () => context.push('/board/${board.id}'),
      ),
    );
  }
}
