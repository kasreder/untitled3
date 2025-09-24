import 'package:flutter/foundation.dart';
import '../data/asset_user_post_repository.dart';
import '../models/post_comment.dart';
import '../models/user_post.dart';

class BoardController extends ChangeNotifier {
  BoardController({required this.repository});

  final UserPostRepository repository;

  List<UserPost> _posts = const [];
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;
  PostLayoutMode _layoutMode = PostLayoutMode.list;

  List<UserPost> get posts => _posts;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;
  PostLayoutMode get layoutMode => _layoutMode;

  Future<void> loadPosts() async {
    if (_isLoading || _hasLoaded) {
      return;
    }
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fetchedPosts = await repository.fetchPosts();
      _posts = List.unmodifiable(fetchedPosts);
      _hasLoaded = true;
    } catch (error) {
      _errorMessage = '게시글을 불러오지 못했습니다. 다시 시도해 주세요.';
      debugPrint('BoardController.loadPosts error: $error');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void changeLayout(PostLayoutMode mode) {
    if (_layoutMode == mode) {
      return;
    }
    _layoutMode = mode;
    notifyListeners();
  }

  void addPost(UserPost post) {
    _posts = List.unmodifiable(<UserPost>[post, ..._posts]);
    notifyListeners();
  }

  void updatePost(UserPost updatedPost) {
    final index = _posts.indexWhere((post) => post.id == updatedPost.id);
    if (index == -1) {
      return;
    }
    final mutable = List<UserPost>.from(_posts);
    mutable[index] = updatedPost;
    _posts = List.unmodifiable(mutable);
    notifyListeners();
  }

  void deletePost(String postId) {
    _posts = List.unmodifiable(
      _posts.where((post) => post.id != postId),
    );
    notifyListeners();
  }

  UserPost? findPostById(String postId) {
    return _posts.firstWhereOrNull((post) => post.id == postId);
  }

  void recordView(String postId) {
    final post = findPostById(postId);
    if (post == null) {
      return;
    }
    updatePost(post.copyWith(views: post.views + 1));
  }

  void toggleLike(String postId, {required bool isLike}) {
    final post = findPostById(postId);
    if (post == null) {
      return;
    }
    if (isLike) {
      updatePost(post.copyWith(likes: post.likes + 1));
    } else {
      updatePost(post.copyWith(dislikes: post.dislikes + 1));
    }

  }

  void addComment(
    String postId,
    PostComment comment, {
    String? parentId,
  }) {
    final post = findPostById(postId);
    if (post == null) {
      return;
    }
    final updatedComments = _addCommentToTree(post.comments, parentId, comment);
    updatePost(post.copyWith(comments: updatedComments));
  }

  void deleteComment(String postId, String commentId) {
    final post = findPostById(postId);
    if (post == null) {
      return;
    }
    final updatedComments =
        _removeCommentFromTree(post.comments, commentId).toList();
    updatePost(post.copyWith(comments: updatedComments));
  }

  List<PostComment> _addCommentToTree(
    List<PostComment> comments,
    String? parentId,
    PostComment newComment,
  ) {
    if (parentId == null) {
      return <PostComment>[newComment, ...comments];
    }
    return comments
        .map((comment) {
          if (comment.id == parentId) {
            final replies = <PostComment>[newComment, ...comment.children];
            return comment.copyWith(children: replies);
          }
          if (comment.children.isEmpty) {
            return comment;
          }
          final updatedChildren =
              _addCommentToTree(comment.children, parentId, newComment);
          if (!listEquals(comment.children, updatedChildren)) {
            return comment.copyWith(children: updatedChildren);
          }
          return comment;
        })
        .toList(growable: false);
  }

  Iterable<PostComment> _removeCommentFromTree(
    List<PostComment> comments,
    String commentId,
  ) sync* {
    for (final comment in comments) {
      if (comment.id == commentId) {
        continue;
      }
      if (comment.children.isEmpty) {
        yield comment;
        continue;
      }
      final updatedChildren =
          _removeCommentFromTree(comment.children, commentId).toList();
      if (!listEquals(comment.children, updatedChildren)) {
        yield comment.copyWith(children: updatedChildren);
      } else {
        yield comment;
      }
    }
  }
}

extension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}
