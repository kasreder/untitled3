import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../models/user_post.dart';
import '../widgets/post_gallery_view.dart';
import '../widgets/post_list_view.dart';

class BoardPage extends StatefulWidget {
  const BoardPage({super.key});

  @override
  State<BoardPage> createState() => _BoardPageState();
}

class _BoardPageState extends State<BoardPage> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<BoardController>().loadPosts();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<BoardController>();
    final posts = controller.posts;

    final toggle = SegmentedButton<PostLayoutMode>(
      segments: const <ButtonSegment<PostLayoutMode>>[
        ButtonSegment<PostLayoutMode>(
          value: PostLayoutMode.list,
          label: Text('리스트'),
          icon: Icon(Icons.view_list),
        ),
        ButtonSegment<PostLayoutMode>(
          value: PostLayoutMode.gallery,
          label: Text('갤러리'),
          icon: Icon(Icons.grid_view),
        ),
      ],
      selected: <PostLayoutMode>{controller.layoutMode},
      onSelectionChanged: (selection) {
        controller.changeLayout(selection.first);
      },
    );

    Widget content;
    if (controller.isLoading && !controller.hasLoaded) {
      content = const Center(child: CircularProgressIndicator());
    } else if (controller.errorMessage != null) {
      content = Center(child: Text(controller.errorMessage!));
    } else if (posts.isEmpty) {
      content = const _EmptyPlaceholder();
    } else {
      content = AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: controller.layoutMode == PostLayoutMode.list
            ? PostListView(
                key: const ValueKey('list-view'),
                posts: posts,
                onTap: _openDetail,
                onShare: _sharePost,
                onReaction: _handleReaction,
              )
            : PostGalleryView(
                key: const ValueKey('gallery-view'),
                posts: posts,
                onTap: _openDetail,
                onShare: _sharePost,
                onReaction: _handleReaction,
              ),
      );
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/free/new'),
        icon: const Icon(Icons.edit),
        label: const Text('글 작성'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '커뮤니티 게시판',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      '${posts.length}개의 게시글',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  toggle,
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: content,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetail(UserPost post) {
    context.push('/free/post/${post.id}', extra: post);
  }

  void _handleReaction(UserPost post, bool isLike) {
    final controller = context.read<BoardController>();
    controller.toggleLike(post.id, isLike: isLike);
  }

  Future<void> _sharePost(UserPost post) async {
    final base = Uri.base;
    final target = base.replace(path: post.sharePath).toString();
    await Clipboard.setData(ClipboardData(text: target));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('공유 링크가 복사되었습니다.\n$target'),
      ),
    );
  }
}

class _EmptyPlaceholder extends StatelessWidget {
  const _EmptyPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 48,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            '아직 등록된 게시글이 없습니다.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 글의 주인공이 되어보세요!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ],
      ),
    );
  }
}
