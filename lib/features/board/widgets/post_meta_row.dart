import 'package:flutter/material.dart';

import '../models/post_comment.dart';
import '../models/user_post.dart';

class PostMetaRow extends StatelessWidget {
  const PostMetaRow({
    required this.post,
    required this.onReaction,
    this.showCommentCount = true,
    super.key,
  });

  final UserPost post;
  final ValueChanged<bool> onReaction;
  final bool showCommentCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _MetaChip(
              icon: Icons.visibility_outlined,
              label: '${post.views}',
              color: colorScheme.primary,
            ),
            _MetaChip(
              icon: Icons.thumb_up_alt_outlined,
              label: '${post.likes}',
              color: colorScheme.tertiary,
            ),
            _MetaChip(
              icon: Icons.thumb_down_alt_outlined,
              label: '${post.dislikes}',
              color: colorScheme.error,
            ),
            if (showCommentCount)
              _MetaChip(
                icon: Icons.chat_bubble_outline,
                label: '${_countComments(post)}',
                color: colorScheme.secondary,
              ),
          ],
        ),
        Wrap(
          spacing: 8,
          children: [
            FilledButton.tonalIcon(
              onPressed: () => onReaction(true),
              icon: const Icon(Icons.thumb_up_alt_outlined),
              label: const Text('좋아요'),
            ),
            FilledButton.tonalIcon(
              onPressed: () => onReaction(false),
              icon: const Icon(Icons.thumb_down_alt_outlined),
              label: const Text('싫어요'),
            ),
          ],
        ),
      ],
    );
  }

  int _countComments(UserPost post) {
    int count = 0;
    void visit(List<PostComment> comments) {
      for (final comment in comments) {
        count++;
        if (comment.children.isNotEmpty) {
          visit(comment.children);
        }
      }
    }

    visit(post.comments);
    return count;
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      side: BorderSide(color: color.withOpacity(0.2)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
    );
  }
}
