import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/community_provider.dart';

class PostDetailScreen extends ConsumerWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 찾기 (목업 전체에서)
    final allPosts = ref.watch(postListProvider(null));
    final post = allPosts.firstWhere((p) => p.id == postId, orElse: () => const Post(id: '', boardId: '', title: '알 수 없음', author: '', date: '', viewCount: 0, commentCount: 0));

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
                title: const Text('게시글', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
                iconTheme: const IconThemeData(color: Colors.white),
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: GlassContainer(
            opacity: 0.05,
            borderOpacity: 0.1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (post.isHot) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: const Text('HOT', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w800)),
                  ),
                  const SizedBox(height: 12),
                ],
                Text(
                  post.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                      child: const Icon(Icons.person, size: 16, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(post.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                        Text(post.date, style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.4))),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Text(
                  '이곳은 상세 게시글 데모 화면입니다.\n실제 서버와 연결되면 여기에 본문 내용이 표시됩니다.',
                  style: TextStyle(fontSize: 14, height: 1.6, color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _ActionButton(icon: Icons.thumb_up_outlined, label: '추천 12'),
                    const SizedBox(width: 20),
                    _ActionButton(icon: Icons.chat_bubble_outline, label: '댓글 ${post.commentCount}'),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(500),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
        ],
      ),
    );
  }
}
