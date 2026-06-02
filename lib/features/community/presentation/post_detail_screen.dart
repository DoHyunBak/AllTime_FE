import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_background.dart';
import '../../../shared/widgets/glass_container.dart';
import '../domain/community_provider.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 400));

    ref.read(commentProvider.notifier).add(widget.postId, text);
    _commentController.clear();
    setState(() => _isSubmitting = false);

    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('댓글이 등록되었습니다.'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _deleteComment(String commentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('댓글 삭제', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('댓글을 삭제하시겠습니까?', style: TextStyle(fontSize: 14)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('취소')),
          TextButton(
            onPressed: () {
              ref.read(commentProvider.notifier).delete(widget.postId, commentId);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('댓글이 삭제되었습니다.'), duration: Duration(seconds: 2)),
              );
            },
            child: const Text('삭제', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPosts = ref.watch(postListProvider(null));
    final post = allPosts.firstWhere(
      (p) => p.id == widget.postId,
      orElse: () => const Post(id: '', boardId: '', title: '알 수 없음', author: '', date: '', viewCount: 0, commentCount: 0),
    );
    final likeState = ref.watch(likeProvider);
    final comments = ref.watch(postCommentsProvider(widget.postId));
    final isLiked = likeState.isLiked(widget.postId);
    final likeCount = likeState.likeCount(widget.postId);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text('게시글', style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w800)),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                children: [
                  // ── 게시글 본문 ──────────────────────────────────
                  GlassContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (post.isHot) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 0.5),
                            ),
                            child: const Text('HOT', style: TextStyle(fontSize: 10, color: AppColors.primary, fontWeight: FontWeight.w800)),
                          ),
                          const SizedBox(height: 12),
                        ],
                        Text(post.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              width: 32, height: 32,
                              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgElevated),
                              child: const Icon(Icons.person, size: 16, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post.author, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                                Text(post.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                              ],
                            ),
                            const Spacer(),
                            const Icon(Icons.visibility_outlined, size: 13, color: AppColors.textMuted),
                            const SizedBox(width: 3),
                            Text('${post.viewCount}', style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Divider(color: AppColors.borderLight, height: 1),
                        const SizedBox(height: 20),
                        Text(
                          '이곳은 상세 게시글 데모 화면입니다.\n실제 서버와 연결되면 여기에 본문 내용이 표시됩니다.\n\n기숙사 생활에 필요한 다양한 정보를 자유롭게 나눠보세요.',
                          style: const TextStyle(fontSize: 14, height: 1.7, color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _LikeButton(
                              isLiked: isLiked,
                              count: likeCount,
                              onTap: () => ref.read(likeProvider.notifier).toggle(widget.postId),
                            ),
                            const SizedBox(width: 12),
                            _InfoChip(icon: Icons.chat_bubble_outline, label: '댓글 ${comments.length}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ── 댓글 목록 ────────────────────────────────────
                  GlassContainer(
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            children: [
                              const Icon(Icons.chat_bubble_outline, size: 15, color: AppColors.textSecondary),
                              const SizedBox(width: 6),
                              Text('댓글 ${comments.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                            ],
                          ),
                        ),
                        const Divider(color: AppColors.borderLight, height: 1),
                        if (comments.isEmpty)
                          const Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('첫 번째 댓글을 남겨보세요!', style: TextStyle(fontSize: 13, color: AppColors.textMuted)),
                          )
                        else
                          ...comments.asMap().entries.map((entry) => _CommentItem(
                            comment: entry.value,
                            isLast: entry.key == comments.length - 1,
                            onDelete: () => _deleteComment(entry.value.id),
                          )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),

            // ── 댓글 입력창 ──────────────────────────────────────
            Container(
              decoration: const BoxDecoration(
                color: AppColors.bgSurface,
                border: Border(top: BorderSide(color: AppColors.borderLight, width: 0.5)),
              ),
              padding: EdgeInsets.only(
                left: 16, right: 12, top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 10,
              ),
              child: Row(
                children: [
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgElevated),
                    child: const Icon(Icons.person, size: 16, color: AppColors.textMuted),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submitComment(),
                      decoration: const InputDecoration(
                        hintText: '댓글을 입력하세요...',
                        hintStyle: TextStyle(fontSize: 14, color: AppColors.textMuted),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 6),
                        fillColor: Colors.transparent,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _isSubmitting ? null : _submitComment,
                    child: Container(
                      width: 34, height: 34,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isSubmitting ? AppColors.bgElevated : AppColors.primary,
                      ),
                      child: _isSubmitting
                          ? const Padding(
                              padding: EdgeInsets.all(9),
                              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                            )
                          : const Icon(Icons.send_rounded, size: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeButton extends StatelessWidget {
  const _LikeButton({required this.isLiked, required this.count, required this.onTap});
  final bool isLiked;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isLiked ? AppColors.primaryBg : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(500),
          border: Border.all(color: isLiked ? AppColors.primary.withValues(alpha: 0.5) : AppColors.borderLight),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_border,
                key: ValueKey(isLiked),
                size: 16,
                color: isLiked ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 6),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isLiked ? AppColors.primary : AppColors.textSecondary,
              ),
              child: Text('추천 $count'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.bgElevated,
        borderRadius: BorderRadius.circular(500),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _CommentItem extends StatelessWidget {
  const _CommentItem({required this.comment, required this.isLast, required this.onDelete});
  final Comment comment;
  final bool isLast;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        border: isLast ? null : const Border(bottom: BorderSide(color: AppColors.borderLight, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.bgElevated),
            child: const Icon(Icons.person, size: 14, color: AppColors.textMuted),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comment.author, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    const SizedBox(width: 8),
                    Text(comment.date, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(comment.content, style: const TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Icon(Icons.close, size: 14, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}
