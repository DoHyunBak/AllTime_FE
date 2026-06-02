import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/community_provider.dart';

class BoardDetailScreen extends ConsumerWidget {
  const BoardDetailScreen({super.key, required this.boardId});
  final String boardId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final boards = ref.watch(boardListProvider);
    final board = boards.firstWhere((b) => b.id == boardId, orElse: () => const Board(id: '', name: '알 수 없음', description: '', postCount: 0));
    final posts = ref.watch(postListProvider(boardId));

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: AppBar(
                backgroundColor: Colors.white.withValues(alpha: 0.1),
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: Text(board.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final p = posts[index];
            return GestureDetector(
              onTap: () => context.push('/post/${p.id}'),
              child: GlassContainer(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                opacity: 0.05,
                borderOpacity: 0.1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (p.isHot) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                            ),
                            child: const Text('HOT', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            p.title,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(p.author, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.6))),
                        const SizedBox(width: 8),
                        Text(p.date, style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                        const Spacer(),
                        Icon(Icons.visibility_outlined, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('${p.viewCount}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                        const SizedBox(width: 12),
                        Icon(Icons.chat_bubble_outline, size: 14, color: Colors.white.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text('${p.commentCount}', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          elevation: 0,
          shape: CircleBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.3))),
          onPressed: () {},
          child: const Icon(Icons.edit, color: Colors.white),
        ),
      ),
    );
  }
}
