import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/board_repository.dart';
import '../models/board_comment.dart';
import '../models/board_post.dart';

class BoardController extends ChangeNotifier {
  BoardController({
    required BoardRepository repository,
  }) : _repository = repository;

  final BoardRepository _repository;
  final List<BoardPost> _posts = <BoardPost>[];
  bool _isLoading = false;
  BoardViewMode _viewMode = BoardViewMode.list;

  bool get isLoading => _isLoading;
  BoardViewMode get viewMode => _viewMode;
  List<BoardPost> get posts => List<BoardPost>.unmodifiable(_posts);

  Future<void> loadInitialPosts() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    notifyListeners();
    try {
      final loadedPosts = await _repository.loadPosts();
      _posts
        ..clear()
        ..addAll(loadedPosts);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BoardPost? findById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } on StateError {
      return null;
    }
  }

  void setViewMode(BoardViewMode mode) {
    if (_viewMode == mode) {
      return;
    }
    _viewMode = mode;
    notifyListeners();
  }

  void addPost(BoardPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  void updatePost(BoardPost updated) {
    final index = _posts.indexWhere((post) => post.id == updated.id);
    if (index == -1) {
      return;
    }
    _posts[index] = updated;
    notifyListeners();
  }

  void deletePost(String id) {
    _posts.removeWhere((post) => post.id == id);
    notifyListeners();
  }

  void registerView(String id) {
    _updatePost(id, (post) {
      return post.copyWith(views: post.views + 1);
    });
  }

  void reactToPost(String id, {required bool like}) {
    _updatePost(id, (post) {
      if (like) {
        return post.copyWith(likes: post.likes + 1);
      }
      return post.copyWith(dislikes: post.dislikes + 1);
    });
  }

  void addComment(
    String postId,
    BoardComment comment, {
    String? parentCommentId,
  }) {
    _updatePost(postId, (post) {
      final now = DateTime.now();
      if (parentCommentId == null) {
        return post.copyWith(
          comments: <BoardComment>[...post.comments, comment],
          updatedAt: now,
        );
      }
      final (updatedComments, inserted) =
          _insertReply(post.comments, parentCommentId, comment);
      if (!inserted) {
        return post;
      }
      return post.copyWith(
        comments: updatedComments,
        updatedAt: now,
      );
    });
  }

  void deleteComment(String postId, String commentId) {
    _updatePost(postId, (post) {
      final (comments, removed) = _removeComment(post.comments, commentId);
      if (!removed) {
        return post;
      }
      return post.copyWith(comments: comments, updatedAt: DateTime.now());
    });
  }

  String generateCommentId() => const Uuid().v4();

  void _updatePost(String id, BoardPost Function(BoardPost post) transform) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) {
      return;
    }
    final updated = transform(_posts[index]);
    _posts[index] = updated;
    notifyListeners();
  }

  (List<BoardComment>, bool) _insertReply(
    List<BoardComment> comments,
    String parentId,
    BoardComment reply,
  ) {
    final List<BoardComment> updated = <BoardComment>[];
    var inserted = false;
    for (final comment in comments) {
      if (comment.id == parentId) {
        inserted = true;
        updated.add(
          comment.copyWith(
            replies: <BoardComment>[...comment.replies, reply],
          ),
        );
      } else {
        final (childReplies, childInserted) =
            _insertReply(comment.replies, parentId, reply);
        if (childInserted) {
          inserted = true;
          updated.add(comment.copyWith(replies: childReplies));
        } else {
          updated.add(comment);
        }
      }
    }
    return (updated, inserted);
  }

  (List<BoardComment>, bool) _removeComment(
    List<BoardComment> comments,
    String commentId,
  ) {
    final List<BoardComment> updated = <BoardComment>[];
    var removed = false;
    for (final comment in comments) {
      if (comment.id == commentId) {
        removed = true;
        continue;
      }
      final (childReplies, childRemoved) =
          _removeComment(comment.replies, commentId);
      if (childRemoved) {
        removed = true;
        updated.add(comment.copyWith(replies: childReplies));
      } else {
        updated.add(comment);
      }
    }
    return (updated, removed);
  }
}
