import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_post.dart';
import 'post_meta_row.dart';

class PostListView extends StatelessWidget {
  const PostListView({
    required this.posts,
    required this.onTap,
    required this.onShare,
    required this.onReaction,
    super.key,
  });

  final List<UserPost> posts;
  final ValueChanged<UserPost> onTap;
  final Future<void> Function(UserPost post) onShare;
  final void Function(UserPost post, bool isLike) onReaction;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return _PostListTile(
          post: post,
          onTap: () => onTap(post),
          onShare: () => onShare(post),
          onReaction: (isLike) => onReaction(post, isLike),
        );
      },
    );
  }
}

class _PostListTile extends StatelessWidget {
  const _PostListTile({
    required this.post,
    required this.onTap,
    required this.onShare,
    required this.onReaction,
  });

  final UserPost post;
  final VoidCallback onTap;
  final VoidCallback onShare;
  final ValueChanged<bool> onReaction;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    tooltip: '공유',
                    onPressed: onShare,
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    label: Text(post.nickname),
                    avatar: const Icon(Icons.person_outline),
                  ),
                  Text(
                    '작성 ${dateFormat.format(post.createdAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  Text(
                    '수정 ${dateFormat.format(post.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (post.thumbnail.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.asset(
                      post.thumbnail,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              if (post.thumbnail.isNotEmpty) const SizedBox(height: 12),
              Text(
                post.plainSummary,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              PostMetaRow(
                post: post,
                onReaction: onReaction,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
