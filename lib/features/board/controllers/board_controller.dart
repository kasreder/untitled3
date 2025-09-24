// 파일 경로: lib/features/board/controllers/board_controller.dart
// 파일 설명: 게시글과 댓글을 관리하고 보기 모드를 전환하는 게시판 상태 컨트롤러.

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../data/board_repository.dart';
import '../models/board_comment.dart';
import '../models/board_post.dart';

/// 자유 게시판 데이터를 전역에서 공유할 수 있도록 관리하는 ChangeNotifier입니다.
class BoardController extends ChangeNotifier {
  /// 게시글 저장소 의존성을 주입해 초기 데이터를 로드할 수 있게 합니다.
  BoardController({
    required BoardRepository repository,
  }) : _repository = repository;

  final BoardRepository _repository;
  final List<BoardPost> _posts = <BoardPost>[];
  bool _isLoading = false;
  BoardViewMode _viewMode = BoardViewMode.list;

  /// 로딩 스피너 표시를 위한 상태 값입니다.
  bool get isLoading => _isLoading;

  /// 리스트/갤러리 보기 중 현재 활성화된 모드입니다.
  BoardViewMode get viewMode => _viewMode;

  /// 외부에서 수정하지 못하도록 방어 복사를 적용한 게시글 목록입니다.
  List<BoardPost> get posts => List<BoardPost>.unmodifiable(_posts);

  /// 저장소에서 초기 게시글 목록을 불러와 상태를 초기화합니다.
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

  /// 게시글 ID를 기준으로 게시글을 찾고, 없으면 null을 반환합니다.
  BoardPost? findById(String id) {
    try {
      return _posts.firstWhere((post) => post.id == id);
    } on StateError {
      return null;
    }
  }

  /// 지정된 보기 모드로 전환하며 값이 달라질 때만 알림을 보냅니다.
  void setViewMode(BoardViewMode mode) {
    if (_viewMode == mode) {
      return;
    }
    _viewMode = mode;
    notifyListeners();
  }

  /// 신규 게시글을 목록 맨 앞에 추가합니다.
  void addPost(BoardPost post) {
    _posts.insert(0, post);
    notifyListeners();
  }

  /// 기존 게시글을 수정하고 즉시 UI에 반영합니다.
  void updatePost(BoardPost updated) {
    final index = _posts.indexWhere((post) => post.id == updated.id);
    if (index == -1) {
      return;
    }
    _posts[index] = updated;
    notifyListeners();
  }

  /// 게시글을 삭제하고 변경 사항을 구독자에게 전달합니다.
  void deletePost(String id) {
    _posts.removeWhere((post) => post.id == id);
    notifyListeners();
  }

  /// 게시글의 조회수를 1 증가시킵니다.
  void registerView(String id) {
    _updatePost(id, (post) {
      return post.copyWith(views: post.views + 1);
    });
  }

  /// 좋아요 또는 싫어요 반응을 적용합니다.
  void reactToPost(String id, {required bool like}) {
    _updatePost(id, (post) {
      if (like) {
        return post.copyWith(likes: post.likes + 1);
      }
      return post.copyWith(dislikes: post.dislikes + 1);
    });
  }

  /// 댓글 혹은 대댓글을 추가해 댓글 트리를 갱신합니다.
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

  /// 댓글을 삭제하고 성공 여부에 따라 상태를 업데이트합니다.
  void deleteComment(String postId, String commentId) {
    _updatePost(postId, (post) {
      final (comments, removed) = _removeComment(post.comments, commentId);
      if (!removed) {
        return post;
      }
      return post.copyWith(comments: comments, updatedAt: DateTime.now());
    });
  }

  /// UUID 기반 댓글 식별자를 생성합니다.
  String generateCommentId() => const Uuid().v4();

  /// 지정된 게시글에 변환 함수를 적용한 뒤 알림을 전파합니다.
  void _updatePost(String id, BoardPost Function(BoardPost post) transform) {
    final index = _posts.indexWhere((post) => post.id == id);
    if (index == -1) {
      return;
    }
    final updated = transform(_posts[index]);
    _posts[index] = updated;
    notifyListeners();
  }

  /// 부모 댓글을 찾아 대댓글을 삽입하는 재귀 유틸리티입니다.
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

  /// 댓글 ID를 찾아 삭제하는 재귀 유틸리티입니다.
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
