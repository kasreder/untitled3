import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../controllers/board_controller.dart';
import '../models/board_comment.dart';
import '../models/board_post.dart';
import '../widgets/comment_utils.dart';
import 'post_editor_page.dart';

class PostDetailPage extends StatelessWidget {
  const PostDetailPage({
    required this.postId,
    super.key,
  });

  final String postId;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoardController>();
    final post = controller.findById(postId);
    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('게시글 상세')),
        body: const Center(child: Text('게시글을 찾을 수 없습니다.')),
      );
    }
    final theme = Theme.of(context);
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(post.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: '공유',
            onPressed: () => _sharePost(post),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'edit':
                  _editPost(context, controller, post);
                  break;
                case 'delete':
                  _deletePost(context, controller, post);
                  break;
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'edit', child: Text('수정')), 
              PopupMenuItem(value: 'delete', child: Text('삭제')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              post.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _MetaChip(icon: Icons.person_outline, label: post.nickname),
                _MetaChip(
                  icon: Icons.schedule_outlined,
                  label: '작성 ${dateFormat.format(post.createdAt)}',
                ),
                _MetaChip(
                  icon: Icons.edit_calendar_outlined,
                  label: '수정 ${dateFormat.format(post.updatedAt)}',
                ),
                _MetaChip(icon: Icons.remove_red_eye_outlined, label: '${post.views}'),
                _MetaChip(icon: Icons.thumb_up_outlined, label: '${post.likes}'),
                _MetaChip(icon: Icons.thumb_down_outlined, label: '${post.dislikes}'),
                _MetaChip(icon: Icons.chat_bubble_outline, label: '${countComments(post.comments)}'),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: Image.asset(
                post.coverImage,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 220,
                    color: theme.colorScheme.surfaceVariant,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image_outlined, size: 48),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
            HtmlWidget(
              post.content,
              renderMode: RenderMode.column,
              customStylesBuilder: (element) {
                if (element.localName == 'ul') {
                  return {'padding-left': '18px'};
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.thumb_up_alt_outlined),
                    label: Text('좋아요 ${post.likes}'),
                    onPressed: () => controller.reactToPost(post.id, like: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonalIcon(
                    icon: const Icon(Icons.thumb_down_alt_outlined),
                    label: Text('싫어요 ${post.dislikes}'),
                    onPressed: () => controller.reactToPost(post.id, like: false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            CommentSection(postId: post.id, comments: post.comments),
          ],
        ),
      ),
    );
  }

  void _sharePost(BoardPost post) {
    final url = 'https://cheongrok.community/posts/${post.id}';
    Share.share('${post.shareMessage}\n$url');
  }

  Future<void> _editPost(
    BuildContext context,
    BoardController controller,
    BoardPost post,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BoardController>.value(
          value: controller,
          child: PostEditorPage(initialPost: post),
        ),
      ),
    );
  }

  Future<void> _deletePost(
    BuildContext context,
    BoardController controller,
    BoardPost post,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('게시글 삭제'),
        content: Text('"${post.title}" 글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deletePost(post.id);
      Navigator.of(context).pop();
    }
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class CommentSection extends StatefulWidget {
  const CommentSection({
    required this.postId,
    required this.comments,
    super.key,
  });

  final String postId;
  final List<BoardComment> comments;

  @override
  State<CommentSection> createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  BoardComment? _replyTarget;

  @override
  void dispose() {
    _nicknameController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoardController>();
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '댓글 ${countComments(widget.comments)}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        if (_replyTarget != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '답글 대상: ${_replyTarget!.nickname}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: () => setState(() => _replyTarget = null),
                  child: const Text('취소'),
                ),
              ],
            ),
          ),
        TextField(
          controller: _nicknameController,
          decoration: const InputDecoration(
            labelText: '닉네임',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _contentController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: '댓글 내용',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: () => _submitComment(controller),
            icon: const Icon(Icons.send_outlined),
            label: Text(_replyTarget == null ? '댓글 등록' : '답글 등록'),
          ),
        ),
        const SizedBox(height: 24),
        _CommentThread(
          comments: widget.comments,
          onReply: (comment) => setState(() => _replyTarget = comment),
          onDelete: (comment) => _deleteComment(context, controller, comment),
          dateFormat: dateFormat,
        ),
      ],
    );
  }

  Future<void> _submitComment(BoardController controller) async {
    final nickname = _nicknameController.text.trim();
    final content = _contentController.text.trim();
    if (nickname.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임과 내용을 모두 입력해 주세요.')),
      );
      return;
    }
    final comment = BoardComment(
      id: controller.generateCommentId(),
      nickname: nickname,
      content: content,
      createdAt: DateTime.now(),
    );
    controller.addComment(
      widget.postId,
      comment,
      parentCommentId: _replyTarget?.id,
    );
    setState(() {
      _contentController.clear();
      _replyTarget = null;
    });
  }

  Future<void> _deleteComment(
    BuildContext context,
    BoardController controller,
    BoardComment comment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('댓글 삭제'),
        content: const Text('댓글을 삭제하시겠습니까?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('취소')),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      controller.deleteComment(widget.postId, comment.id);
    }
  }
}

class _CommentThread extends StatelessWidget {
  const _CommentThread({
    required this.comments,
    required this.onReply,
    required this.onDelete,
    required this.dateFormat,
  });

  final List<BoardComment> comments;
  final ValueChanged<BoardComment> onReply;
  final ValueChanged<BoardComment> onDelete;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const Text('첫 번째 댓글을 남겨보세요.');
    }
    return Column(
      children: [
        for (final comment in comments)
          _CommentTile(
            comment: comment,
            onReply: onReply,
            onDelete: onDelete,
            dateFormat: dateFormat,
            depth: 0,
          ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.onReply,
    required this.onDelete,
    required this.dateFormat,
    required this.depth,
  });

  final BoardComment comment;
  final ValueChanged<BoardComment> onReply;
  final ValueChanged<BoardComment> onDelete;
  final DateFormat dateFormat;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final indent = depth * 16.0;
    return Container(
      margin: EdgeInsets.only(left: indent, bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  comment.nickname,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              Text(
                dateFormat.format(comment.createdAt),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment.content),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            children: [
              TextButton.icon(
                onPressed: () => onReply(comment),
                icon: const Icon(Icons.reply_outlined, size: 18),
                label: const Text('답글'),
              ),
              TextButton.icon(
                onPressed: () => onDelete(comment),
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('삭제'),
              ),
            ],
          ),
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                children: [
                  for (final reply in comment.replies)
                    _CommentTile(
                      comment: reply,
                      onReply: onReply,
                      onDelete: onDelete,
                      dateFormat: dateFormat,
                      depth: depth + 1,
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
