// 파일 경로: lib/features/board/view/widgets/post_list_tile.dart
// 파일 설명: 게시글 리스트 카드 형태를 정의한 프레젠테이션 위젯.

import 'package:flutter/material.dart';

import '../../models/board_post.dart';
import '../../widgets/comment_utils.dart';

/// 자유 게시판 목록에서 단일 게시글을 카드로 보여주는 위젯입니다.
class PostListTile extends StatelessWidget {
  const PostListTile({
    required this.post,
    required this.formattedDate,
    required this.onTap,
    super.key,
  });

  final BoardPost post;
  final String formattedDate;
  final VoidCallback onTap;

  /// 게시글 요약 정보를 카드로 렌더링합니다.
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                post.summary.isEmpty ? '상세 내용을 확인해보세요.' : post.summary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _InfoChip(
                    icon: Icons.person_outline,
                    label: post.nickname,
                  ),
                  _InfoChip(
                    icon: Icons.schedule_outlined,
                    label: formattedDate,
                  ),
                  _InfoChip(
                    icon: Icons.remove_red_eye_outlined,
                    label: '${post.views}',
                  ),
                  _InfoChip(
                    icon: Icons.thumb_up_outlined,
                    label: '${post.likes}',
                  ),
                  _InfoChip(
                    icon: Icons.thumb_down_outlined,
                    label: '${post.dislikes}',
                  ),
                  _InfoChip(
                    icon: Icons.chat_bubble_outline,
                    label: '${countComments(post.comments)}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 게시글 부가 정보를 아이콘과 함께 보여주는 보조 위젯입니다.
class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  /// 작은 아이콘과 텍스트 조합을 렌더링합니다.
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}
