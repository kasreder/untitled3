// 파일 경로: lib/features/board/models/board_comment.dart
// 파일 설명: 게시판 댓글과 대댓글 정보를 표현하는 데이터 모델.

import 'package:equatable/equatable.dart';

/// 댓글 본문과 작성 정보를 캡슐화한 모델입니다.
class BoardComment extends Equatable {
  /// 댓글 및 대댓글 생성 시 모든 필수 필드를 설정합니다.
  const BoardComment({
    required this.id,
    required this.nickname,
    required this.content,
    required this.createdAt,
    this.replies = const <BoardComment>[],
  });

  final String id;
  final String nickname;
  final String content;
  final DateTime createdAt;
  final List<BoardComment> replies;

  /// 불변 객체 특성을 유지하면서 일부 필드만 변경합니다.
  BoardComment copyWith({
    String? id,
    String? nickname,
    String? content,
    DateTime? createdAt,
    List<BoardComment>? replies,
  }) {
    return BoardComment(
      id: id ?? this.id,
      nickname: nickname ?? this.nickname,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      replies: replies ?? this.replies,
    );
  }

  /// JSON 맵으로부터 댓글 인스턴스를 생성합니다.
  factory BoardComment.fromJson(Map<String, dynamic> json) {
    return BoardComment(
      id: json['id'] as String,
      nickname: json['nickname'] as String,
      content: json['content'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      replies: [
        for (final reply in json['replies'] as List<dynamic>? ?? <dynamic>[])
          BoardComment.fromJson(reply as Map<String, dynamic>),
      ],
    );
  }

  /// API 연동을 위해 현재 상태를 JSON으로 직렬화합니다.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nickname': nickname,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'replies': [
        for (final reply in replies) reply.toJson(),
      ],
    };
  }

  @override
  List<Object?> get props => [id, nickname, content, createdAt, replies];
}
