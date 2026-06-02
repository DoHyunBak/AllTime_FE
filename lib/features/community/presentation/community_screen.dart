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
    final boards = ref.watch(boardListProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // ── 기숙사 네트워크 바로가기 ──────────────────────────
          _NetworkShortcut(),
          const SizedBox(height: 16),
          // ── 게시판 목록 ─────────────────────────────────────
          _BoardListSection(boards: boards),
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

// ── 기숙사 네트워크 ────────────────────────────────────────────────────

class _NetworkShortcut extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.push('/network'),
      child: GlassContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.public, color: AppColors.primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('기숙사 네트워크', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text('자치회 · 타 학교 열람 · 학교 대항전', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GlassContainer(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text('게시판', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimary)),
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

class _BoardRow extends StatelessWidget {
  const _BoardRow({required this.board, required this.isLast});
  final Board board;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: isDark ? AppColors.borderDark : Colors.black.withValues(alpha: 0.05), width: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
        title: Text(board.name, style: TextStyle(fontSize: 14, color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w600)),
        subtitle: Text(board.description, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        trailing: Text('${board.postCount}', style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
        onTap: () => context.push('/board/${board.id}'),
      ),
    );
  }
}

