import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../models/post_comment.dart';
import '../models/user_post.dart';
import '../widgets/comment_thread.dart';
import '../widgets/post_meta_row.dart';

class PostDetailPage extends StatefulWidget {
  const PostDetailPage({
    required this.postId,
    super.key,
  });

  final String postId;

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BoardController>().recordView(widget.postId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoardController>();
    final post = controller.findPostById(widget.postId);
    if (post == null) {
      return Scaffold(
        body: Center(
          child: Text(
            '게시글을 찾을 수 없습니다.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      );
    }

    final dateFormat = DateFormat('yyyy년 MM월 dd일 HH:mm');
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.title,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Chip(
                              avatar: const Icon(Icons.person_outline),
                              label: Text(post.nickname),
                            ),
                            Text('작성 ${dateFormat.format(post.createdAt)}'),
                            Text('수정 ${dateFormat.format(post.updatedAt)}'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () => _sharePost(post),
                        icon: const Icon(Icons.share_outlined),
                        tooltip: '공유',
                      ),
                      const SizedBox(height: 8),
                      FilledButton.tonalIcon(
                        onPressed: () {
                          context.push('/free/post/${post.id}/edit', extra: post);
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('수정'),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () => _confirmDelete(post),
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('삭제'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (post.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: [
                    for (final tag in post.tags)
                      Chip(
                        label: Text(tag),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withOpacity(0.3),
                      ),
                  ],
                ),
              const SizedBox(height: 20),
              if (post.thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    post.thumbnail,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(height: 20),
              Html(data: post.content),
              const SizedBox(height: 12),
              if (post.attachments.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '첨부 이미지',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final attachment in post.attachments)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              attachment,
                              width: 160,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              PostMetaRow(
                post: post,
                onReaction: (isLike) {
                  controller.toggleLike(post.id, isLike: isLike);
                },
              ),
              const Divider(height: 48),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '댓글 ${_countComments(post.comments)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  FilledButton.icon(
                    onPressed: () => _openCommentDialog(post),
                    icon: const Icon(Icons.add_comment),
                    label: const Text('댓글 작성'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              CommentThread(
                comments: post.comments,
                onReply: (comment) => _openCommentDialog(post, parent: comment),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sharePost(UserPost post) async {
    final target = Uri.base.replace(path: post.sharePath).toString();
    await Clipboard.setData(ClipboardData(text: target));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('공유 링크가 복사되었습니다.\n$target')),
    );
  }

  Future<void> _confirmDelete(UserPost post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('게시글 삭제'),
          content: const Text('삭제된 게시글은 되돌릴 수 없습니다. 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    context.read<BoardController>().deletePost(post.id);
    if (!mounted) {
      return;
    }
    context.go('/free');
  }

  Future<void> _openCommentDialog(
    UserPost post, {
    PostComment? parent,
  }) async {
    final nicknameController = TextEditingController();
    final contentController = TextEditingController();
    final result = await showDialog<_CommentDialogResult>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(parent == null ? '새 댓글 작성' : '답글 작성'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nicknameController,
                  decoration: const InputDecoration(
                    labelText: '닉네임',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: '내용',
                  ),
                  minLines: 4,
                  maxLines: 6,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            FilledButton(
              onPressed: () {
                if (nicknameController.text.trim().isEmpty ||
                    contentController.text.trim().isEmpty) {
                  return;
                }
                Navigator.of(context).pop(
                  _CommentDialogResult(
                    nickname: nicknameController.text.trim(),
                    content: contentController.text.trim(),
                  ),
                );
              },
              child: const Text('등록'),
            ),
          ],
        );
      },
    );
    if (result == null) {
      return;
    }
    final now = DateTime.now();
    final escapedContent = const HtmlEscape().convert(result.content);
    final formattedContent = '<p>${escapedContent.replaceAll('\n', '<br />')}</p>';
    final newComment = PostComment(
      id: 'C${now.millisecondsSinceEpoch}',
      nickname: result.nickname,
      content: formattedContent,
      createdAt: now,
      children: const [],
    );
    context
        .read<BoardController>()
        .addComment(post.id, newComment, parentId: parent?.id);
  }

  int _countComments(List<PostComment> comments) {
    var total = 0;
    for (final comment in comments) {
      total += 1 + _countComments(comment.children);
    }
    return total;
  }
}

class _CommentDialogResult {
  const _CommentDialogResult({
    required this.nickname,
    required this.content,
  });

  final String nickname;
  final String content;
}
