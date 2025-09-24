import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'package:untitled3/features/auth/controllers/auth_controller.dart';

import '../controllers/board_controller.dart';
import '../models/board_post.dart';
import '../widgets/ckeditor5.dart';

class PostEditorPage extends StatefulWidget {
  const PostEditorPage({
    this.initialPost,
    super.key,
  });

  final BoardPost? initialPost;

  bool get isEditing => initialPost != null;

  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final Ckeditor5Controller _contentController;
  late String _coverImage;
  late List<String> _selectedImages;
  late final String _authorNickname;
  late final String _authorGradeLabel;

  static const List<String> _availableImages = [
    'assets/pics/1.jpg',
    'assets/pics/2.jpg',
    'assets/pics/3.png',
    'assets/pics/4.gif',
    'assets/pics/5.jpg',
    'assets/pics/5.webp',
    'assets/pics/6.jpeg',
    'assets/pics/7.jpeg',
    'assets/pics/8.webp',
    'assets/pics/9.webp',
  ];

  @override
  void initState() {
    super.initState();
    final initial = widget.initialPost;
    final auth = context.read<AuthController>();
    _titleController = TextEditingController(text: initial?.title ?? '');
    _summaryController = TextEditingController(text: initial?.summary ?? '');
    _authorNickname = initial?.nickname ?? auth.currentUser?.nickname ?? '익명 회원';
    _authorGradeLabel = auth.currentUser?.grade.label ?? '모두';
    final mergedInitialHtml = _mergeAttachedImages(
      initial?.content ?? '',
      initial?.images ?? const <String>[],
    );
    _contentController = Ckeditor5Controller(initialHtml: mergedInitialHtml);
    _coverImage = initial?.coverImage ?? _availableImages.first;
    _selectedImages = List<String>.from(initial?.images ?? <String>[]);
    if (!_selectedImages.contains(_coverImage)) {
      _selectedImages.insert(0, _coverImage);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.isEditing;
    final gradeLabel = context.watch<AuthController>().currentUser?.grade.label ?? _authorGradeLabel;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? '게시글 수정' : '새 게시글 작성'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '제목',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '제목을 입력해 주세요.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: '작성자',
                border: OutlineInputBorder(),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _authorNickname,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Chip(
                    label: Text(gradeLabel),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _summaryController,
              decoration: const InputDecoration(
                labelText: '요약 설명',
                hintText: '리스트나 갤러리에서 보일 짧은 설명을 입력하세요.',
                border: OutlineInputBorder(),
              ),
              minLines: 2,
              maxLines: 4,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _coverImage,
              decoration: const InputDecoration(
                labelText: '대표 이미지',
                border: OutlineInputBorder(),
              ),
              items: [
                for (final path in _availableImages)
                  DropdownMenuItem(
                    value: path,
                    child: Row(
                      children: [
                        _ImagePreview(path: path, size: 32),
                        const SizedBox(width: 8),
                        Text(path.split('/').last),
                      ],
                    ),
                  ),
              ],
              onChanged: (value) {
                if (value == null) {
                  return;
                }
                setState(() {
                  _coverImage = value;
                  if (!_selectedImages.contains(value)) {
                    _selectedImages.insert(0, value);
                  }
                });
              },
            ),
            const SizedBox(height: 16),
            Text(
              '첨부 이미지',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final path in _availableImages)
                  FilterChip(
                    label: Text(path.split('/').last),
                    avatar: _ImagePreview(path: path, size: 24),
                    selected: _selectedImages.contains(path),
                    onSelected: (selected) async {
                      setState(() {
                        if (selected) {
                          if (!_selectedImages.contains(path)) {
                            _selectedImages.add(path);
                          }
                        } else {
                          if (path == _coverImage) {
                            return;
                          }
                          _selectedImages.remove(path);
                        }
                      });
                      if (selected) {
                        final html = await _contentController.getHtml();
                        final updated = _mergeAttachedImages(html, [path]);
                        await _contentController.setHtml(updated);
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              '본문 내용',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 400,
              child: Ckeditor5(controller: _contentController),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _handleSubmit,
              icon: Icon(isEditing ? Icons.save_outlined : Icons.publish_outlined),
              label: Text(isEditing ? '게시글 수정' : '게시글 등록'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final controller = context.read<BoardController>();
    final html = await _contentController.getHtml();
    final plainText = html.replaceAll(RegExp(r'<[^>]+>'), '').replaceAll('&nbsp;', '').trim();
    if (plainText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('본문 내용을 입력해 주세요.')),
        );
      }
      return;
    }
    final now = DateTime.now();
    final images = <String>{_coverImage, ..._selectedImages}.toList();
    final contentWithImages = _mergeAttachedImages(html, images);
    if (widget.initialPost == null) {
      final newPost = BoardPost(
        id: const Uuid().v4(),
        title: _titleController.text.trim(),
        nickname: _authorNickname,
        summary: _summaryController.text.trim(),
        content: contentWithImages,
        coverImage: _coverImage,
        createdAt: now,
        updatedAt: now,
        views: 0,
        likes: 0,
        dislikes: 0,
        images: images,
        comments: const [],
      );
      controller.addPost(newPost);
    } else {
      final updated = widget.initialPost!.copyWith(
        title: _titleController.text.trim(),
        nickname: _authorNickname,
        summary: _summaryController.text.trim(),
        content: contentWithImages,
        coverImage: _coverImage,
        images: images,
        updatedAt: now,
      );
      controller.updatePost(updated);
    }
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  String _mergeAttachedImages(String html, List<String> images) {
    if (images.isEmpty) {
      return html;
    }
    final buffer = StringBuffer(html.trim());
    final original = html;
    for (final image in images) {
      if (!original.contains(image)) {
        if (buffer.isNotEmpty) {
          buffer.write('\n');
        }
        buffer.write('<figure class="image"><img src="$image" alt="첨부 이미지" /></figure>');
      }
    }
    return buffer.toString();
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({
    required this.path,
    required this.size,
  });

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Radius.circular(6)),
      child: Image.asset(
        path,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: size,
            height: size,
            color: Theme.of(context).colorScheme.surfaceVariant,
            alignment: Alignment.center,
            child: const Icon(Icons.broken_image_outlined, size: 16),
          );
        },
      ),
    );
  }
}
