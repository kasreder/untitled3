import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

import '../models/post_comment.dart';

class CommentThread extends StatelessWidget {
  const CommentThread({
    required this.comments,
    required this.onReply,
    super.key,
  });

  final List<PostComment> comments;
  final void Function(PostComment comment) onReply;

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return Center(
        child: Text(
          '첫 번째 댓글을 남겨주세요.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
        ),
      );
    }
    return Column(
      children: [
        for (final comment in comments)
          _CommentTile(
            comment: comment,
            depth: 0,
            onReply: onReply,
          ),
      ],
    );
  }
}

class _CommentTile extends StatelessWidget {
  const _CommentTile({
    required this.comment,
    required this.depth,
    required this.onReply,
  });

  final PostComment comment;
  final int depth;
  final void Function(PostComment comment) onReply;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0, bottom: 12),
      child: Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      comment.nickname,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Text(
                    dateFormat.format(comment.createdAt),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Html(data: comment.content),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: () => onReply(comment),
                  icon: const Icon(Icons.reply),
                  label: const Text('답글'),
                ),
              ),
              if (comment.children.isNotEmpty)
                for (final child in comment.children)
                  _CommentTile(
                    comment: child,
                    depth: depth + 1,
                    onReply: onReply,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
