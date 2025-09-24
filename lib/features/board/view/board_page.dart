import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:untitled3/features/auth/controllers/auth_controller.dart';
import 'package:untitled3/features/auth/models/user_grade.dart';

import '../controllers/board_controller.dart';
import '../data/board_repository.dart';
import '../models/board_post.dart';
import 'post_detail_page.dart';
import 'post_editor_page.dart';
import 'widgets/post_gallery_tile.dart';
import 'widgets/post_list_tile.dart';

class BoardPage extends StatelessWidget {
  const BoardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<BoardController>(
      create: (_) => BoardController(repository: BoardRepository())
        ..loadInitialPosts(),
      child: const _BoardView(),
    );
  }
}

class _BoardView extends StatelessWidget {
  const _BoardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final controller = context.watch<BoardController>();
    final auth = context.watch<AuthController>();
    final canChangeViewMode = auth.currentUser?.grade.isOperator ?? false;
    if (!canChangeViewMode && controller.viewMode != BoardViewMode.list) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (controller.viewMode != BoardViewMode.list) {
          controller.setViewMode(BoardViewMode.list);
        }
      });
    }
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _BoardToolbar(
                controller: controller,
                canChangeViewMode: canChangeViewMode,
                userGrade: auth.currentUser?.grade,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: controller.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _BoardContent(controller: controller),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton.extended(
            onPressed: () => _openEditor(context),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('새 글 작성'),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  void _openEditor(BuildContext context) {
    final controller = context.read<BoardController>();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<BoardController>.value(
          value: controller,
          child: const PostEditorPage(),
        ),
      ),
    );
  }
}

class _BoardToolbar extends StatelessWidget {
  const _BoardToolbar({
    required this.controller,
    required this.canChangeViewMode,
    this.userGrade,
  });

  final BoardController controller;
  final bool canChangeViewMode;
  final UserGrade? userGrade;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gradeLabel = userGrade?.label ?? UserGrade.all.label;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '커뮤니티 게시판',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SegmentedButton<BoardViewMode>(
              segments: [
                const ButtonSegment<BoardViewMode>(
                  value: BoardViewMode.list,
                  icon: Icon(Icons.view_list_outlined),
                  label: Text('리스트'),
                ),
                ButtonSegment<BoardViewMode>(
                  value: BoardViewMode.gallery,
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('갤러리'),
                  enabled: canChangeViewMode,
                ),
              ],
              selected: <BoardViewMode>{controller.viewMode},
              onSelectionChanged: canChangeViewMode
                  ? (selection) {
                      controller.setViewMode(selection.first);
                    }
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '총 ${controller.posts.length}건',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Chip(
              label: Text('등급: $gradeLabel'),
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            if (!canChangeViewMode)
              Text(
                '운영자 등급 이상만 보기 전환이 가능합니다.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _BoardContent extends StatelessWidget {
  const _BoardContent({required this.controller});

  final BoardController controller;

  @override
  Widget build(BuildContext context) {
    final posts = controller.posts;
    if (posts.isEmpty) {
      return const Center(child: Text('등록된 글이 없습니다. 첫 번째 글을 작성해보세요.'));
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: controller.viewMode == BoardViewMode.list
          ? _PostListView(
              key: const ValueKey('list'),
              posts: posts,
            )
          : _PostGalleryView(
              key: const ValueKey('gallery'),
              posts: posts,
            ),
    );
  }
}

class _PostListView extends StatelessWidget {
  const _PostListView({required this.posts, super.key});

  final List<BoardPost> posts;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<BoardController>();
    final dateFormat = DateFormat('yyyy.MM.dd HH:mm');
    return ListView.separated(
      itemCount: posts.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostListTile(
          post: post,
          formattedDate: dateFormat.format(post.updatedAt),
          onTap: () => _openDetail(context, controller, post),
        );
      },
    );
  }
}

class _PostGalleryView extends StatelessWidget {
  const _PostGalleryView({required this.posts, super.key});

  final List<BoardPost> posts;

  @override
  Widget build(BuildContext context) {
    final controller = context.read<BoardController>();
    final columns = MediaQuery.of(context).size.width > 900
        ? 4
        : MediaQuery.of(context).size.width > 600
            ? 3
            : 2;
    final dateFormat = DateFormat('MM/dd HH:mm');
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return PostGalleryTile(
          post: post,
          formattedDate: dateFormat.format(post.updatedAt),
          onTap: () => _openDetail(context, controller, post),
        );
      },
    );
  }
}

void _openDetail(BuildContext context, BoardController controller, BoardPost post) {
  controller.registerView(post.id);
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider<BoardController>.value(
        value: controller,
        child: PostDetailPage(postId: post.id),
      ),
    ),
  );
}
