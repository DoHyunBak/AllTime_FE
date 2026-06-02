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
    final hotPosts = ref.watch(postListProvider(null))
        .where((p) => p.isHot)
        .take(3)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // HOT 게시글
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionLabel(text: 'HOT 게시글', color: Colors.white),
                const SizedBox(height: 12),
                ...hotPosts.map((p) => _PostRow(post: p)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 기숙사 네트워크
          GestureDetector(
            onTap: () => context.push('/network'),
            child: GlassContainer(
              padding: const EdgeInsets.all(14),
              opacity: 0.25,
              child: const Row(
                children: [
                  Icon(Icons.public, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('기숙사 네트워크', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white)),
                        SizedBox(height: 2),
                        Text('자치회 · 타 학교 열람 · 학교 대항전', style: TextStyle(fontSize: 11, color: Colors.white70)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.white54, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 게시판 목록
          GlassContainer(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
                  child: _SectionLabel(text: '게시판', color: Colors.white),
                ),
                ...boards.asMap().entries.map((entry) {
                  final isLast = entry.key == boards.length - 1;
                  return _BoardRow(board: entry.value, isLast: isLast);
                }),
              ],
            ),
          ),
          const SizedBox(height: 80), // FAB space
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white.withValues(alpha: 0.2),
        elevation: 0,
        shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: color),
    );
  }
}

class _PostRow extends StatelessWidget {
  const _PostRow({required this.post});
  final Post post;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/post/${post.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            if (post.isHot)
              Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                ),
                child: const Text('HOT', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            Expanded(
              child: Text(
                post.title,
                style: const TextStyle(fontSize: 13, color: Colors.white),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              post.date,
              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4)),
            ),
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
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1), width: 0.5)),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        title: Text(
          board.name,
          style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          board.description,
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6)),
        ),
        trailing: Text(
          '${board.postCount}',
          style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4)),
        ),
        onTap: () => context.push('/board/${board.id}'),
      ),
    );
  }
}
