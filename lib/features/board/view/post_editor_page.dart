import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../controllers/board_controller.dart';
import '../models/user_post.dart';
import '../../../util/editor/ckeditor_field.dart';

const List<String> kAvailableImages = [
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

class PostEditorPage extends StatefulWidget {
  const PostEditorPage({
    this.postId,
    super.key,
  });

  final String? postId;
  @override
  State<PostEditorPage> createState() => _PostEditorPageState();
}

class _PostEditorPageState extends State<PostEditorPage> {
  final _formKey = GlobalKey<FormState>();
  late final BoardController _controller = context.read<BoardController>();
  UserPost? _original;

  late final TextEditingController _titleController;
  late final TextEditingController _summaryController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _tagsController;
  String _thumbnail = kAvailableImages.first;
  List<String> _attachments = <String>[];
  String _content = '';

  bool get _isEditing => widget.postId != null;
=======
  late final TextEditingController _titleController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _summaryController;
  late final Ckeditor5Controller _contentController;
  late String _coverImage;
  late List<String> _selectedImages;

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
    if (_isEditing) {
      _original = _controller.findPostById(widget.postId!);
    }
    _titleController = TextEditingController(text: _original?.title ?? '');
    _summaryController = TextEditingController(text: _original?.summary ?? '');
    _nicknameController = TextEditingController(text: _original?.nickname ?? '');
    _tagsController = TextEditingController(
      text: _original == null ? '' : _original!.tags.join(', '),
    );
    _thumbnail = _original?.thumbnail ?? _thumbnail;
    _attachments = List<String>.from(_original?.attachments ?? <String>[]);
    _content = _original?.content ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _summaryController.dispose();
    _nicknameController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _save,
        icon: const Icon(Icons.save_alt),
        label: Text(_isEditing ? '글 수정' : '글 등록'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            children: [
              Text(
                _isEditing ? '게시글 수정' : '새 게시글 작성',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: '작성자 닉네임',
                  helperText: '게시글에 노출될 닉네임을 입력하세요.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '닉네임을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '제목',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '제목을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _summaryController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: '요약',
                  hintText: '목록과 갤러리에서 보여질 간단한 요약을 작성하세요.',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '요약을 입력하세요';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              Text(
                '대표 이미지 선택',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: kAvailableImages.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final image = kAvailableImages[index];
                    final isSelected = image == _thumbnail;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _thumbnail = image;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                        ),
                        width: 160,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(image, fit: BoxFit.cover),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '첨부 이미지',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final image in kAvailableImages)
                    FilterChip(
                      label: Text(image.split('/').last),
                      avatar: Image.asset(image, width: 32, height: 32, fit: BoxFit.cover),
                      selected: _attachments.contains(image),
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _attachments = <String>{..._attachments, image}.toList();
                          } else {
                            _attachments = _attachments
                                .where((attachment) => attachment != image)
                                .toList();
                          }
                        });
                      },
                    ),
                ],
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: '태그',
                  helperText: '쉼표(,)로 구분하여 입력하세요.',
                ),
              ),
              const SizedBox(height: 24),
              Text(
                '본문 내용',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              CkEditorField(
                initialValue: _content,
                onChanged: (value) {
                  _content = value;
                },
                height: 360,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_content.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('본문 내용을 입력하세요.')),
      );
      return;
    }
    final now = DateTime.now();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
    final nickname = _nicknameController.text.trim();

    if (_isEditing && _original != null) {
      final updated = _original!.copyWith(
        title: _titleController.text.trim(),
        summary: _summaryController.text.trim(),
        content: _content,
        thumbnail: _thumbnail,
        attachments: _attachments,
        tags: tags,
        nickname: nickname,
        updatedAt: now,
      );
      _controller.updatePost(updated);
      context.go('/free/post/${updated.id}');
    } else {
      final newId = 'POST-${now.millisecondsSinceEpoch}';
      final newPost = UserPost(
        id: newId,
        title: _titleController.text.trim(),
        nickname: nickname,
        summary: _summaryController.text.trim(),
        content: _content,
        thumbnail: _thumbnail,
        attachments: _attachments,
        tags: tags,
        views: 0,
        likes: 0,
        dislikes: 0,
        createdAt: now,
        updatedAt: now,
        comments: const [],
      );
      _controller.addPost(newPost);
      context.go('/free/post/$newId');
    }

  }
}
