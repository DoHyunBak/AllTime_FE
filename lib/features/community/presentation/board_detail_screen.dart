import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../../../shared/widgets/toss.dart';
import '../domain/community_provider.dart';

class BoardDetailScreen extends ConsumerWidget {
  const BoardDetailScreen({super.key, required this.boardId});
  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardListProvider);
    final board = boards.firstWhere(
      (b) => b.id == boardId,
      orElse: () => const Board(id: '', name: '알 수 없음', description: '', postCount: 0),
    );
    final posts = ref.watch(postListProvider(boardId));

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: Text(board.name, style: TextStyle(color: isDark ? Colors.white : AppColors.textPrimary, fontWeight: FontWeight.w800)),
        ),
        body: posts.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.article_outlined, size: 48, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                    const SizedBox(height: 12),
                    Text('게시글이 없습니다', style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textSecondary, fontSize: 14)),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: posts.length,
                itemBuilder: (context, index) {
                  final p = posts[index];
                  return Appear(
                    index: index,
                    child: TossPressable(
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
                                    color: isDark ? AppColors.primary.withValues(alpha: 0.15) : AppColors.primaryBg,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                                  ),
                                  child: const Text('HOT', style: TextStyle(fontSize: 9, color: AppColors.primary, fontWeight: FontWeight.w800)),
                                ),
                              ],
                              Expanded(
                                child: Text(p.title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppColors.textPrimary)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Text(p.author, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)),
                              const SizedBox(width: 8),
                              Text(p.date, style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
                              const Spacer(),
                              Icon(Icons.visibility_outlined, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Text('${p.viewCount}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
                              const SizedBox(width: 10),
                              Icon(Icons.chat_bubble_outline, size: 13, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary),
                              const SizedBox(width: 3),
                              Text('${p.commentCount}', style: TextStyle(fontSize: 11, color: isDark ? AppColors.textMutedDark : AppColors.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ),
                  );
                },
              ),

        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shape: const CircleBorder(),
          onPressed: () {},
          child: const Icon(Icons.edit),
        ),
      ),
    );
  }
}
