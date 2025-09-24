import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/user_post.dart';
import 'post_meta_row.dart';

class PostGalleryView extends StatelessWidget {
  const PostGalleryView({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final crossAxisCount = width > 1200
            ? 4
            : width > 900
                ? 3
                : width > 600
                    ? 2
                    : 1;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.86,
          ),
          itemCount: posts.length,
          itemBuilder: (context, index) {
            final post = posts[index];
            return _GalleryCard(
              post: post,
              onTap: () => onTap(post),
              onShare: () => onShare(post),
              onReaction: (isLike) => onReaction(post, isLike),
            );
          },
        );
      },
    );
  }
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard({
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
    final dateFormat = DateFormat('MM/dd HH:mm');
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (post.thumbnail.isNotEmpty)
                    Image.asset(post.thumbnail, fit: BoxFit.cover)
                  else
                    Container(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.4),
                      child: const Center(
                        child: Icon(Icons.image_outlined, size: 48),
                      ),
                    ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filledTonal(
                      onPressed: onShare,
                      icon: const Icon(Icons.share_outlined),
                      tooltip: '공유',
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.nickname,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${dateFormat.format(post.createdAt)} · ${dateFormat.format(post.updatedAt)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.plainSummary,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  PostMetaRow(
                    post: post,
                    onReaction: onReaction,
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
